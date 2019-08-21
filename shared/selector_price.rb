# Price Selector
# Selects items in the cart that are greater than (or less than) a price.

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

# Usage:
# Items with a price greater than $5
# PriceSelector.new(:greater_than, 500)

# PriceSelector takes 2 inputs.
# 1) condition - symbol - either :greater_than or :less_than
# 2) price - integer - the number of cents to compare the line item price.
