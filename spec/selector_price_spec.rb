require_relative 'mock_data.rb'
require_relative './../line_items_discount_script.rb'
require 'pry'
# First pull in definitions of a mock cart, product, variant, etc.
# Then pull in all code after pulled into the final discount script.

RSpec.describe 'PriceSelector', '#match?' do

  context 'when looking for items greater than given price' do
    it 'returns true if price is greater than selector price' do
      @selector = PriceSelector.new(:greater_than, 999.to_money)
      variant = Variant.new
      price = 1000.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq true
    end

    it 'returns false if price is less than selector price' do
      @selector = PriceSelector.new(:greater_than, 1000.to_money)
      variant = Variant.new
      price = 999.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq false
    end
  end

  context 'when looking for items less than given price' do
    it 'returns true if price is less than selector price' do
      @selector = PriceSelector.new(:less_than, 1000.to_money)
      variant = Variant.new
      price = 999.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq true
    end

    it 'returns false if price is greater than selector price' do
      @selector = PriceSelector.new(:less_than, 999.to_money)
      variant = Variant.new
      price = 1000.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq false
    end
  end
end