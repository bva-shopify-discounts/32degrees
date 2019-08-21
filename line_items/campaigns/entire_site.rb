# Entire Site Campaign
# Pass a discount into this campaign and it will be applied to each item in the cart.

class EntireSiteCampaign

  def initialize(discount = 0)
    @discount = discount
  end

  # modify cart.line_items directly, so no need to return. 
  def run(cart)

    return if @discount == 0;

    cart.line_items.each do |line_item|
      @discount.apply(line_item)
    end
  end
end

# Usage:
# Entire site 25% off for summer discount event.

# Entire Site Campaign takes 1 input:
# 1) A discount to apply (flat rate, percentage, etc.)

# Notes: 
# If a coupon code is needed to unlock the discount, use a Category Campaign with no tags.
