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
  PercentageDiscount.new(PERCENT, MESSAGE)
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
  PercentageDiscount.new(PERCENT, MESSAGE)
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
  PercentageDiscount.new(PERCENT, MESSAGE)
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
  SetFlatAmountDiscount.new(FLAT_AMOUNT, MESSAGE)
)
```

Notes: 

* Again, the flat amount is measured in cents. So $7.50 is equal to 750.

***

#### Example: Featured hats 10% off! All products tagged 'Hat' that are also tagged 'Featured' qualify.

TAG_OPTIONS_A = ['Hat']
TAG_OPTIONS_B = ['Featured']
PERCENT = 10
MESSAGE = 'Featured hats 10% off!'

CAMPAIGNS << CategoryCampaign.new(
  [
    CategorySelector.new(TAG_OPTIONS_A),
    CategorySelector.new(TAG_OPTIONS_B)
  ],
  PercentageDiscount.new(PERCENT, MESSAGE)
)

***

### BOGO Campaign

***

#### Example: Buy two products tagged with 'BOGO' and the third is 50% off.

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
  BOGOPartitioner.new(PAID_ITEM_COUNT, DISCOUNTED_ITEM_COUNT)
)

***

### SPEND X and Save Campaign

***

***

### Quantity Tier Campaign

***

***

### Using Coupon Codes

***

***

## Shipping Discount Campaign Templates

As stated above, there is currently only one type of shipping campaign. These are the available customizations that can be changed directly in the `shipping_script.rb` file.

```
SHIPPING_RATES_TO_DISCOUNT = ['Priority Mail']
MIN_CART_TOTAL = Money.new(cents: 32_00)
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

## Technologies Used

* Shopify
* Ruby
* RSpec
