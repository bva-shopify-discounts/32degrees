# BOGO Campaign
# Tagged products are discounted as buy a certain quantity and get X% off 
# To buy one get one free, you would say buy quantity = 1 and get X = 100% off.

class BOGOCampaign
  attr_reader :coupon_code

  def initialize(category_selectors, discount, partition, code = nil)
    @category_selectors = category_selectors
    @discount = discount
    @partition = partition
    @coupon_code = CouponCode.new(code) if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

    items_in_discount_category = cart.line_items.select do |line_item|
      @category_selectors.all? do |selector|
        selector.match?(line_item)
      end
    end

    discount_these_items = @partition.partition(cart, items_in_discount_category)

    discount_these_items.each do |line_item|
      @discount.apply(line_item)
    end
  end
end

# Usage:
# Buy two products tagged with 'BOGO' and the third is 50% off.

# BOGO Campaign takes 4 inputs.
# 1) An array [] of conditions to define your category (a CategorySelector for tags, a PriceSelector to restrict by price etc.)
# 2) A discount to apply (flat rate, percentage, etc.)
# 3) A Bogo Partitions, which itself takes 2 inputs: paid_item_count, discounted_item_count. 
#    In this example, these would be 2, 1 (buy 2, get 1) BOGOPartitioner.new(2, 1)
# 4) Optional coupon code to require.

