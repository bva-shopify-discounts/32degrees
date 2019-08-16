
########## SHARED FUNCTIONS AND CLASSES ##########
class CouponCode
  attr_reader :campaign_code, :message

  def initialize(campaign_code, message = '  ')
    # this object would not be created if the discount campaign doesn't require a coupon code.
    @campaign_code = campaign_code
    @message = message
  end

  def disqualifies?(cart)
    # shopify scripts require you to check cart object before calling its methods
    if cart
      if cart.discount_code && cart.discount_code.code == campaign_code
        # if there is a code on the cart 
        # and if it matches the required campaign code
        # then remove the discount code from the cart with required message
        # then return false (qualifies) to apply campaign discount instead
        cart.discount_code.reject({ message: message })
        return false
      else
        # in this case discount code does not match or is not on cart
        # then return true because we are disqualified
        return true
      end
    end
  end
end

# End of coupon_code.rb 

# Apply a percentage discount to a line item.
class PercentageDiscount
  attr_reader :message

  def initialize(percent, message)
    @percent = Decimal.new(percent) / 100.0
    @message = message
  end

  def apply(line_item)
    line_discount = line_item.line_price * @percent
    new_line_price = line_item.line_price - line_discount
    line_item.change_line_price(new_line_price, message: @message)
    puts 'line_price, percent, line_discount, new_line_price'
    puts line_item.line_price
    puts @percent
    puts line_discount
    puts new_line_price
  end

  # need to implement these in each discount.
  def amount
    @percent
  end
end

# End of discount_percentage.rb 

# Discounts an item to a flat amount.
#
# Example
# -------
#   * Items tagged flash sale are $3.99
#
class SetFlatAmountDiscount
  attr_reader :message, :amount
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

# End of discount_set_flat_amount.rb 

# Partitions the items and returns the items that are to be discounted.
# Used in BOGO campaign

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


# End of partitioner_bogo.rb 

# Selects items by 1 or more tags.
#
# Example
# -------
#   * Items tagged with "sale" or "new".
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


# End of selector_category.rb 

# Selects items in the cart that are greater than (or less than) a price.
#
# Example
# -------
#   * Items with a price greater than $5
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
      line_item.line_price > @price
    when :less_than
      line_item.line_price < @price
    end
  end
end


# End of selector_price.rb 


########## CAMPAIGN CLASSES ##########
# BOGO FREE or X% OFF 
# Tagged products are discounted as buy a certain quantity and get X% off 
# To buy one get one free, you would say buy quantity = 1 and get X = 100% off.

class BOGOCampaign
  attr_reader :coupon_code

  def initialize(category_selectors, discount, partition, code = nil)
    @category_selectors = category_selectors
    @discount = discount
    @partition = partition
    @coupon_code = CouponCode.new(code) if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

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

# Usage:
# 
# BOGO
# Ex: Buy two products tagged with 'BOGO' and the third is 50% off.
# To get Buy X get X free:
  # set PERCENT = 100
  # because free = 100% discount

# TAGS = ['BOGO']
# MESSAGE = 'Buy 2 get 1 at 50% off!'
# PAID_ITEM_COUNT = 2
# DISCOUNTED_ITEM_COUNT = 1
# PERCENT = 50

# BOGOCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE),
#   BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT)
# )

# End of bogo.rb 

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

# End of category.rb 

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

# End of entire_site.rb 

# BUY MORE SAVE MORE: X QTY FOR $Y

class QuantityTierCampaign
  attr_reader :coupon_code

  def initialize(discounts_by_quantity, selectors = [], code = nil)
    @discounts_by_quantity = discounts_by_quantity
    @selectors = selectors
    @coupon_code = CouponCode.new(code) if code
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)

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

# Usage:
#
# # Tag products for tiered discount campaign. Optional. 
# # Without tags, any item triggers the discount when bought in enough quantity.
# TAGS = ['BUYXQTY']

# # quantity => discount type with price and message.
# # Use flat rate and or percent discount for any tier with any message.

# # Flat Rate example: 
# # DISCOUNTS_BY_QUANTITY = {
# #   40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
# #   30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
# #   20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
# #   10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
# # }

# # Percentage discount example
# DISCOUNTS_BY_QUANTITY = {
#   50 => PercentageDiscount.new(50, 'Buy 50, get 50% off!'),
#   30 => PercentageDiscount.new(30, 'Buy 30, get 30% off!'),
#   20 => PercentageDiscount.new(20, 'Buy 20, get 20% off!'),
#   10 => PercentageDiscount.new(10, 'Buy 10, get 10% off!')
# }

# CAMPAIGNS << QuantityTierCampaign.new(
#   DISCOUNTS_BY_QUANTITY,
#   [
#     CategorySelector.new(TAGS),
#   ]
# )


# End of quantity_tier.rb 

# SPEND $X SAVE $Y

class SPENDXSAVECampaign
  attr_reader :coupon_code

  def initialize(spend_threshold, discount, message, discount_tags = [], code = nil, once = false)
    @spend_threshold = spend_threshold
    @discount = discount
    @message = message
    @discount_tags = discount_tags
    @coupon_code = CouponCode.new(code) if code
    @once = once
  end

  def run(cart)
    return if @coupon_code && @coupon_code.disqualifies?(cart)
    return if @spend_threshold.nil? || @spend_threshold.zero?
    total_cart_price = Decimal.new(0)

    eligible_items = Input.cart.line_items.select do |line_item|
      # if eligible, put the line_item in the array and add its price to total_cart_price.
      # replace with CategorySelector
      if @discount_tags.empty? || @discount_tags.any?{ |tag| product.tags.include?(tag) }
        total_cart_price += line_item.line_price.cents
      end
    end
    
    puts "eligible_items #{eligible_items}"
    return if eligible_items.empty? || total_cart_price < @spend_threshold

    case @discount.class.to_s
    when 'PercentageDiscount'
      puts "inside of case percentage discount"
      eligible_items.each do |line_item|
        puts "applying discount to line_item"
        @discount.apply(line_item)
      end
    when 'SetFlatAmountDiscount'
      puts "inside of SetFlatAmountDiscount"
      if @once
        puts "inside of SetFlatAmountDiscount once"
        # buy $50 get $10 back, but it does not compound. just distribute over items once.
        total_discount = Decimal.new(@discount.amount.cents)
      else
        puts "inside of SetFlatAmountDiscount compounding"
        # Distribute the total discount across the products propotional to their price
        # calculate total_discount based on the cart price and how much it exceeds the threshold.
        total_discount = (total_cart_price/@spend_threshold).floor * Decimal.new(@discount.amount.cents)
      end
      remainder = Decimal.new(0)
      eligible_items.each do |line_item|
        price = line_item.line_price.cents
        # money / decimal probably coverts proportion to money
        proportion =  Decimal.new(price / total_cart_price)
        # multiply total_discount by proportion for this item. 
        # add remainder - it will initially be 0.
        discount_float = (total_discount * proportion) + remainder
        # round to nearest.
        discount = discount_float.round
        # get remainder to pass to next
        remainder =  discount_float - discount
        line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @message) unless discount == 0
      end
    else
      return
    end
  end
end

# End of spend_x_save.rb 

########### CURRENT CAMPAIGNS ###########

# Create all your current discount campaigns here
# They will be applied in order from top to bottom.
# Comment out the ones you don't want by selecting and pressing 'Command + /'
# Copy and paste to create new campaigns and change the available settings.

# Initialization steps (Please do not touch.)
CAMPAIGNS = []
TAGS = []
MESSAGE = 'Discount!'
###########################################




########## Entire Site Campaign ########## 
# # ENTIRE SITE X% OFF
# # Entire site 25% off for summer discount event.

# PERCENT = 25
# MESSAGE = 'Summer discount event!'

# CAMPAIGNS << EntireSiteCampaign.new(
#   PercentageDiscount.new(PERCENT, MESSAGE)
# )


###########################################


########### Category Campaigns ########## 

# Category Campaign 1: Category X Percent off
# Take X percent off products tagged with any of the words in TAGS.
# Use one or more words.

# Example: Take 20% off any products tagged as either 'New' or 'Sale'.
# TAGS = ['Sale', 'New']
# PERCENT = 10
# MESSAGE = "10% off select coffees!"

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE)
# )


###########################################
# NOTE: Order of discounts is defined here. 
# Example: 
# Cart contains 1 item of $80.
# Summer discount event on the entire site is applied first, making it $60.
# Then the 10% off select coffees is applied, making it $54.
###########################################

# Category Campaign 2: Entire Category $X or under (5)
# Select all items in cart tagged OUTERWEAR or SALE
# That also cost < $25
# Apply 50% discount

# TAGS = ['OUTERWEAR', 'ACCESSORIES']
# GREATER_OR_LOWER_THAN = :less_than
# # You can also separate out items with prices greater than X by uncommenting this:
# # GREATER_OR_LOWER_THAN = :greater_than
# CATEGORY_PRICE = Money.new(cents: 20_00)
# PERCENT = 50
# MESSAGE = "50% off Outerwear or Accessories under $20!"


# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAGS),
#     PriceSelector.new(GREATER_OR_LOWER_THAN, CATEGORY_PRICE)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE)
# )

###########################################

# Category Campaign 3: FLASH SALE SPECIFIC PRODUCT(S) PRICE $X.XX (6) 
# Select all items in cart tagged with 'Flash' 
# Set to a flat amount of $3.99
# Can include multiple tags to look for - ex: ['Flash', 'Clearance']

# TAGS = ['Flash']
# FLAT_AMOUNT = Money.new(cents: 7_50)
# MESSAGE = 'Flash Sale!'

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAGS),
#   ],
#   SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
# )




###########################################

# Add a required coupon code to the flash sale above.

# Item1 9.99
# Item2 11.99
# if I buy both then $7.50 each for both item 1 and 2

