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




# ########## Entire Site Campaign ########## 
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
# GREATER_OR_LOWER_THAN = :lower_than
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
# FLAT_AMOUNT = Money.new(cents: 3_99)
# MESSAGE = 'Flash sale!'

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAGS)
#   ],
#   SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
# )



###########################################

# Add a required coupon code to the flash sale above.

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

# CAMPAIGNS << CategoryCampaign.new(
#   [
#     CategorySelector.new(TAG_OPTIONS_A),
#     CategorySelector.new(TAG_OPTIONS_B)
#   ],
#   PercentageDiscount.new(PERCENT, MESSAGE)
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

# # Inputs:
# # Because it makes the math cleaner, we use cents instead of a Money object in this campaign type.
# # SPEND_THRESHOLD: number of cents needed in cart to trigger discount. 5000 = $50.
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

# Same, but with a required coupon code
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



###########################################

# # BUY MORE SAVE MORE: X QTY FOR $Y

# # Tag products for tiered discount campaign. Optional. 
# # Without tags, any item triggers the discount when bought in enough quantity.
TAGS = ['BUYXQTY']
COUPON_CODE = 'SUMMER'

# # quantity => discount type with price and message.
# # Use flat rate and or percent discount for any tier with any message.
# # List tiers in descending order by quantity. Highest quantity tier at the top.

# Flat Rate example: 
DISCOUNTS_BY_QUANTITY = {
  40 => SetFlatAmountDiscount.new(Money.new(cents: 1_00), 'Buy 40 for $1!'),
  30 => SetFlatAmountDiscount.new(Money.new(cents: 2_00), 'Buy 30 for $2!'),
  20 => SetFlatAmountDiscount.new(Money.new(cents: 3_00), 'Buy 20 for $3!'),
  10 => SetFlatAmountDiscount.new(Money.new(cents: 4_00), 'Buy 10 for $4!'),
}

# Percentage discount example
# DISCOUNTS_BY_QUANTITY = {
#   20 => PercentageDiscount.new(50, 'Buy 20, get 50% off!'),
#   10 => PercentageDiscount.new(25, 'Buy 10, get 25% off!')
# }

CAMPAIGNS << QuantityTierCampaign.new(
  DISCOUNTS_BY_QUANTITY,
  [
    CategorySelector.new(TAGS),
  ],
  COUPON_CODE
)



# #################################################################################
# # RUN CAMPAIGNS
# #################################################################################

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart

