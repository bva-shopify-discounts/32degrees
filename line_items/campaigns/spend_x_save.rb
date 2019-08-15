# SPEND $X SAVE $Y

class SPENDXSAVECampaign
  attr_reader :coupon_code

  def initialize(spend_threshold, discount_amount, message, discount_tags = [], code = nil)
    @spend_threshold = spend_threshold
    @discount_amount = discount_amount
    @message = message
    @discount_tags = discount_tags
    @coupon_code = CouponCode.new(code, ' ') if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)
    return if @spend_threshold.nil? || @spend_threshold.zero?

    total_cart_price = 0

    eligible_items = Input.cart.line_items.select do |line_item|
      # if eligible, put the line_item in the array and add its price to total_cart_price.
      if @discount_tags.empty? || @discount_tags.any?{ |tag| product.tags.include?(tag) }
        total_cart_price += Integer(line_item.line_price.cents.to_s)
      end
    end

    # total_discount is the amount * the number of times over the spend_threshold the cart is.
    # if total cart price of elligible items is $140 and we say 'spend $50 get $10'
    # 140/50 rounded down gives us 2. total_discount is 2 * @discount_amount = 2 * $10 = $20 off.
    total_discount = (total_cart_price/@spend_threshold).floor * @discount_amount
    # to distribute a flat rate one time total discount amount just set this to @discount_amount

    # Distribute the total discount across the products propotional to their price
    remainder = 0.0
    eligible_items.each do |line_item|
      price = Integer(line_item.line_price.cents.to_s)
      proportion =  price / total_cart_price
      discount_float = (total_discount * proportion) + remainder
      discount = discount_float.round
      remainder =  discount_float - discount
      line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @message) unless discount == 0
    end
  end
end

# Usage:
# 
# Ex: Spend $50 get $10 

# # Inputs:
# # Because it makes the math cleaner, we use cents instead of a Money object in this campaign type.
# # SPEND_THRESHOLD: number of cents needed in cart to trigger discount. 5000 = $50.
# SPEND_THRESHOLD = 5000
# # DISCOUNT_AMOUNT: How much to subtract from cart total when discount triggered in cents. 
# DISCOUNT_AMOUNT = 1000
# # MESSAGE: Message to display in checkout.
# MESSAGE = 'Spend $50 and get $10 off!'

# CAMPAIGNS << SPENDXSAVECampaign.new(
#   SPEND_THRESHOLD,
#   DISCOUNT_AMOUNT,
#   MESSAGE
# )
