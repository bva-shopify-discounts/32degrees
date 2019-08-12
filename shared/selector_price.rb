# Selects items in the cart that are greater than (or less than) a price.
#
# Example
# -------
#   * Items with a price greater than $5
#   PriceSelector.new(:greater_than, Money.new(cents: 5_00))
#
class PriceSelector

  def initialize(condition, price)
    @price = price
    @condition = condition
  end

  def match?(line_item)
    case @condition
    when :greater_than
      line_item.variant.price > @price
    when :lower_than
      line_item.variant.price < @price
    end
  end
end

