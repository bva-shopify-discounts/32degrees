require_relative 'mock_data.rb'
require_relative './../line_items_discount_script.rb'
# First pull in definitions of a mock cart, product, variant, etc.
# Then pull in all code after pulled into the final discount script.

RSpec.describe 'CategorySelector', '#match?' do

  context 'with one tag to look for' do
    it 'returns true if the line item has a match' do
      @selector = CategorySelector.new(['tagged'])
      variant = Variant.new(['tagged'])
      price = 100.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq true
    end

    it 'returns false if the line item has no match' do
      @selector = CategorySelector.new(['tagged'])
      variant = Variant.new(['other'])
      price = 100.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq false
    end
  end

  context 'with multiple tags to look for' do
    it 'returns true if the line item has a match' do
      @selector = CategorySelector.new(['tagged', 'extra'])
      variant = Variant.new(['tagged'])
      price = 100.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq true
    end

    it 'returns false if the line item has no match' do
      @selector = CategorySelector.new(['tagged', 'extra'])
      variant = Variant.new(['other'])
      price = 100.to_money
      line_item = LineItem.new(price, variant)
      match = @selector.match?(line_item)
      expect(match).to eq false
    end
  end
end