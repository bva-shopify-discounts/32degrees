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
