# Input.shipping_rates.each do |shipping_rate|
#   # next unless shipping_rate.source == "shopify"
#   shipping_rate.apply_discount(shipping_rate.price * 0.10, message: "Discounted shipping")
# end

# Output.shipping_rates = Input.shipping_rates

# List of shipping methods to make discounted. Matched by exact name.
# To deactivate: Set # SHIPPING_RATES_TO_DISCOUNT = []
# Example: Free shipping on orders of more than $32. 
SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail', 'Priority Mail Express']
MIN_CART_TOTAL = Money.new(cents: 32_00)
DISCOUNT_SHIPPING_PERCENT = 50
DISCOUNT_SHIPPING_MESSAGE = "Free shipping for orders over $32!"

class DiscountShippingOverMinimumCartTotalCampaign

  def initialize(min_cart_total, discount_percent, discount_shipping_message, names_of_rates_to_discount)
    @min_cart_total = min_cart_total
    @discount_percent = Float(100 - discount_percent) / 100.0
    @discount_shipping_message = discount_shipping_message
    @names_of_rates_to_discount = names_of_rates_to_discount
  end

  def run
    return unless Input.cart.subtotal_price > @min_cart_total
    puts "Passed conditions."
    Input.shipping_rates.each do |shipping_rate|
      # shipping_rate.apply_discount(shipping_rate.price * 0.50, message: '50% off all shipping!')
      puts "discount calculated shipping_rate.price * @discount_percent #{shipping_rate.price * @discount_percent}"
      shipping_rate.apply_discount(shipping_rate.price * @discount_percent, message: @discount_shipping_message)
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