module ItemsHelper
  def country_select_tag
      select_tag 'country', countries, :onchange => "Back.no();Message.notify('#{t('actions.loading')}');#{remote_function(:url => { :action => :country }, :with => "#{question_with}+#{option_with_('country', '&')}")}"
  end

  def question_select_tag
    select_tag 'question', options_for_select(groups_for_select, @active_question_id), :onchange => "Back.no();$('.question').each(function(el) { $(this).hide() });$('#items_' + this.value).show();"
  end

  def sort_select_tag
    select_tag 'sort', order_options, :onchange => remote_function(:url => { :action => :list }, :with => "#{question_with}+#{option_with_('sort', '&')}")
  end

  def order_options
    options_for_select([ [t('items.order.date'), 'new'],
      [t('items.order.score'), 'score'],
      [t('items.order.percent'), 'percent']
    ], 'percent')
  end

  def order_link(type, question_id, name = nil)
    active = ' active' if type == 'rank'
    link_to_remote(name || t("items.order.#{type}"), :url => { :action => :list, :order => type }, :with => question_with, :html => { :id => "#{type}_#{question_id}", :class => "order#{active}" })
  end

  def upload_links(type)
    ['upload', 'flickr', 'url'].map do |el|
      options = type == el ? { :class => 'active' } : {}
      build_upload_link(el, options)
    end.join(' ')
  end

  def item_display(item, thumb = :compare, options = {})
    return unless item
    if thumb == :thumb && options[:height] && item.attachment
      img = item.attachment.thumbnails.find_by_thumbnail('thumb')
      options.delete(:height) if img.height < options[:height]
    end
    path = item.attachment.public_filename(thumb)
    # we sometime get a bad path, fix it
    path = path[path =~ /\/system/, path.length] unless path[0,7] == "/system"
    item.attachment ? image_tag(path, options.merge(:title => '')) : item.description
  end

  def fast_link_to_item(image_name, item_id, width)
    fast_link(rounded(image_tag(image_name, {:width => width, :title => ''})), "items/#{item_id}")
  end

  def link_to_item(item, size = :thumb, options = {})
    link_to(rounded(item_display(item, size, options)), item)
  end

  def type_instructions(type)
    t("item.submit.instructions.#{type}")
  end

  def type_style(type)
    @item_type != type && 'display:none'
  end

  def pic_for_country(country_code)
    image_tag((country_code && !country_code.empty? && "#{country_code.downcase}.jpg") || "world.jpg")
  end

  def wins(item, question)
    (@country_code && !@country_code.empty?) ? item.wins_for_country(@country_code, question_id) : item.items_questions.find_by_question_id(question.id).wins
  end

  def ratings(item, question)
    if (@country_code && !@country_code.empty?)
      item.ratings_for_country(@country_code, question.id, false)
    else
      iq = item.items_questions.find_by_question_id(question.id)
      iq.wins + iq.losses
    end
  end

  def google_item_chart(item, question)
    percents = []
    country_names = @groups.map do |group|
      stat = Stat.get(item, group, question)
      percents << stat.win_percent.to_i
      "#{group.name} (#{stat.ratings})"
    end
    country_names.unshift("All (#{item.ratings(question.id)})")
    title = question.name.strip_tags.gsub(' ', '+')
    percents.unshift(item.win_percent(question.id).to_i)
    image_tag("http://chart.apis.google.com/chart?cht=bvs&chbh=60,40,10&chtt=#{title}&chxt=y&chd=t:#{percents.join(',')}&chs=420x300&chl=#{country_names.join('|')}")
  end

  def google_map_votes(item, question_id = nil)
    wins, losses = [], []
    options = {
      :select => "items_responses.item_id, responses.visit_id, ip_latitude, ip_longitude",
      :conditions => { :active => true },
      :joins => "INNER JOIN visits ON (visits.id=responses.visit_id) INNER JOIN items_responses ON (items_responses.response_id=responses.id) INNER JOIN items_prompts ON (items_prompts.item_id=#{item.id} AND responses.prompt_id=items_prompts.prompt_id)"
    }
    options[:joins] += " INNER JOIN prompts ON (responses.prompt_id=prompts.id AND prompts.question_id=#{question_id})" if question_id
    Response.all(options).each do |response|
      geo = [response.ip_latitude, response.ip_longitude]
      unless geo.any? { |pos| pos.nil? }
        geo = geo.join(',')
        if response.item_id.to_i == item.id
          wins << geo
        else
          losses << geo
        end
      end
    end
    wins = wins.length > 0 ? "[#{wins.join('],[')}]" : ''
    losses = losses.length > 0 ? "[#{losses.join('],[')}]" : ''
    javascript_tag("
      Google.map([#{wins}], [#{losses}], 'world_map');
      Google.map([#{wins}], [#{losses}], 'asia_map', [38,105, 3]);
      Google.map([#{wins}], [#{losses}], 'us_map', [42,-90, 3]);
    ")
  end

  private
    def countries_for_stats
      country_codes.dup.unshift('world')
    end

    def question_with
      option_with_('question')
    end

    def countries
      options_for_select(groups_for_select { |q| q.groups.first.code.upcase }.unshift([t('form.all_countries'), nil]), @country_code && @country_code.upcase)
    end

    def build_upload_link(name, options = nil)
      link_to_function(t("item.submit.#{name}"), "Item.changeType('#{name}', '#{type_instructions(name)}')", options.merge(:id => "#{name}_link"))
    end
end