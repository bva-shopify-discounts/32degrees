# Apply a percentage discount to a line item.
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

end
