# _Master Shopify Discount Scripts_

#### _A Ruby Project to Generate Shopify Discounts for the Script Editor_

## Description

This project gives you a few different types of discount 'Campaigns' that you can use to create discounts to run with the Shopify Script Editor.

## Setup/Installation Requirements

1. Make sure you have Ruby installed on your machine. If you are on a Mac, this comes automatically installed.
2. Make sure you have a commandline program, such as the Terminal installed that can use ruby. 
3. Using the commandline, navigate into the top level of this project folder. 

## Using This Project

#### Line Items Discounts (Used in the Cart)

1. Using the commandline, navigate into the top level of this project folder. 
2. Open the file `line_items/run/current_campaigns.rb` in a standard text editor such as Sublime Text, Atom or Notepad++.
4. Copy and paste the discount campaign template you would like to use from this readme into the file, customizing any values such as the message to display.
5. Save the current_campaigns.rb file. 
6. From the commandline, run `ruby build_line_items.rb`
7. This generates you a file called `line_items_discount_script.rb` in the top level of the project.
8. Go to the Shopify Admin, and click on Apps. Download the Script Editor if you haven't already and then click it.
9. Click the Line Items tab, and click 'Create New Script'. Select Blank Template. 
10. Copy and paste the entire contents of your generated `line_items_discount_script.rb` file into the new script, replacing any existing lines. Now you can preview, test and publish the script to your site.

#### Shipping Discounts (Used in the Shipping step)

Currently, there is only one type of shipping discount, so the `shipping_script.rb` file can be edited directly without having to build anything. Customizations explained below. 

## Line Item Discount Campaign Templates

Copy and paste as many of these into your `line_items/run/current_campaigns.rb` file where it says 'ADD CAMPAIGNS HERE'.

### Entire Site Campaign

***

#### Example: Entire site 25% off for summer discount event.

```
PERCENT = 25
MESSAGE = 'Summer discount event!'

CAMPAIGNS << EntireSiteCampaign.new(
  PercentageDiscount.new(PERCENT, MESSAGE)
)

```

Notes: 

* You only need to edit the values stored for `PERCENT` and `MESSAGE`. But copy and paste the whole block of code above into your current_campaigns.rb file, right below where it says ADD CAMPAIGNS HERE. 
* To use a coupon code to unlock a discount to the entire site, use a Category Campaign with no tags. Described below.

***

### Category Campaigns

***

#### Example: Take 20% off any products tagged as either 'New' OR 'Sale'.

```
TAGS = ['Sale', 'New']
PERCENT = 20
MESSAGE = "20% off select coffees!"

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```

Notes: 

* You can use any number of tags in the `TAGS` list, and the script will discount any items that match ANY of them. For example, `TAGS = ['Jackets', 'Gloves', 'Hats']` will discount any items that fit into one or more of those categories.

***

#### Example: 50% off items tagged with 'OUTERWEAR', that are ALSO under $20. 

```
TAGS = ['OUTERWEAR']
GREATER_OR_LESS_THAN = :less_than
CATEGORY_PRICE = 2000
PERCENT = 50
MESSAGE = "50% off Outerwear under $20!"


CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS),
    PriceSelector.new(GREATER_OR_LESS_THAN, CATEGORY_PRICE)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```

You can also separate out items with prices greater than a certain price by using `:greater_than` instead of `:less_than`

```
TAGS = ['OUTERWEAR']
GREATER_OR_LESS_THAN = :greater_than
CATEGORY_PRICE = 2000
PERCENT = 50
MESSAGE = "50% off Outerwear over $20!"


CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS),
    PriceSelector.new(GREATER_OR_LESS_THAN, CATEGORY_PRICE)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```


Notes: 

* This is an example of a discount with multiple conditions required. Both must be satisfied to qualify. Items must be tagged with Outerwear AND less thatn $20. 
* CATEGORY_PRICE is measured in cents. So $20 is equal to 2000. 

***

#### Example: Flat amount: Flash sale! All products tagged 'Flash' cost exactly $7.50.

```
TAGS = ['Flash']
FLAT_AMOUNT = 750
MESSAGE = 'Flash Sale!'

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS),
  ],
  SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
  COUPON_CODE
)
```

Notes: 

* Again, the flat amount is measured in cents. So $7.50 is equal to 750.

