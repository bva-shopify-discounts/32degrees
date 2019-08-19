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
