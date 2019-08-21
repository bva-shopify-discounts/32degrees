# Category Selector
# Selects items by 1 or more tags.

class CategorySelector

  #    Array of strings that the selector will look for in the item tags.
  def initialize(category_tags = [])
    @category_tags = category_tags
  end

  def match?(line_item)
    # take each tag on the line item, and if any of them are included in the category tags return true.
    return true if @category_tags.empty?
    line_item.variant.product.tags.any?{ |tag| @category_tags.include?(tag) }
  end
end

# Usage:
# Select items tagged with "sale" or "new".
# CategorySelector.new(['sale', 'new'])
# CategorySelector.new(['featured'])
# CategorySelector.new([])

# CategorySelector takes 1 input
# 1) array of tags to look for on the given line_item. if any product tags match, return true.