***

#### Example: Featured hats 10% off! All products tagged 'Hat' that are also tagged 'Featured' qualify.

```
TAG_OPTIONS_A = ['Hat']
TAG_OPTIONS_B = ['Featured']
PERCENT = 10
MESSAGE = 'Featured hats 10% off!'

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAG_OPTIONS_A),
    CategorySelector.new(TAG_OPTIONS_B)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```
***

### BOGO Campaign

***

#### Example: Buy two products tagged with 'BOGO' and the third is 50% off.

```
TAGS = ['BOGO']
MESSAGE = 'Buy 2 get 1 at 50% off!'
PAID_ITEM_COUNT = 2
DISCOUNTED_ITEM_COUNT = 1
PERCENT = 50

CAMPAIGNS << BOGOCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT),
  COUPON_CODE
)
```

***

### SPEND X and Save Campaign

***

#### Example: Get a flat amount once if over threshold

```
SPEND_THRESHOLD = 5000
DISCOUNT = SetFlatAmountDiscount.new(1000, 'Buy over $50 and get $10 back!')
MESSAGE = 'Buy over $50 and get $10 back'
ONCE = true

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)
```

***

#### Example: Get a flat amount back EVERY TIME you spend the threshold.

```
SPEND_THRESHOLD = 5000
DISCOUNT = SetFlatAmountDiscount.new(1000, 'For every $50 you spend, get $10 back!')
MESSAGE = 'For every $50 you spend, get $10 back.'
ONCE = false

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)
```

***

#### Example: Spend $50 and get 25% off.

```
SPEND_THRESHOLD = 5000
DISCOUNT = PercentageDiscount.new(25, '25% off!')
MESSAGE = '25% off for $50!'

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)
```

Notes: 

* We did not include a value for `TAGS` here so it would be site wide. See the next example if you want to restrict this discount to a particular tagged product.

#### Example: For every $20 you spend on sweaters, you get $5 back.

```
SPEND_THRESHOLD = 2000
DISCOUNT = SetFlatAmountDiscount.new(5000, 'For every $20 you spend on sweaters, get $5 back!')
MESSAGE = 'For every $20 you spend on sweaters, get $5 back!'
TAGS = ['SWEATER']

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)
```


Notes: 

* There are two kinds of flat rate discounts - those applied once, and those applied repeatedly every time the threshold is exceeded. Which of these options is used depends on the ONCE variable.
* Percent discounts are always only applied only once since that is more standard.

***

### Quantity Tier Campaign

***

#### Example: The more sweaters you buy, the cheaper they are!

```
TAGS = ['SWEATER']
DISCOUNTS_BY_QUANTITY = {
  40 => SetFlatAmountDiscount.new(100, 'Buy 40 for $1!'),
  30 => SetFlatAmountDiscount.new(200, 'Buy 30 for $2!'),
  20 => SetFlatAmountDiscount.new(300, 'Buy 20 for $3!'),
  10 => SetFlatAmountDiscount.new(400, 'Buy 10 for $4!'),
}

CAMPAIGNS << QuantityTierCampaign.new(
  DISCOUNTS_BY_QUANTITY,
  [
    CategorySelector.new(TAGS),
  ],
  COUPON_CODE
)
```

Notes: 

* This is a flat rate example. Buy a particular quantity, and it is set to the given price. 
* Quantities in between tiers are rounded down. For example 15 sweaters are $4 each.

***

#### Example: Buy sweaters and save up to 50%!

```
TAGS = ['SWEATER']
DISCOUNTS_BY_QUANTITY = {
  20 => PercentageDiscount.new(50, 'Buy 20, get 50% off!'),
  10 => PercentageDiscount.new(25, 'Buy 10, get 25% off!')
}

CAMPAIGNS << QuantityTierCampaign.new(
  DISCOUNTS_BY_QUANTITY,
  [
    CategorySelector.new(TAGS),
  ],
  COUPON_CODE
)
```

Notes: 

* This is a percentage example. Buy a particular quantity, and the order is discounted by the given percent.
* Quantities in between tiers are rounded down. For example 15 sweaters are 25% off.

***


### Using Coupon Codes

