
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

class SetFlatAmountDiscount
  attr_reader :message, :amount
  # arguments:
  # amount: flat amount to set line item price to as class Money.
  # message: display with line item.
  def initialize(amount, message)
    if $ENV && $ENV['TEST_ENV']
      # tests have to use an older Money gem because the shopify scripts one isn't documented.
      @amount = Money.new(amount)
    else
      @amount = Money.new(cents: amount)
    end
    @message = message
  end

  def apply(line_item)
    # discount inactive if amount is nil.
    return if @amount.nil?
    line_item.change_line_price(@amount * line_item.quantity, message: @message)
  end
end

# End of discount_set_flat_amount.rb 


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


class CategorySelector

  #    Array of strings that the selector will look for in the item tags.
  def initialize(category_tags = [])
    @category_tags = category_tags
  end

  def match?(line_item)
    # take each tag on the line item, and if any of them are included in the category tags return true.
    return true if @category_tags.empty?
    line_item.variant.product.tags.any?{ |tag| @category_tags.include?(tag) }
  end
end



# End of selector_category.rb 


class PriceSelector

  def initialize(condition, price)
    if $ENV && $ENV['TEST_ENV']
      # tests have to use an older Money gem because the shopify scripts one isn't documented.
      @price = Money.new(price)
    else
      @price = Money.new(cents: price)
    end
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




# End of bogo.rb 

 
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



# End of category.rb 


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




# End of entire_site.rb 


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




# End of quantity_tier.rb 


class SPENDXSAVECampaign
  attr_reader :coupon_code

  def initialize(spend_threshold, discount, discount_tags = [], code = nil, once = false)
    @spend_threshold = spend_threshold
    @discount = discount
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
      @category_selector = CategorySelector.new(@discount_tags)
      if @category_selector.match?(line_item)
        total_cart_price += line_item.line_price.cents
      end
    end
    
    return if eligible_items.empty? || total_cart_price < @spend_threshold

    case @discount.class.to_s
    when 'PercentageDiscount'
      eligible_items.each do |line_item|
        @discount.apply(line_item)
      end
    when 'SetFlatAmountDiscount'
      if @once
        # buy $50 get $10 back, but it does not compound. just distribute over items once.
        total_discount = Decimal.new(@discount.amount.cents)
      else
        # Distribute the total discount across the products propotional to their price
        # calculate total_discount based on the cart price and how much it exceeds the threshold.
        times_to_apply = (total_cart_price/@spend_threshold).floor
        amount_to_apply = Decimal.new(@discount.amount.cents)
        total_discount = times_to_apply * amount_to_apply
      end
      remainder = Decimal.new(0)
      eligible_items.each do |line_item|
        # price of line_item including quantity
        price = line_item.line_price.cents
        # how much of the total cart price is it? we distribute the total_discount evenly.
        proportion =  Decimal.new(price / total_cart_price)
        # multiply total_discount by proportion for each item and add remainder (initially is 0). 
        discount_float = (total_discount * proportion) + remainder
        # round to nearest.
        discount = discount_float.round
        # get remainder to pass to next
        remainder =  discount_float - discount
        # set price to current - calculated discount
        line_item.change_line_price(line_item.line_price - Money.new(cents: discount), message: @discount.message) unless discount == 0
      end
    else
      return
    end
  end
end



# End of spend_x_save.rb 



CAMPAIGNS = []
















CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart


# End of current_campaigns.rb 

