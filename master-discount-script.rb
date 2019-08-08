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
# Take X percent off products tagged with any of the words in DISCOUNT_CATEGORY_TAGS.
# Use one or more words, or to deactivate set DISCOUNT_CATEGORY_TAGS = []

# Example: Take 20% off any products tagged as either 'New' or 'Sale'.
# DISCOUNT_CATEGORY_TAGS = ['Sale', 'New']
DISCOUNT_CATEGORY_TAGS = []
DISCOUNT_CATEGORY_PERCENT = 20
DISCOUNT_CATEGORY_MESSAGE = "20% off select coffees!"

# Category Campaign 2: Cups under $20 are 50% off.
# Entire Category X% off with price condition. 
# To deactivate set DISCOUNT_CATEGORY_WITH_PRICE_CONDITION_TAGS = []
# DISCOUNT_CATEGORY_WITH_PRICE_CONDITION_TAGS = ['Cup']
DISCOUNT_CATEGORY_WITH_PRICE_CONDITION_TAGS = []
GREATER_OR_LOWER_THAN = :lower_than
CATEGORY_PRICE = Money.new(cents: 20_00)
DISCOUNT_CATEGORY_WITH_PRICE_PERCENT = 50
DISCOUNT_CATEGORY_WITH_PRICE_MESSAGE = "50% off cups under $20!"

# Category Campaign 3: FLASH SALE SPECIFIC PRODUCT(S) PRICE $X.XX 
# Set products tagged as 'Flash' to a flat amount. 
# Can include multiple tags to look for - ex: ['Flash', 'Clearance']

# To deactivate: 
# remove the 'Flash' tag from the product, or set 
# FLAT_AMOUNT_CATEGORY_TAGS = []
FLAT_AMOUNT_CATEGORY_TAGS = ['Flash']
FLAT_AMOUNT = Money.new(cents: 3_99)
FLAT_AMOUNT_CATEGORY_MESSAGE = 'Flash sale!'

# BOGO
# Ex: Buy two products tagged with 'BOGO' and the third is 50% off.
BOGO_CATEGORY_TAGS = ['BOGO']
BOGO_MESSAGE = 'Buy 2 get 50% off!'
PAID_ITEM_COUNT = 2
DISCOUNTED_ITEM_COUNT = 1
BOGO_DISCOUNT_PERCENT = 50
# To disable:
  # set BOGO_CATEGORY_TAGS = []
# To get Buy X get X free:
  # set BOGO_DISCOUNT_PERCENT = 100
  # because free = 100% discount

# SpendXGet$Y
# Ex: Spend $50 get $10 

# Inputs:
# * SPEND_THRESHOLD: number of cents needed in cart to trigger discount. 5000 = $50.
# To disable: 
#   SPEND_THRESHOLD_AMOUNT = nil
SPEND_THRESHOLD = 5000
# * DISCOUNT_AMOUNT: How much to subtract from cart total when discount triggered. 
DISCOUNT_AMOUNT = 1000
# * SPEND_X_SAVE_MESSAGE: Message to display in checkout.
SPEND_X_SAVE_MESSAGE = 'Spend $50 and get $10 off!'

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
    line_item.change_line_price(@amount * line_item.quantity, message: @message)
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

class BOGOPartitioner

  def initialize(paid_item_count, discounted_item_count)
    @paid_item_count = paid_item_count
    @discounted_item_count = discounted_item_count
  end

  # Returns the integer amount of items that must be discounted next
  # given the amount of items seen
  #
  def discounted_items_to_find(total_items_seen, discounted_items_seen)
    Integer(total_items_seen / (@paid_item_count + @discounted_item_count) * @discounted_item_count) - discounted_items_seen
  end

  # Partitions the items and returns the items that are to be discounted.
  #
  # Arguments
  # ---------
  #
  # * cart
  #   The cart to which split items will be added (typically Input.cart).
  #
  # * line_items
  #   The selected items that are applicable for the campaign.
  #
  def partition(cart, line_items)
    # Sort the items by price from high to low
    sorted_items = line_items.sort_by{|line_item| line_item.variant.price}.reverse
    # Create an array of items to return
    discounted_items = []
    # Keep counters of items seen and discounted, to avoid having to recalculate on each iteration
    total_items_seen = 0
    discounted_items_seen = 0

    # Loop over all the items and find those to be discounted
    sorted_items.each do |line_item|
      total_items_seen += line_item.quantity
      # After incrementing total_items_seen, see if any items must be discounted
      count = discounted_items_to_find(total_items_seen, discounted_items_seen)
      # If there are none, skip to the next item
      next if count <= 0

      if count >= line_item.quantity
        # If the full item quantity must be discounted, add it to the items to return
        # and increment the count of discounted items
        discounted_items.push(line_item)
        discounted_items_seen += line_item.quantity
      else
        # If only part of the item must be discounted, split the item
        discounted_item = line_item.split(take: count)
        # Insert the newly-created item in the cart, right after the original item
        position = cart.line_items.find_index(line_item)
        cart.line_items.insert(position + 1, discounted_item)
        # Add it to the list of items to return
        discounted_items.push(discounted_item)
        discounted_items_seen += discounted_item.quantity
      end
    end

    # Return the items to be discounted
    discounted_items
  end
end


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

class BOGOCampaign
  def initialize(category_selectors, discount, partition)
    @category_selectors = category_selectors
    @discount = discount
    @partition = partition
  end

  def run(cart)
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

class SPENDXSAVECampaign
  def initialize(spend_threshold, discount_amount, message, discount_tags = [])
    @spend_threshold = spend_threshold
    @discount_amount = discount_amount
    @message = message
    @discount_tags = discount_tags
  end

  def run(cart)
    return if @spend_threshold.nil? || @spend_threshold.zero?
    total_cart_price = 0

    # Loop over all the items to find eligble ones and total eligible discount price
    eligible_items = Input.cart.line_items.select do |line_item|
      total_cart_price += Integer(line_item.line_price.cents.to_s)
      true
    end

    #   product = line_item.variant.product
    #   @discount_tags.any?{ |tag| product.tags.include?(tag) }
    # end

    message = ""
    # total_discount is the amount * the number of times over the spend_threshold the cart is.
    # if total cart price of elligible items is $140 and we say 'spend $50 get $10'
    # 140/50 rounded down gives us 2. total_discount is 2 * @discount_amount = 2 * $10 = $20 off.
    total_discount = (total_cart_price/@spend_threshold).floor * @discount_amount
    # to distribute a flat rate one time total discount amount just set this to @discount_amount

    # Distribute the total discount across the products propotional to their price
    remainder = 0.0
    eligible_items.each do |line_item|
      price = Integer(line_item.line_price.cents.to_s)
      proportion =  price / total_cart_price
      discount_float = (total_discount * proportion) + remainder
      discount = discount_float.round
      remainder =  discount_float - discount
      line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @message) unless discount == 0
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
  ),
  BOGOCampaign.new(
    [
      CategorySelector.new(BOGO_CATEGORY_TAGS)
    ],
    PercentageDiscount.new(BOGO_DISCOUNT_PERCENT, BOGO_MESSAGE),
    BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT)
  ),
  SPENDXSAVECampaign.new(SPEND_THRESHOLD, DISCOUNT_AMOUNT, SPEND_X_SAVE_MESSAGE)
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart

