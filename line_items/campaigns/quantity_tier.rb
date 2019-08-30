# QuantityTier Campaign
# Buy more save more.
# Apply a discount to a line item based on its quantity. 

class QuantityTierCampaign
  attr_reader :coupon_code

  def initialize(discounts_by_quantity, selectors = [], code = nil)
    @discounts_by_quantity = discounts_by_quantity
    @selectors = selectors
    @coupon_code = CouponCode.new(code) if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

    items_in_discount_category = cart.line_items.select do |line_item|
      # if no selectors, item goes into discount category. default all.
      @selectors.all? do |selector|
        selector.match?(line_item)
      end
    end

    total_quantity = items_in_discount_category.inject(0){|sum, item| sum + item.quantity }

    # @discounts_by_quantity is a key value pair of quantity => discount
    # we need to look through each tier and find the first one where total_quantity >= its quantity.
    # @discounts_by_quantity needs to be sorted from high to low quantity to match the highest qualifying tier.
    # Keys are quantities so we get them out, sort them, and look up the discounts to put in a new hash in order.
    @sorted_discounts_by_quantity = {}
    keys = @discounts_by_quantity.keys.sort.reverse
    keys.each{|key| @sorted_discounts_by_quantity[key] = @discounts_by_quantity[key] }

    quantity, discount = @sorted_discounts_by_quantity.detect do |quantity, discount|
      puts "total_quantity #{total_quantity}"
      puts "quantity #{quantity}"
      puts "discount #{discount}"
      total_quantity >= quantity
    end

    # if not qualified for a discount tier, return and continue checkout.
    return unless discount
    # if qualified for discount, apply to all items.
    items_in_discount_category.each do |line_item|
      discount.apply(line_item)
    end
  end
end

# Usage:
# Buy at least 10, get 10% off. Buy 20, get 20% off.

# QuantityTierCampaign needs 3 inputs.
# 1) discounts_by_quantity is an object defining the quantity tiers needed to qualify. For example: 
# Flat Rate example: 
# DISCOUNTS_BY_QUANTITY = {
#   40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
#   30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
#   20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
#   10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
# }
# Percent example:
# DISCOUNTS_BY_QUANTITY = {
#   50 => PercentageDiscount.new(50, 'Buy 50, get 50% off!'),
#   30 => PercentageDiscount.new(30, 'Buy 30, get 30% off!'),
#   20 => PercentageDiscount.new(20, 'Buy 20, get 20% off!'),
#   10 => PercentageDiscount.new(10, 'Buy 10, get 10% off!')
# }

# 2) An array [] of conditions to define your category (a CategorySelector for tags, a PriceSelector to restrict by price etc.)
# 3) Optional coupon code to require.
