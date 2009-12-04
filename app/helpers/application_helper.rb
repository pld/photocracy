# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def fast_link(text, link, html_options='')
   %(<a href="#{ActionController::Base.relative_url_root}/#{link}" hmtl_options>#{text}</a>)
  end

  def joke_link(text, link)
    fast_link(text, "joke/#{link}", 'class="joke_link"')
  end

  def languages
    Constants::Locales::ALL.sort_by(&:last)
  end

  def attribution(item)
    (item.attribution && !item.attribution.empty?) ? item.attribution : t('items.anonymous')
  end

  def non_default_languages
    @controller.non_default_languages
  end

  def translations
    @controller.translations
  end

  def flag_link(obj, downcase = false)
    label = t('flag.h')
    label.downcase! if downcase
    link_to_function label, "$('#flag_#{obj.class == Item ? 'item' : 'comment'}_#{obj.id}').toggle()"
  end

  def share_this_tag
    ENV['RAILS_ENV'] == 'production' && javascript_tag('', :src => "http://w.sharethis.com/widget/?tabs=web%2Cpost%2Cemail&amp;charset=utf-8&amp;style=default&amp;publisher=d02fb4fa-f0d9-477c-934e-40e5b861eb0c")
  end

  def top_country_item(country, items, question)
    items.sort_by { |item| item.win_percent_for_country(country.upcase, question.id) }.last
  end

  def top_country_item_from_list(idx, items, win_percents)
    win_percents.sort_by { |key, value| value[idx] }.last.first
  end

  def nav_link(text, link)
    cmp = if(link.count('/') < 2)
      case link
      when '/about'
        '/home/index'
      when '/stats'
        '/home/stats'
      else
        "#{link}/index"
      end
    elsif (link =~ /responses\/\d*/)
      '/responses/show\d*'
    end
    if (cmp || link) =~ /\/#{params[:controller]}\/#{params[:action]}/
      link_to text, link, { :class => 'active' }
    else
      link_to text, link
    end
  end

  def notify(page, message, delay = Constants::Config::FLASH_DELAY)
    page << "Message.notify('#{escape_javascript(message)}', #{delay});"
  end

  def error(page, message, delay = Constants::Config::FLASH_DELAY)
    page << "Message.error('#{escape_javascript(message)}', #{delay});"
  end

  def country_codes
    Constants::Countries::CODES
  end

  def option_with_(id, append = nil)
    "'#{append}#{id}_id=' + $('##{id}').attr('options')[$('##{id}').attr('selectedIndex')].value"
  end

  def questions_for_select(method = 'id')
    Question.all.map { |q| [sanitize(q.for_locale(I18n.locale), :tags => []), q.send(method)] }
  end

  def question_options_for_select(method = 'id')
    options_for_select(questions_for_select(method), @question && @question.id)
  end

  def groups_for_select(method = 'id', &blk)
    Question.all.map { |q| [sanitize(q.groups.first.for_locale(I18n.locale), :tags => []), (blk.nil? ? q.send(method) : yield(q)) ] }
  end

  def highlightable(item)
    onmouseover = "$$('.item_#{item.id}').each(function(s) { s.setStyle({
      background: '#{Constants::Display::HIGHLIGHT}'
    })})"
    onmouseout = "$$('.item_#{item.id}').each(function(s) { s.setStyle({
      background: '#{Constants::Display::BORDER}'
    })})"
    rounded(item_display(item, :compare, :onmouseover => onmouseover, :onmouseout => onmouseout), "item_#{item.id}")
  end

  def rounded(content, classes = nil)
    render(:partial => 'shared/rounded', :locals => { :classes => classes && " #{classes}", :content => content })
  end

  def analytics
    render(:partial => 'shared/analytics') if Constants::Config::GOOGLE_ANALYTICS
  end

  def field_options
    { :maxlength => Constants::VARCHAR, :size => 35 }
  end

  def flag_form_tag(suffix = '', &blk)
    if @prompt
      remote_form_for(:flag, :url => { :action => :flag, :question_id => @question && @question.id }, :condition => "Item.validFlag('#{suffix}')") { |f| blk.call(f) }
    else
      form_for(:flag, :url => { :action => :flag, :question_id => @question && @question.id }) { |f| blk.call(f) }
    end
  end

  def google_control_script
    if PRODUCTION && I18n.locale == 'en'
      <<JS
        <script>
        function utmx_section(){}function utmx(){}
        (function(){var k='2654905852',d=document,l=d.location,c=d.cookie;function f(n){
        if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
        length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
        d.write('<sc'+'ript src="'+
        'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
        +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
        +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
        '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
        </script>
JS
    end
  end

  def google_tracking_script
    if PRODUCTION && I18n.locale == 'en'
      <<JS
        <script type="text/javascript">
        if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
        (document.location.protocol=='https:'?'s://ssl':'://www')+
        '.google-analytics.com/ga.js"></sc'+'ript>')</script>
        <script type="text/javascript">
        try {
        var pageTracker=_gat._getTracker("UA-8796271-1");
        pageTracker._trackPageview("/2654905852/test");
        }catch(err){}</script>
JS
    end
  end

  def google_optimize(label, text)
    PRODUCTION && I18n.locale == 'en' ? "<script>utmx_section(\"#{label}\")</script>#{text}</noscript>" : text
  end
end
