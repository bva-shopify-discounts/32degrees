# BUY MORE SAVE MORE: X QTY FOR $Y

class QuantityTierCampaign
  attr_reader :coupon_code

  def initialize(discounts_by_quantity, selectors = [], code = nil)
    @discounts_by_quantity = discounts_by_quantity
    @selectors = selectors
    @coupon_code = CouponCode.new(code, ' ') if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

    items_in_discount_category = cart.line_items.select do |line_item|
      # if no selectors, item goes into discount category. default all.
      @selectors.all? do |selector|
        selector.match?(line_item)
      end
    end

    items_in_discount_category.each do |line_item|
      # return the first tier (key value pair of quantity => discount)
      # where line_item.quantity >= current quantity (key). 
      quantity, discount = @discounts_by_quantity.detect do |quantity, discount|
        line_item.quantity >= quantity
      end
      # skip this line item if quantity does not qualify for a tier 
      next unless discount
      discount.apply(line_item)
    end
  end
end

# Usage:
#
# # Tag products for tiered discount campaign. Optional. 
# # Without tags, any item triggers the discount when bought in enough quantity.
# TAGS = ['BUYXQTY']

# # quantity => discount type with price and message.
# # Use flat rate and or percent discount for any tier with any message.

# # Flat Rate example: 
# # DISCOUNTS_BY_QUANTITY = {
# #   40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
# #   30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
# #   20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
# #   10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
# # }

# # Percentage discount example
# DISCOUNTS_BY_QUANTITY = {
#   50 => PercentageDiscount.new(50, 'Buy 50, get 50% off!'),
#   30 => PercentageDiscount.new(30, 'Buy 30, get 30% off!'),
#   20 => PercentageDiscount.new(20, 'Buy 20, get 20% off!'),
#   10 => PercentageDiscount.new(10, 'Buy 10, get 10% off!')
# }

# CAMPAIGNS << QuantityTierCampaign.new(
#   DISCOUNTS_BY_QUANTITY,
#   [
#     CategorySelector.new(TAGS),
#   ]
# )

