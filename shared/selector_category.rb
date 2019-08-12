# Selects items by 1 or more tags.
#
# Example
# -------
#   * Items tagged with "sale" or "new".
#   CategorySelector.new(['sale', 'new'])
#   CategorySelector.new(['featured'])
#
#
class CategorySelector

  #    Array of strings that the selector will look for in the item tags.
  def initialize(category_tags = [])
    @category_tags = category_tags
  end

  def match?(line_item)
    # take each tag on the line item, and if any of them are included in the category tags return true.
    line_item.variant.product.tags.any?{ |tag| @category_tags.include?(tag) }
  end
end

