##########################################################################################
# X% Off if Order Total Over Minimum
##########################################################################################

# Example: 25% off Priority Mail shipping on orders of more than $32. 
#
# Input:
# * SHIPPING_RATES_TO_DISCOUNT: List of shipping methods to make discounted. Matched by exact name.
# * MIN_CART_TOTAL: Minimum cart total to trigger discount in cents.
# * DISCOUNT_SHIPPING_PERCENT: Percent amount to discount (integer) Free = 100 for a 100% discount
# * DISCOUNT_SHIPPING_MESSAGE: Message to print on discounted shipping method

# To deactivate: Set SHIPPING_RATES_TO_DISCOUNT = []

SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail']
MIN_CART_TOTAL = 3200
DISCOUNT_SHIPPING_PERCENT = 25
DISCOUNT_SHIPPING_MESSAGE = "25% off for orders over $32!"

class DiscountShippingOverMinimumCartTotalCampaign

  def initialize(min_cart_total, discount_percent, discount_shipping_message, names_of_rates_to_discount)
    @min_cart_total = Money.new(cents: min_cart_total)
    @discount_percent = Float(discount_percent) / 100.00
    @discount_shipping_message = discount_shipping_message
    @names_of_rates_to_discount = names_of_rates_to_discount
  end

  def run
    return unless Input.cart.subtotal_price > @min_cart_total
    Input.shipping_rates.each do |shipping_rate|
      if @names_of_rates_to_discount.include?(shipping_rate.name)
        shipping_rate.apply_discount(shipping_rate.price * @discount_percent, message: @discount_shipping_message)
      end
    end
  end
end

CAMPAIGNS = [
  DiscountShippingOverMinimumCartTotalCampaign.new(
    MIN_CART_TOTAL,
    DISCOUNT_SHIPPING_PERCENT, 
    DISCOUNT_SHIPPING_MESSAGE,
    SHIPPING_RATES_TO_DISCOUNT
  )
]

CAMPAIGNS.each do |campaign|
  campaign.run
end

# pass input shipping rates to output.
Output.shipping_rates = Input.shipping_rates