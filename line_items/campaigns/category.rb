# Category Campaign
# Apply discount to any cart items which pass all category selectors.
 
class CategoryCampaign
  attr_reader :coupon_code

  def initialize(category_selectors, discount, code = nil)
    @category_selectors = category_selectors
    @discount = discount
    @coupon_code = CouponCode.new(code) if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

    items_in_discount_category = cart.line_items.select do |line_item|
      @category_selectors.all? do |selector|
        selector.match?(line_item)
      end
    end

    items_in_discount_category.each do |line_item|
      @discount.apply(line_item)
    end
  end
end

# Usage:
# Take 20% off any products tagged as ‘New’.

# Category campaign needs 3 inputs.
# 1) An array [] of conditions to define your category (a CategorySelector for tags, a PriceSelector to restrict by price etc.)
# 2) A discount to apply (flat rate, percentage, etc.)
# 3) Optional coupon code to require.
