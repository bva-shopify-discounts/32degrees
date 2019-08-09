# SHARED
############################################

# Apply a percentage discount to a line item.
class PercentageDiscount

  def initialize(percent, message)
    @percent = Decimal.new(percent) / 100.0
    @message = message
  end

  def apply(line_item)
    line_discount = line_item.line_price * @percent
    new_line_price = line_item.line_price - line_discount
    line_item.change_line_price(new_line_price, message: @message)
    puts "Discounted line item with variant #{line_item.variant.id} by #{line_discount}."
  end

end

class SetFlatAmountDiscount

  # arguments:
  # amount: flat amount to set line item price to as class Money.
  # message: display with line item.
  def initialize(amount, message)
    @amount = amount
    @message = message
  end

  def apply(line_item)
    # discount inactive if amount is nil.
    return if @amount.nil?
    line_item.change_line_price(@amount * line_item.quantity, message: @message)
  end
end


# CategorySelector
# ============
#
# The `CategorySelector` selects items by 1 or more tags.
#
# Example
# -------
#   * Items where the variant has "sale" or "new" tags.
#   CategorySelector.new(['sale', 'new'])
#   CategorySelector.new(['featured'])
#
#
class CategorySelector

  #    Array of strings that the selector will look for in the item tags.
  def initialize(category_tags = [])
    @category_tags = category_tags
  end

  def match?(line_item)
    # take each tag on the line item, and if any of them are included in the category tags return true.
    line_item.variant.product.tags.any?{ |tag| @category_tags.include?(tag) }
  end
end

############################################

# SETTINGS

# quantity => discount type with price and message. 
# Use flat rate and or percent discount for any tier with any message.

# DISCOUNTS_BY_QUANTITY = {
#   40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
#   30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
#   20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
#   10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
# }

DISCOUNTS_BY_QUANTITY = {
  50 => PercentageDiscount.new(50, 'Buy 50, get 50% off!'),
  30 => PercentageDiscount.new(30, 'Buy 30, get 30% off!'),
  20 => PercentageDiscount.new(20, 'Buy 20, get 20% off!'),
  10 => PercentageDiscount.new(10, 'Buy 10, get 10% off!')
}

# Tag products for tiered discount campaign. Optional. 
# Set = [] for entire site. 
QUANTITY_TIER_TAGS = ['BUYXQTY']

############################################

class QuantityTierCampaign
  def initialize(discounts_by_quantity, selectors = [])
    @discounts_by_quantity = discounts_by_quantity
    @selectors = selectors
  end

  def run(cart)
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

############################################

# INITIALIZATION

############################################


CAMPAIGNS = [
  QuantityTierCampaign.new(
    DISCOUNTS_BY_QUANTITY,
    [
      CategorySelector.new(QUANTITY_TIER_TAGS),
    ]
  )
]

# work out later how to do a flat rate discount. should pass it in. DONE.
# make sure you can use cart not Input.cart directly. done.
# then keywords. should take a selector for category. DONE.

############################################

# EXECUTION

############################################

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart
