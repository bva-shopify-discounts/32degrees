########### CURRENT CAMPAIGNS ###########

# Create all your current discount campaigns here by copying and pasting templates from the readme.
# They will be applied in order from top to bottom.

# Initialization steps (Please do not touch.)
CAMPAIGNS = []

###########################################
# ADD CAMPAIGNS HERE:
###########################################






###########################################
# EXAMPLES: See README.md for the full list
###########################################
# def july_4_sale
#   PERCENT = 25
#   MESSAGE = '4th of July Sale!'

#   EntireSiteCampaign.new(
#     PercentageDiscount.new(PERCENT, MESSAGE)
#   )
# end

# CAMPAIGNS << july_4_sale
###########################################
# def flash_sale
#   TAGS = ['Flash']
#   FLAT_AMOUNT = 750
#   MESSAGE = 'Flash Sale!'
#   COUPON_CODE = nil

#   CategoryCampaign.new(
#     [
#       CategorySelector.new(TAGS),
#     ],
#     SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
#     COUPON_CODE
#   )
# end

# CAMPAIGNS << flash_sale
###########################################




# #################################################################################
# # RUN CAMPAIGNS
# #################################################################################

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

# pass input cart to output.
Output.cart = Input.cart

