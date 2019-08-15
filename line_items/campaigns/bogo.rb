# BOGO FREE or X% OFF 
# Tagged products are discounted as buy a certain quantity and get X% off 
# To buy one get one free, you would say buy quantity = 1 and get X = 100% off.

class BOGOCampaign
  attr_reader :coupon_code

  def initialize(category_selectors, discount, partition, code = nil)
    @category_selectors = category_selectors
    @discount = discount
    @partition = partition
    # @code = code
    # @message = @discount.message
    @coupon_code = CouponCode.new(code, @discount.message) if code
  end

  def run(cart)
    # if @code != -1
    #   # if there is a code, check if there is one on the cart
    #   if cart.discount_code
    #     # return unless code matches. then run discount.
    #     return unless cart.discount_code.code == @code
    #     cart.discount_code.reject({ message: @message })
    #   else
    #     # code is required but is not in cart, return without running discount.
    #     return
    #   end
    # end
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