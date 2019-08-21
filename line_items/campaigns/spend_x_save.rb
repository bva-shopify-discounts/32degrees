# SPEND $X SAVE $Y
# If the qualifying items in the cart cost more than the threshold apply a discount evenly to them.

class SPENDXSAVECampaign
  attr_reader :coupon_code

  def initialize(spend_threshold, discount, discount_tags = [], code = nil, once = false)
    @spend_threshold = spend_threshold
    @discount = discount
    @discount_tags = discount_tags
    @coupon_code = CouponCode.new(code) if code
    @once = once
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)
    return if @spend_threshold.nil? || @spend_threshold.zero?
    total_cart_price = Decimal.new(0)

    eligible_items = Input.cart.line_items.select do |line_item|
      # if eligible, put the line_item in the array and add its price to total_cart_price.
      # replace with CategorySelector
      @category_selector = CategorySelector.new(@discount_tags)
      if @category_selector.match?(line_item)
        total_cart_price += line_item.line_price.cents
      end
    end
    
    return if eligible_items.empty? || total_cart_price < @spend_threshold

    case @discount.class.to_s
    when 'PercentageDiscount'
      eligible_items.each do |line_item|
        @discount.apply(line_item)
      end
    when 'SetFlatAmountDiscount'
      if @once
        # buy $50 get $10 back, but it does not compound. just distribute over items once.
        total_discount = Decimal.new(@discount.amount.cents)
      else
        # Distribute the total discount across the products propotional to their price
        # calculate total_discount based on the cart price and how much it exceeds the threshold.
        times_to_apply = (total_cart_price/@spend_threshold).floor
        amount_to_apply = Decimal.new(@discount.amount.cents)
        total_discount = times_to_apply * amount_to_apply
      end
      remainder = Decimal.new(0)
      eligible_items.each do |line_item|
        # price of line_item including quantity
        price = line_item.line_price.cents
        # how much of the total cart price is it? we distribute the total_discount evenly.
        proportion =  Decimal.new(price / total_cart_price)
        # multiply total_discount by proportion for each item and add remainder (initially is 0). 
        discount_float = (total_discount * proportion) + remainder
        # round to nearest.
        discount = discount_float.round
        # get remainder to pass to next
        remainder =  discount_float - discount
        # set price to current - calculated discount
        line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @discount.message) unless discount == 0
      end
    else
      return
    end
  end
end

# Usage:
# Spend $50 get $5 back.

# SPENDXSAVECampaign takes 5 inputs.
# 1) Spend threshold - integer - cents to qualify for discount
# 2) A discount to apply (flat rate, percentage, etc.)
# 3) Optional: An array [] of conditions to define your category (a CategorySelector for tags, a PriceSelector to restrict by price etc.)
# 4) Optional: coupon code to require.
# 5) Optional: Boolean value to decide whether or not to discount a flat rate multiple times. 
#    If once is true, then if you exceed the threshold you only get the discount once.
#    If once is false, then you get the discount every time the threshold is exceeded. 
#    If we are using a percent discount then once is ignored. Percents are applied only once. 