1. Create a coupon code in the shopify admin. For example: 'SUMMER'. 
2. Copy and paste one of the discount campaign templates into your `current_campaigns.rb` file like normal.
3. Add a new line, setting `COUPON_CODE` equal to the code you created in the shopify admin: `COUPON_CODE = 'SUMMER'`. Now this discount script will override the discount created in the admin, but it will only be activated if the customer enters the code. 

***

#### Example: Flat amount: Flash sale! All products tagged 'Flash' cost exactly $7.50.

```
# Copy and pasted campaign template from above
TAGS = ['Flash']
FLAT_AMOUNT = 750
MESSAGE = 'Flash Sale!'
# Adding only the following line to require a coupon code of 'SUMMER'
COUPON_CODE = 'SUMMER'


CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS),
  ],
  SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
  COUPON_CODE
)
```

Notes: 

* Any discount campaigns can use coupon codes (Except for `EntireSiteCampaign` because that function is covered by `CategoryCampaign` as shown in the next example). 
* COUPON_CODE is an optional setting to include on the campaign. If the variable `COUPON_CODE` is set, then the code will be required to activate the discount campaign.
* The coupon code must be in quotes
* The coupon code must be created in advance in the Shopify Admin under Discounts. 
* If it is used in a discount campaign in this script, this will override the behavior created in the admin. For example: If you create a discount code 'WINTER' in the admin that gives users 25% off the whole site, and then create a script discount that is instead a `QuantityTierCampaign` looking for the coupon code 'WINTER', then when the customer enters the code, the 25% off discount from the admin will not be applied. It will be overriden by the `QuantityTierCampaign` if the customer has bought a large enough quantity. But, if they don't qualify for the script discount `QuantityTierCampaign` then the 25% off discount created in the admin will be applied instead. **This allows the admin interface to coexist with this discount script.**

***

### More Coupon Code Examples for reference

***

#### Example: Enter the code 'SUMMER' to get 10% off on the whole site. 

```
# No tags means do not restrict the product set by tag.
TAGS = []
PERCENT = 10
MESSAGE = "SUMMER Sale 10% off everything!"
# Adding coupon code here:
COUPON_CODE = "SUMMER"

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```

***

#### Example: Enter the code "FALL" to unlock BOGO on all Jackets.

```
TAGS = ['Jacket']
MESSAGE = 'Buy 1 get 1 free!'
PAID_ITEM_COUNT = 1
DISCOUNTED_ITEM_COUNT = 1
PERCENT = 100
COUPON_CODE = 'FALL'

CAMPAIGNS << BOGOCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT),
  COUPON_CODE
)


```

***

#### Example: (Flat amount with coupon) Enter the code "FLASH" to get all hats for $10.99. 

```
TAGS = ['Hat']
FLAT_AMOUNT = 1099
MESSAGE = 'Hat Flash sale!'
COUPON_CODE = 'FLASH'

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE),
  COUPON_CODE
)
```

***

#### Example: SpendXSave - Enter coupon TEN and every $10 you spend gets you $1 back!

```
# all products
TAGS = []
SPEND_THRESHOLD = 1000
DISCOUNT = SetFlatAmountDiscount.new(100, 'For every $10 you spend on sweaters, get $1 back!')
MESSAGE = 'For every $10 you spend on sweaters, get $1 back!'
COUPON_CODE = 'TEN'

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)
```

***


#### Example: Enter code 'COZY' and save up to 50% on sweaters!

```
TAGS = ['SWEATER']
DISCOUNTS_BY_QUANTITY = {
  20 => PercentageDiscount.new(50, 'Buy 20, get 50% off!'),
  10 => PercentageDiscount.new(25, 'Buy 10, get 25% off!')
}
COUPON_CODE = 'COZY'

CAMPAIGNS << QuantityTierCampaign.new(
  DISCOUNTS_BY_QUANTITY,
  [
    CategorySelector.new(TAGS),
  ],
  COUPON_CODE
)
```

***

### Using Multiple Discounts

* Discounts are applied in the order defined by `current_campaigns.rb`
* Be sure to call `reset_defaults` after each discount, like this: 

```

# Add each block of code copied from the above examples 
# Campaign 1: 
TAGS = []
SPEND_THRESHOLD = 1000
DISCOUNT = SetFlatAmountDiscount.new(100, 'For every $10 you spend on sweaters, get $1 back!')
MESSAGE = 'For every $10 you spend on sweaters, get $1 back!'
COUPON_CODE = 'TEN'

CAMPAIGNS << SPENDXSAVECampaign.new(
  SPEND_THRESHOLD,
  DISCOUNT,
  MESSAGE,
  TAGS,
  COUPON_CODE,
  ONCE
)

# add this line to reset before the next campaign, since we do not use a coupon code on the others:
reset_defaults

# Campaign 2:
TAGS = ['SWEATER']
DISCOUNTS_BY_QUANTITY = {
  40 => SetFlatAmountDiscount.new(100, 'Buy 40 for $1!'),
  30 => SetFlatAmountDiscount.new(200, 'Buy 30 for $2!'),
  20 => SetFlatAmountDiscount.new(300, 'Buy 20 for $3!'),
  10 => SetFlatAmountDiscount.new(400, 'Buy 10 for $4!'),
}

CAMPAIGNS << QuantityTierCampaign.new(
  DISCOUNTS_BY_QUANTITY,
  [
    CategorySelector.new(TAGS),
  ],
  COUPON_CODE
)

# add this line to reset before the next campaign
reset_defaults

# Campaign 3: 
TAGS = ['Sale', 'New']
PERCENT = 20
MESSAGE = "20% off select coffees!"

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAGS)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE),
  COUPON_CODE
)
```

* This allows us to reuse variable names like `COUPON_CODE` for simplicity when copying and pasting from this document, while only the using the settings we need. For example, if you do not define a coupon code on a discount campaign, then there is no code required to activate the discount. 

***

## Shipping Discount Campaign Templates

As stated above, there is currently only one type of shipping campaign. These are the available customizations that can be changed directly in the `shipping_script.rb` file.

```
SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail']
MIN_CART_TOTAL = 3200
DISCOUNT_SHIPPING_PERCENT = 25
DISCOUNT_SHIPPING_MESSAGE = "25% off for orders over $32!"
```

#### SHIPPING_RATES_TO_DISCOUNT

Add new shipping rates to discount by including their name in the SHIPPING_RATES_TO_DISCOUNT list. For example:

`SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail', 'Standard']`

Note: The name must exactly match what is seen in checkout.

#### MIN_CART_TOTAL

The total cost of the customer's cart must be greater than this number to qualify for the shipping discount. It is measured in cents. For example, to make it a $50 minimum, we would edit the line to say: 

`MIN_CART_TOTAL = Money.new(cents: 50_00)`

Note: The underscore is just a visual convenience for the decimal point. `50_00` is the same as `5000`.

#### DISCOUNT_SHIPPING_PERCENT

This defines how much each shipping rate is discounted. For example, to make shipping free, we would use a 100% discount.

`DISCOUNT_SHIPPING_PERCENT = 100`

#### DISCOUNT_SHIPPING_MESSAGE

This is the message to display in checkout if the user qualifies. For example: 

`DISCOUNT_SHIPPING_MESSAGE = 'Free Priority Mail Shipping!'`

After you have finished customizing the file, go into the Script Editor in the Shopify Admin and click on the Shipping tab instead of Line Items. Create a new script and copy the entire `shipping_script.rb` file that you have modified into the editor. Here you can test and publish your script.

## Specs

1. Using the commandline, navigate into the top level of this project folder. 
2. Run `bundle install`
3. Run `ruby build_line_items.rb`
4. Run `bin/rspec`

## Known Issues

Still writing some specs, and would like to do some cleanup for Rubocop standards. But that will have to wait until there are more available hours.

Otherwise, be aware of the following:

1. "Discount code requirements not met: Empty Cart"

This error will sometimes show up on line 1 of the Script Editor when you are editing your script. You can disregard it, this is a Shopify bug. Reload the page, re-paste in your code, and it will go away.

2. When running specs, make sure you have run `ruby build_line_items.rb` first as the master file is used in tests. 
3. The Shopify Script Editor has a character limit. This is the other reason for the ruby build script. It will remove all commented out lines from the generated file. 
4. Remember to always rerun `ruby build_line_items.rb` before copying and pasting `line_items_discount_script.rb` into the shopify admin if you make any changes in the project folder.

## Technologies Used

* Shopify
* Ruby
* RSpec