# TAGS = ['Flash']
# FLAT_AMOUNT = Money.new(cents: 3_99)
# MESSAGE = 'Summer Flash sale!'
# COUPON_CODE = 'SUMMER'

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
#   COUPON_CODE
# )


###########################################

# # Category Campaign 4: Multiple Tag Conditions 
# # To only mark certain items in a category as a particular discount:
# # Featured hats 10% off! x
# # Select all hats that are ALSO tagged as 'featured'

# TAG_OPTIONS_A = ['Hat']
# TAG_OPTIONS_B = ['Featured']
# PERCENT = 10
# MESSAGE = 'Featured hats 10% off!'
# COUPON_CODE = 'SUMMER'

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAG_OPTIONS_A),
#     CategorySelector.new(TAG_OPTIONS_B)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE),
#   COUPON_CODE
# )

###########################################


# BOGO
# Ex: Buy two products tagged with 'BOGO' and the third is 50% off.
# To get Buy X get X free:
  # set PERCENT = 100
  # because free = 100% discount

# TAGS = ['BOGO']
# MESSAGE = 'Buy 2 get 1 at 50% off!'
# PAID_ITEM_COUNT = 2
# DISCOUNTED_ITEM_COUNT = 1
# PERCENT = 50

# CAMPAIGNS << BOGOCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE),
#   BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT)
# )

# Same discount as above but unlocked with a coupon code.

# TAGS = ['BOGO']
# MESSAGE = 'Buy 2 get 1 at 50% off!'
# PAID_ITEM_COUNT = 2
# DISCOUNTED_ITEM_COUNT = 1
# PERCENT = 50
# COUPON_CODE = 'SUMMER'

# CAMPAIGNS << BOGOCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE),
#   BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT),
#   COUPON_CODE
# )




###########################################


# SpendXGet$Y
# Ex: Spend $50 get $10 

# Inputs:
# Because it makes the math cleaner, we use cents instead of a Money object in this campaign type.
# SPEND_THRESHOLD: number of cents needed in cart to trigger discount. 5000 = $50.
# SPEND_THRESHOLD = 5000
# # DISCOUNT_AMOUNT: How much to subtract from cart total when discount triggered in cents. 
# DISCOUNT_AMOUNT = 1000
# # MESSAGE: Message to display in checkout.
# MESSAGE = 'Spend $50 and get $10 off!'

# CAMPAIGNS << SPENDXSAVECampaign.new(
#   SPEND_THRESHOLD,
#   DISCOUNT_AMOUNT,
#   MESSAGE
# )

# add functionality for both flat rate and percent off for qualifying orders.

# # Same, but with a required coupon code
# SPEND_THRESHOLD = 5000
# DISCOUNT_AMOUNT = 1000
# MESSAGE = 'Spend $50 and get $10 off!'
# COUPON_CODE = 'SUMMER'
# TAGS = []

# CAMPAIGNS << SPENDXSAVECampaign.new(
#   SPEND_THRESHOLD,
#   DISCOUNT_AMOUNT,
#   MESSAGE,
#   TAGS,
#   COUPON_CODE
# )
SPEND_THRESHOLD = 5000
# DISCOUNT = PercentageDiscount.new(25, '25% off!')
# MESSAGE = '25% off!'
# Once does not get used here because it would be weird to compound a %.

# Set a flat amount once if over threshold
# DISCOUNT = SetFlatAmountDiscount.new(Money.new(cents: 10_00), 'Buy over $50 and get $10 back!')
# MESSAGE = 'Buy over $50 and get $10 back'
# ONCE = TRUE

# Set a flat amount to get back EVERY TIME you spend the threshold.
DISCOUNT = SetFlatAmountDiscount.new(Money.new(cents: 10_00), 'For every $50 you spend, get $10 back!')
MESSAGE = 'For every $50 you spend, get $10 back.'
COUPON_CODE = 'SUMMER'
TAGS = []
ONCE = false

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)



###########################################

# # BUY MORE SAVE MORE: X QTY FOR $Y

# # Tag products for tiered discount campaign. Optional. 
# # Without tags, any item triggers the discount when bought in enough quantity.
# TAGS = ['BUYXQTY']
# COUPON_CODE = 'SUMMER'

# # # quantity => discount type with price and message.
# # # Use flat rate and or percent discount for any tier with any message.
# # # List tiers in descending order by quantity. Highest quantity tier at the top.

# # Flat Rate example: 
# DISCOUNTS_BY_QUANTITY = {
#   40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
#   30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
#   20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
#   10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
# }

# A and B are $10 each, buy them together they are $7.50

# Percentage discount example
# DISCOUNTS_BY_QUANTITY = {
#   20 => PercentageDiscount.new(50, 'Buy 20, get 50% off!'),
#   10 => PercentageDiscount.new(25, 'Buy 10, get 25% off!')
# }

# CAMPAIGNS << QuantityTierCampaign.new(
#   DISCOUNTS_BY_QUANTITY,
#   [
#     CategorySelector.new(TAGS),
#   ],
# )



# #################################################################################
# # RUN CAMPAIGNS
# #################################################################################

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart


# End of current_campaigns.rb 

