# Category Campaign
# Apply discount to any cart items which pass all category selectors.
 
class CategoryCampaign

  def initialize(category_selectors, discount)
    @category_selectors = category_selectors
    @discount = discount
  end

  def run(cart)
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
# 
# Entire Category $X or under (5)
# Select all items in cart tagged OUTERWEAR or SALE
# That also cost < $25
# Apply 50% discount

# CategoryCampaign.new(
#   [
#     CategorySelector.new(['OUTERWEAR', 'SALE'])
#   ],
#   PercentageDiscount.new(50, 'Buy 50, get 50% off!'),
# )

# FLASH SALE SPECIFIC PRODUCT(S) PRICE $X.XX (6) 
# Select all items in cart tagged with 'Flash' 
# Set to a flat amount of $3.99
# CategoryCampaign.new(
#   [
#     CategorySelector.new(['Flash'])
#   ],
#   SetFlatAmountDiscount.new(
#     Money.new(cents: 3_99), 
#     'Flash sale!'
#   )
# )

# You can control the order discounts are applied in current_campaigns.rb

# Entire Category 25% off (1, 2)
# Select all items in cart tagged OUTERWEAR or SALE
# Apply a 25% discount.

# CategoryCampaign.new(
#   [
#     CategorySelector.new(['OUTERWEAR', 'SALE'])
#   ],
#   PercentageDiscount.new(25, '25% off Outerwear!')
# )

# EXTRA X% OFF (3)
# All 'Jackets' take an extra 60% off
# This becomes and extra % off if you put it at the end of the discount list in current_campaigns.rb

# CategoryCampaign.new(
#   [
#     CategorySelector.new(['Jackets'])
#   ],
#   PercentageDiscount.new(60, 'Take an extra 60% off Jackets!')
# )

# To only mark certain items in a category as a particular discount:
# Featured hats 10% off! 
# Select all hats that are ALSO tagged as 'featured'

# CategoryCampaign.new(
#   [
#     CategorySelector.new(['hat']),
#     CategorySelector.new(['featured'])
#   ],
#   PercentageDiscount.new(10, 'Featured hats 10% off!')
# )


# Summary:
# Category campaign needs two inputs. 
# 1) An array [] of conditions to define your category (tags, a price threshold etc.)
# 2) A discount to apply (flat rate, percentage, etc.)