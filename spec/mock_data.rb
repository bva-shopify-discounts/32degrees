require 'money'
require 'pry'
$ENV = {}
$ENV['TEST_ENV'] = 'true'

class Product
  attr_accessor :tags
  def initialize(tags = ['tagged'])
    @tags = tags
  end
end

class Variant
  attr_accessor :product
  def initialize(tags = ['tagged'])
    @product = Product.new(tags)
  end
end

class LineItem
  attr_accessor :line_price, :quantity, :original_line_price, :line_price_was, :variant
  def initialize(line_price, variant, quantity = 1)
    @line_price, @original_line_price, @line_price_was = line_price
    @quantity = quantity
    @variant = variant
  end

  def change_line_price(new_line_price, message = 'test')
    @line_price = new_line_price
  end

end

class Cart
  attr_accessor :line_items, :discount_code
  def initialize(line_items = [], discount_code = nil)
    @line_items = line_items
    @discount_code = discount_code
  end
end

class Output
  attr_accessor :cart
  def initialize(cart = Cart.new)
    @cart = cart
  end
end

class Input
  attr_accessor :cart
  def initialize(cart = Cart.new)
    @cart = cart
  end
end

Output = Output.new
Input = Input.new