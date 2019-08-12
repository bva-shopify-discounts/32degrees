# Discounts an item to a flat amount.
#
# Example
# -------
#   * Items tagged flash sale are $3.99
#
class SetFlatAmountDiscount

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
