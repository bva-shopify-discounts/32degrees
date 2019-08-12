# ENTIRE SITE X% OFF 
# Pass a discount into this campaign and it will be applied to each item in the cart

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
# 
# (1, 3)
# Entire site 25% off for summer discount event.

# PERCENT = 25
# MESSAGE = 'Summer discount event!'

# EntireSiteCampaign.new(
#   PercentageDiscount.new(PERCENT, MESSAGE)
# )