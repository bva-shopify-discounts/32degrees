#################################################################################
# MERCHANT SETTINGS
# Enable, disable, customize each campaign type. 
#################################################################################

# EntireSiteCampaign settings
# set to 0 to deactivate entire site discount.
DISCOUNT_ENTIRE_SITE_PERCENT = 0
DISCOUNT_ENTIRE_SITE_MESSAGE = 'Summer discount event!'

# CategoryCampaign settings
# Take X percent off products tagged with these words.
# Use one or more words, or to deactivate set DISCOUNT_CATEGORY_TAGS = []
DISCOUNT_CATEGORY_TAGS = ['Sale', 'New']
DISCOUNT_CATEGORY_PERCENT = 20
DISCOUNT_CATEGORY_MESSAGE = "20% off new coffee!"

#################################################################################
# CUSTOM DISCOUNTS
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


#################################################################################
# CUSTOM SELECTORS
#################################################################################

# CategorySelector
# ============
#
# The `CategorySelector` selects items by 1 or more tags.
#
# Example
# -------
#   * Items where the variant has "sale" or "new" tags.
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


#################################################################################
# CUSTOM PARTITIONERS
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

    # example code.
    # applicable_items = cart.line_items.select do |line_item|
    #   @selector.match?(line_item)
    # end
    # discounted_items = @partitioner.partition(cart, applicable_items)

    # discounted_items.each do |line_item|
    #   @discount.apply(line_item)
    # end

    return if @discount == 0;

    cart.line_items.each do |line_item|
      @discount.apply(line_item)
    end
  end
end


class CategoryCampaign

  def initialize(category_selector, discount)
    @category_selector = category_selector
    @discount = discount
  end

  def run(cart)
    items_in_discount_category = cart.line_items.select do |line_item|
      @category_selector.match?(line_item)
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
  EntireSiteCampaign.new(
    PercentageDiscount.new(DISCOUNT_ENTIRE_SITE_PERCENT, DISCOUNT_ENTIRE_SITE_MESSAGE)
  ),
  CategoryCampaign.new(
    CategorySelector.new(DISCOUNT_CATEGORY_TAGS),
    PercentageDiscount.new(DISCOUNT_CATEGORY_PERCENT, DISCOUNT_CATEGORY_MESSAGE)
  ),
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart

