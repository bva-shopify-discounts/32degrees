
# _Master Shopify Discount Scripts_

#### _A Ruby Project to Generate Discounts for the Shopify Script Editor_

## Description

This project gives you a few different types of discount 'Campaigns' that you can use to create discounts to run with the Shopify Script Editor.

## Setup/Installation Requirements

1. Make sure you have Ruby installed on your machine. If you are on a Mac, this comes automatically installed.
2. Make sure you have a command line program, such as the Terminal installed that can use ruby.

## Using This Project

#### Line Items Discounts (Used in the Cart)

1. Using the command line, navigate into the top level of this project folder. 
2. Open the file `line_items/run/current_campaigns.rb` in a text editor such as Sublime Text, Atom or Notepad++.
4. Copy and paste the discount campaign template you would like to use from this readme into the file, customizing any values such as the message to display.
5. Save the `current_campaigns.rb` file in its current folder. 
6. From the command line, run `ruby build_line_items.rb`
7. This generates a file called `line_items_discount_script.rb` in the top level of the project.
8. Go to the Shopify Admin, and click on Apps. Download the Script Editor if you haven't already and then click it.
9. Click the `Line Items` tab, and click 'Create New Script'. Select Blank Template. 
10. Copy and paste the entire contents of your generated `line_items_discount_script.rb` file into the new script, replacing any existing lines. Now you can preview, test and publish the script to your site.

#### Shipping Discounts (Used in the Shipping step)

Currently, there is only one type of shipping discount, so the `shipping_discount_script.rb` file can be edited directly in the top level of the project folder without having to build anything. Customizations explained for both types of script below. 

## Line Item Discount Campaign Templates

* Copy and paste any of these into your `line_items/run/current_campaigns.rb` file in the space after it says `ADD CAMPAIGNS HERE`.
* Each campaign is initialized in a function, which you can name after the discount you're creating. For examples:

```
def name_of_my_campaign

# Discount settings go here.
# Then we create the discount campaign and return it.

end

# Then we add the new campaign into the global CAMPAIGNS list. 

CAMPAIGNS << name_of_my_campaign
```

* To use multiple campaigns, you would add several functions. 
* Add them to `CAMPAIGNS` in the order you'd like them to run.

```
def flash_sale_swimwear
  # Code here
end

def buy_1_jacket_get_1_free
  # Code here
end

# Add both campaigns so that the flash sale is applied first, and then the BOGO.
CAMPAIGNS << flash_sale_swimwear
CAMPAIGNS << buy_1_jacket_get_1_free

```

***

### Entire Site Campaign

***

#### Example: Entire site 25% off for 4th of July.

```
def july_4_sale
  PERCENT = 25
  MESSAGE = '4th of July Sale!'

  EntireSiteCampaign.new(
    PercentageDiscount.new(PERCENT, MESSAGE)
  )
end

CAMPAIGNS << july_4_sale

```

Notes: 

* You only need to edit the values stored for `PERCENT` and `MESSAGE`. But copy and paste the whole block of code above into your `current_campaigns.rb` file, right below where it says `ADD CAMPAIGNS HERE`. 
* To use a coupon code to unlock a discount to the entire site, use a Category Campaign with no tags. Described below under Category Campaigns.
* Don't forget to add your discount to the `CAMPAIGNS` list.

```

```

***

### Category Campaigns

***

#### Example: Take 20% off any products tagged as either 'New' OR 'Sale'.

```
def new_or_sale_tags_20_percent_off
  TAGS = ['Sale', 'New']
  PERCENT = 20
  MESSAGE = "20% off select coffees!"
  COUPON_CODE = nil

  CategoryCampaign.new(
    [
      CategorySelector.new(TAGS)
    ],
    PercentageDiscount.new(PERCENT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << new_or_sale_tags_20_percent_off
```

Notes: 

* You can use any number of tags in the `TAGS` list, and the script will discount items that match ANY of them. For example, `TAGS = ['Jackets', 'Gloves', 'Hats']` will discount Jackets, Gloves, and Hats - any items that fit into one or more of those categories.

***

#### Example: Price Selector - 50% off items tagged with 'OUTERWEAR', that are ALSO under $20. 

```
def half_off_outerwear_under_20
  TAGS = ['OUTERWEAR']
  GREATER_OR_LESS_THAN = :less_than
  CATEGORY_PRICE = 2000
  PERCENT = 50
  MESSAGE = "50% off Outerwear under $20!"
  COUPON_CODE = nil


  CategoryCampaign.new(
    [
      CategorySelector.new(TAGS),
      PriceSelector.new(GREATER_OR_LESS_THAN, CATEGORY_PRICE)
    ],
    PercentageDiscount.new(PERCENT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << half_off_outerwear_under_20
```

* You can also separate out items with prices greater than a certain price by using `:greater_than` instead of `:less_than`

```
def half_off_outerwear_over_20
  TAGS = ['OUTERWEAR']
  GREATER_OR_LESS_THAN = :greater_than
  CATEGORY_PRICE = 2000
  PERCENT = 50
  MESSAGE = "50% off Outerwear over $20!"
  COUPON_CODE = nil


  CategoryCampaign.new(
    [
      CategorySelector.new(TAGS),
      PriceSelector.new(GREATER_OR_LESS_THAN, CATEGORY_PRICE)
    ],
    PercentageDiscount.new(PERCENT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << half_off_outerwear_over_20
```


Notes: 

* This is an example of a discount with multiple conditions required. BOTH must be satisfied to qualify. Items must be tagged with Outerwear AND less thatn $20. 
* CATEGORY_PRICE is measured in cents. So $20 is equal to 2000. 

***

#### Example: Flat amount - Flash sale! All products tagged 'Flash' cost exactly $7.50.

```
def flash_sale
  TAGS = ['Flash']
  FLAT_AMOUNT = 750
  MESSAGE = 'Flash Sale!'
  COUPON_CODE = nil

  CategoryCampaign.new(
    [
      CategorySelector.new(TAGS),
    ],
    SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << flash_sale
```

Notes: 

* Again, the flat amount is measured in cents. So $7.50 is equal to 750.

***



#### Example: Using Coupon Codes

1. Create a coupon code in the shopify admin. For example: 'SUMMER'. 
2. Copy and paste one of the discount campaign templates into your `current_campaigns.rb` file like normal.
3. Add a new line, setting `COUPON_CODE` equal to the code you created in the shopify admin: `COUPON_CODE = 'SUMMER'`. Now this discount script will override the discount created in the admin, but it will only be activated if the customer enters the code. 

***

#### Example: Flat amount: Summer Flash sale! All products tagged 'Flash' cost exactly $7.50 with coupon code 'SUMMER'.

```
def flash_sale_with_coupon
  TAGS = ['Flash']
  FLAT_AMOUNT = 750
  MESSAGE = 'Flash Sale!'
  # Changing only the following line to require a coupon code of 'SUMMER'
  COUPON_CODE = 'SUMMER'

  CategoryCampaign.new(
    [
      CategorySelector.new(TAGS),
    ],
    SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << flash_sale_with_coupon

```

Notes: 

* Any discount campaign type can use coupon codes (Except for `EntireSiteCampaign` because that functionality is covered by `CategoryCampaign` if you use no tags.
* `COUPON_CODE` is an optional setting to include on the campaign. If the variable `COUPON_CODE` is set, then the code will be required to activate the discount campaign.
* The coupon code must be in quotes.
* The coupon code must be created in advance in the Shopify Admin under Discounts. 
* This script will override the discount code behavior created in the admin, so your settings there won't matter. This allows simpler admin interface discounts to coexist with this discount script.

For example: 
You create a discount code 'WINTER' in the admin that gives users 25% off the whole site. 
Then you create a script discount here - let's say a category campaign - winter coats 50% off. 
You also set this discount to look for the coupon code 'WINTER'. 
When the customer enters 'WINTER', if they have a winter coat in their cart, it will be 50% off. 
If they don't qualify (not buying a winter coat), then the site wide 25% off discount still does not get applied. 
If the site wide discount created in the admin is assigned a different coupon code, then both can work alongside each other.

***

#### Example: Featured hats 10% off! All products tagged 'Hat' that are also tagged 'Featured' qualify.

```
def ten_percent_off_featured_hats
  TAG_OPTIONS_A = ['Hat']
  TAG_OPTIONS_B = ['Featured']
  PERCENT = 10
  MESSAGE = 'Featured hats 10% off!'
  COUPON_CODE = nil

  CategoryCampaign.new(
    [
      CategorySelector.new(TAG_OPTIONS_A),
      CategorySelector.new(TAG_OPTIONS_B)
    ],
    PercentageDiscount.new(PERCENT, MESSAGE),
    COUPON_CODE
  )
end

CAMPAIGNS << ten_percent_off_featured_hats
```

Notes: 

*  This discount requires both tags to be true instead of either to qualify. The item must be not only tagged as a 'hat', but tagged as a 'featured' hat.

***

### BOGO Campaign

***

#### Example: Buy two products tagged with 'BOGO' and the third is 50% off.

```
def buy_2_get_1
  TAGS = ['BOGO']
  MESSAGE = 'Buy 2 get 1 at 50% off!'
  PAID_ITEM_COUNT = 2
  DISCOUNTED_ITEM_COUNT = 1
  PERCENT = 50
  COUPON_CODE = nil

  BOGOCampaign.new(
    [
      CategorySelector.new(TAGS)
    ],
    PercentageDiscount.new(PERCENT, MESSAGE),
    BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT),
    COUPON_CODE
  )
end

CAMPAIGNS << buy_2_get_1
```

***

### SPEND X and Save Campaign

***

#### Example: Get a flat amount once if over threshold

```
def buy_50_bucks_get_10
  SPEND_THRESHOLD = 5000
  FLAT_AMOUNT = 1000
  MESSAGE = 'Buy over $50 and get $10 back!'
  TAGS = []
  COUPON_CODE = nil
  ONCE = true

  DISCOUNT = SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
  SPENDXSAVECampaign.new(
    SPEND_THRESHOLD,
    DISCOUNT,
    TAGS,
    COUPON_CODE,
    ONCE
  )
end

CAMPAIGNS << buy_50_bucks_get_10
```

Notes: 

* In this discount we are not using tags or a coupon code but we are setting `ONCE` to true. This means we don't get $10 for EVERY $50 we spend, we only get it ONCE. The next example sets it to false.
* We did not include a value for `TAGS` here because we want the discount site wide. There is an example further down with tags.

***

#### Example: Get a flat amount back EVERY TIME you spend the threshold.

```
def every_50_bucks_get_10
  SPEND_THRESHOLD = 5000
  FLAT_AMOUNT = 1000
  MESSAGE = 'Spend $50 and get $10 back!'
  TAGS = []
  COUPON_CODE = nil
  ONCE = false

  DISCOUNT = SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
  SPENDXSAVECampaign.new(
    SPEND_THRESHOLD,
    DISCOUNT,
    TAGS,
    COUPON_CODE,
    ONCE
  )
end

CAMPAIGNS << every_50_bucks_get_10
```

Notes:

* This example sets ONCE to false, so that the discount amount gets $10 larger with every $50 spent.

***

#### Example: Percent - Spend $50 and get 25% off.

```
def spend_50_get_25_percent_off
  SPEND_THRESHOLD = 5000
  PERCENT = 25
  MESSAGE = '25% off for $50!'
  TAGS = []
  COUPON_CODE = nil
  ONCE = nil

  DISCOUNT = PercentageDiscount.new(PERCENT, MESSAGE)
  SPENDXSAVECampaign.new(
    SPEND_THRESHOLD,
    DISCOUNT,
    TAGS,
    COUPON_CODE,
    ONCE
  )
end

CAMPAIGNS << spend_50_get_25_percent_off
```

Notes:

* Percent discounts are always only applied only once since that is more standard.

***

#### Example: Restrict products by tag - For every $20 you spend on sweaters, you get $5 back.

```
def each_20_on_sweaters_gets_5
  SPEND_THRESHOLD = 2000
  FLAT_AMOUNT = 500
  MESSAGE = 'For every $20 you spend on sweaters, get $5 back!'
  TAGS = ['SWEATER']
  COUPON_CODE = nil
  ONCE = false

  DISCOUNT = SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
  SPENDXSAVECampaign.new(
    SPEND_THRESHOLD,
    DISCOUNT,
    TAGS,
    COUPON_CODE,
    ONCE
  )
end

CAMPAIGNS << each_20_on_sweaters_gets_5
```


Notes: 

* There are two kinds of flat rate discounts - those applied once, and those applied repeatedly every time the threshold is exceeded. Which of these options is used depends on the ONCE variable.

***

### Quantity Tier Campaign

***

#### Example: The more sweaters you buy, the cheaper they are!

```
def flat_amount_sweater_quantity
  TAGS = ['SWEATER']
  DISCOUNTS_BY_QUANTITY = {
    40 => SetFlatAmountDiscount.new(100, 'Buy 40 for $1!'),
    30 => SetFlatAmountDiscount.new(200, 'Buy 30 for $2!'),
    20 => SetFlatAmountDiscount.new(300, 'Buy 20 for $3!'),
    10 => SetFlatAmountDiscount.new(400, 'Buy 10 for $4!'),
  }
  COUPON_CODE = nil

  QuantityTierCampaign.new(
    DISCOUNTS_BY_QUANTITY,
    [
      CategorySelector.new(TAGS),
    ],
    COUPON_CODE
  )
end

CAMPAIGNS << flat_amount_sweater_quantity
```

Notes: 

* This is a flat rate example. Buy a particular quantity, and it is set to the given price. 
* Quantities in between tiers are rounded down. For example 15 sweaters are $4 each.

***

#### Example: Buy sweaters and save up to 50%!

```
def percent_off_for_sweater_quantity
  TAGS = ['SWEATER']
  DISCOUNTS_BY_QUANTITY = {
    20 => PercentageDiscount.new(50, 'Buy 20, get 50% off!'),
    10 => PercentageDiscount.new(25, 'Buy 10, get 25% off!')
  }
  COUPON_CODE = nil

  QuantityTierCampaign.new(
    DISCOUNTS_BY_QUANTITY,
    [
      CategorySelector.new(TAGS),
    ],
    COUPON_CODE
  )
end

CAMPAIGNS << percent_off_for_sweater_quantity
```

Notes: 

* This is a percentage example. Buy a particular quantity, and the order is discounted by the given percent.
* Quantities in between tiers are rounded down. For example 15 sweaters are 25% off.

***

## Shipping Discount Campaign Templates

There is currently only a need for one type of shipping campaign, so there is only one file to edit and no build command to run for the shipping discounts. 

The customer can get a percent off certain shipping methods if their order is over a certain price total. 

These are the available customizations that can be changed directly in the `shipping_discount_script.rb` file and then copied and pasted into the Shopify Script Editor under the Shipping tab.

#### Example: Get 25% off on orders over $32 if they ship with Priority Mail.

```
SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail']
MIN_CART_TOTAL = 3200
DISCOUNT_SHIPPING_PERCENT = 25
DISCOUNT_SHIPPING_MESSAGE = "25% off for orders over $32!"
```

* `SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail', 'Standard']`

Add new shipping rates to discount by including their name in the SHIPPING_RATES_TO_DISCOUNT list. For example:
Note: The name must exactly match what is seen in checkout.

* `MIN_CART_TOTAL = 3200`

The total cost of the customer's cart must be greater than this number to qualify for the shipping discount. It is measured in cents. For example, to make it a $50 minimum, we would edit the line to say: `MIN_CART_TOTAL = 5000`

* `DISCOUNT_SHIPPING_PERCENT = 100`

This defines how much each shipping rate is discounted. For example, to make shipping free, we would use a 100% discount.

* `DISCOUNT_SHIPPING_MESSAGE = 'Free Priority Mail Shipping!'`

This is the message to display in checkout if the user qualifies. 

After you have finished customizing the file, go into the Script Editor in the Shopify Admin and click on the Shipping tab instead of Line Items. Create a new script and copy the entire `shipping_discount_script.rb` file that you have modified into the editor. Here you can test and publish your script.

## Specs

1. Using the commandline, navigate into the top level of this project folder. 
2. Run `bundle install`
3. Run `ruby build_line_items.rb`
4. Run `bin/rspec`

## Known Issues

Would like to expand test coverage and do some updates for Rubocop standards. But that will have to wait until there are more available hours.

Otherwise, be aware of the following:

1. `Discount code requirements not met: Empty Cart`

This error will sometimes show up on line 1 of the Script Editor when you are editing your script. You can disregard it, this is a Shopify bug. Reload the page, re-paste in your code, and it will go away.

2. When running specs, make sure you have run `ruby build_line_items.rb` first as the master file is used in tests. 
3. The Shopify Script Editor has a character limit. This is the other reason for the ruby build script. It will remove all commented out lines from the generated file. 
4. Remember to always rerun `ruby build_line_items.rb` before copying and pasting `line_items_discount_script.rb` into the shopify admin if you make any changes in the project folder.

## Technologies Used

* Shopify
* Ruby
* RSpec
