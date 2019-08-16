# SPEND $X SAVE $Y

class SPENDXSAVECampaign
  attr_reader :coupon_code

  def initialize(spend_threshold, discount, message, discount_tags = [], code = nil, once = false)
    @spend_threshold = spend_threshold
    @discount = discount
    @message = message
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
      if @discount_tags.empty? || @discount_tags.any?{ |tag| product.tags.include?(tag) }
        total_cart_price += line_item.line_price.cents
      end
    end
    
    puts "eligible_items #{eligible_items}"
    return if eligible_items.empty? || total_cart_price < @spend_threshold

    case @discount.class.to_s
    when 'PercentageDiscount'
      puts "inside of case percentage discount"
      eligible_items.each do |line_item|
        puts "applying discount to line_item"
        @discount.apply(line_item)
      end
    when 'SetFlatAmountDiscount'
      puts "inside of SetFlatAmountDiscount"
      if @once
        puts "inside of SetFlatAmountDiscount once"
        # buy $50 get $10 back, but it does not compound. just distribute over items once.
        total_discount = Decimal.new(@discount.amount.cents)
      else
        puts "inside of SetFlatAmountDiscount compounding"
        # Distribute the total discount across the products propotional to their price
        # calculate total_discount based on the cart price and how much it exceeds the threshold.
        total_discount = (total_cart_price/@spend_threshold).floor * Decimal.new(@discount.amount.cents)
      end
      remainder = Decimal.new(0)
      eligible_items.each do |line_item|
        price = line_item.line_price.cents
        # money / decimal probably coverts proportion to money
        proportion =  Decimal.new(price / total_cart_price)
        # multiply total_discount by proportion for this item. 
        # add remainder - it will initially be 0.
        discount_float = (total_discount * proportion) + remainder
        # round to nearest.
        discount = discount_float.round
        # get remainder to pass to next
        remainder =  discount_float - discount
        line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @message) unless discount == 0
      end
    else
      return
    end
  end
end