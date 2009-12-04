module Admin::ItemsHelper
  def tag_list_for_item_groups(item, groups)
    groups.map do |g|
      tags = item.tag_list_on(g.code.to_sym)
      tags.empty? ? nil: "#{g.name}: #{tags}"
    end.compact.join('<br/>')
  end
end