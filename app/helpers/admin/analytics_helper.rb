module Admin::AnalyticsHelper
  def plot_selects(group, options)
    country_plot_select(group) + stat_select(group, options && cap_options(options)) +
    " <strong>#{group.humanize}</strong> " + (group == 'per_visitor' ? "ordered by #{order_select(group)}" : '')
  end

  def country_plot_select(group = '')
    select_tag "country_#{group}", country_options, :onchange => "Plot.select('#{group}');"
  end

  def stat_select(group, options = nil)
    options ||= cap_options(stat_types)
    select_tag "stat_#{group}", options, :onchange => "Plot.select('#{group}');"
  end

  def order_select(group)
    select_tag "order_#{group}", cap_options(orders(group)), :onchange => "Plot.select('#{group}');"
  end

  def country_options
    options_for_select(groups_for_select { |q| q.groups.first.code.downcase }.unshift([t('form.all_countries'), 'all']))
  end

  def cap_options(options)
    options_for_select(options.map(&:humanize).zip(options))
  end

  def show_all_firsts
    javascript_tag("$([$('#all_visitors_per_day'), $('#all_votes_histogram'),
      $('#all_votes_per_visitor_day_of_visit'), $('#all_popular_hits_per_action')]).showAll()")
  end

  def orders(group)
    group == 'per_visitor' ? ['day_of_visit', 'visit'] : ['']
  end

  def stat_types; ['votes', 'actions', 'uploads'] end
  def stat_types_per_day; ['visitors', 'votes', 'uploads'] end
  def stat_types_per_action; ['popular_hits', 'unpopular_hits', 'last_hits'] end
  def stat_types_items; ['last_visit', 'skipped'] end
end
