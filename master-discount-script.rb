#################################################################################
# MERCHANT SETTINGS
# Enable, disable, customize each campaign type. 
#################################################################################

# EntireSiteCampaign settings
# set to 0 to deactivate entire site discount.
DISCOUNT_ENTIRE_SITE_PERCENT = 0
DISCOUNT_ENTIRE_SITE_MESSAGE = 'Summer discount event!'

# CategoryCampaign settings

# Category Campaign 1: Category X Percent off
# Take X percent off products tagged with these words.
# Use one or more words, or to deactivate set DISCOUNT_CATEGORY_TAGS = []
DISCOUNT_CATEGORY_TAGS = ['Sale', 'New']
DISCOUNT_CATEGORY_PERCENT = 20
DISCOUNT_CATEGORY_MESSAGE = "20% off select coffees!"

# Category Campaign 2: Cups under $20 are 50% off.
# Entire Category X% off with price condition. 
DISCOUNT_CATEGORY_WITH_PRICE_CONDITION_TAGS = ['Cup']
GREATER_OR_LOWER_THAN = :lower_than
CATEGORY_PRICE = Money.new(cents: 20_00)
DISCOUNT_CATEGORY_WITH_PRICE_PERCENT = 50
DISCOUNT_CATEGORY_WITH_PRICE_MESSAGE = "50% off cups under $20!"

# Category Campaign 3: FLASH SALE SPECIFIC PRODUCT(S) PRICE $X.XX 
# Set tagged products to a flat amount
FLAT_AMOUNT_CATEGORY_TAGS = ['Flash']
FLAT_AMOUNT = Money.new(cents: 3_99)
# To disable this discount campaign, uncomment the following line to set FLAT_AMOUNT to nil:
# FLAT_AMOUNT = nil
FLAT_AMOUNT_CATEGORY_MESSAGE = 'Flash sale!'

#################################################################################
# DISCOUNTS
#################################################################################

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

# SetFlatAmountDiscount
# ============
#
# The `SetFlatAmountDiscount` discounts an item to a flat amount.
#
# Example
# -------
#   * Items tagged flash sale are $3.99
#   SetFlatAmountDiscount
#
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
    line_item.change_line_price(@amount, message: @message)
  end
end


#################################################################################
# SELECTORS
#################################################################################

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

# PriceSelector
# =============
#
# The `PriceSelector` selects items by price.
#
# Example
# -------
#   * Items with a price lower than $5
#   PriceSelector.new(:greater_than, Money.new(cents: 5_00))
#
class PriceSelector

  def initialize(condition, price)
    @price = price
    @condition = condition
  end

  def match?(line_item)
    case @condition
    when :greater_than
      line_item.variant.price > @price
    when :lower_than
      line_item.variant.price < @price
    end
  end
end


#################################################################################
# PARTITIONERS
#################################################################################

#################################################################################
# CAMPAIGN CLASSES
# Define each campaign with methods: initialize, run.
# Method run: modify cart.line_items directly, no need to return a variable.
# Method initialize: input selectors, partitioners and discounts.
# These should hold any client variables like discount amount. 
#################################################################################

class EntireSiteCampaign

  def initialize(discount)
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

#################################################################################
# EXECUTE CAMPAIGNS
# Initialize all campaigns and run them, passing in cart to modify.
#################################################################################

CAMPAIGNS = [
  # Entire site X% off.
  EntireSiteCampaign.new(
    PercentageDiscount.new(DISCOUNT_ENTIRE_SITE_PERCENT, DISCOUNT_ENTIRE_SITE_MESSAGE)
  ),
  # Category Campaign 1: 20% off items tagged 'sale' or 'new'.
  # Entire Category X% off. Category defined by 1 or more tags. 
  CategoryCampaign.new(
    [
      CategorySelector.new(DISCOUNT_CATEGORY_TAGS)
    ],
    PercentageDiscount.new(DISCOUNT_CATEGORY_PERCENT, DISCOUNT_CATEGORY_MESSAGE)
  ),
  # Category Campaign 2: Cups under $20 are 50% off.
  # Entire Category X% off with price condition. 
  CategoryCampaign.new(
    [
      CategorySelector.new(DISCOUNT_CATEGORY_WITH_PRICE_CONDITION_TAGS),
      PriceSelector.new(GREATER_OR_LOWER_THAN, CATEGORY_PRICE)
    ],
    PercentageDiscount.new(DISCOUNT_CATEGORY_WITH_PRICE_PERCENT, DISCOUNT_CATEGORY_WITH_PRICE_MESSAGE)
  ),
  # Category Campaign 3: Items tagged with 'Flash' are $3.99
  # Set tagged products to a flat amount: FLASH SALE SPECIFIC PRODUCT(S) PRICE $X.XX 
  CategoryCampaign.new(
    [
      CategorySelector.new(FLAT_AMOUNT_CATEGORY_TAGS)
    ],
    SetFlatAmountDiscount.new(FLAT_AMOUNT, FLAT_AMOUNT_CATEGORY_MESSAGE)
  )
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart

