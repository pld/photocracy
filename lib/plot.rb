class Plot
  MAX_BIN = 35
  
  attr_reader :locations
  attr_reader :countries
  attr_reader :path
  attr_reader :visits

  def initialize(path)
    @path = path
    @locations = Constants::Config::Admin::LOCATIONS
    (@countries = locations.dup).shift
    @visits = Visit.all(:include => [:responses, :trackings, :items, { :prompt => :items }], :order => 'visits.created_at', :conditions => "(user_id NOT IN (#{User.admin_ids.join(',')}) OR user_id IS NULL) AND user_agent NOT LIKE '%bot%'")
  end

  def items
    questions = Question.all(:include => [:items, :groups])
    for question in questions
      stats = {}
      stats[@locations.first] = [
        Item.ratings_overall(question),
        Item.wins_overall(question)
      ]
      for country in countries
        stats[country] = [
          Item.ratings_for_country(question, country),
          Item.wins_for_country(question, country)
        ]
      end
      for item in question.items
        xtics = []
        count = -1
        data = stats.sort_by(&:first).inject([]) do |array, el|
          stat = el.last
          ratings = stat.first[item.id].to_f
          percent = ratings > 0 ? 100 * (stat.last[item.id] / ratings) : 0
          xtics << el.first
          array << [count += 1, percent, error(percent, ratings)]
        end.transpose
        GNUPlotter.plot({
          :file_name => "#{path}items/question_#{question.id}_item_#{item.id}",
          :title => "item #{item.id} win percent for '#{question.groups.first.name}'",
          :xlabel => 'country',
          :ylabel => 'win percent with error',
          :data => data,
          :size => [250, 250],
          :font_size => 10,
          :xtics => xtics,
          :xrange => [-1, data.first.length],
          :yrange => [0, 100],
          :ds => { :using => '1:2:3', :error_bars => 'errorbars' }
        })
      end
    end
  end

  def data
    locations.each do |location|
      current_visits = (location == 'All') ? visits : visits.reject do |visit|
        visit.ip_country_code != location
      end
      loc = location.downcase
      Param.data_store("#{loc}visits_to_voters", current_visits.partition { |visit| visit.trackings.any? do |tracking|
        tracking.controller == 'responses' && tracking.action == 'create'
      end }.map(&:length))
      Param.data_store("#{loc}visits_to_register", current_visits.partition { |visit| !visit.user.nil? }.map(&:length))
      Param.data_store("#{loc}visits_to_interact", current_visits.partition { |visit| visit.trackings.length > 3 }.map(&:length))
    end
  end

  def usage
    by_day_plots
    histogram_plots
    by_visitor_plots
    actions_plots
    last_item_plots
    skipped_item_plots
  end
  
  def trackings_plot(trackings, title, filename, log = true)
    options = {
      :file_name => "#{path}#{filename}",
      :title => title,
      :xlabel => "Action",
      :ylabel => "Hits",
      :data => trackings.last,
      :size => [900, 300],
      :font_size => 10,
      :xrange => [-1, trackings.last.length],
      :xtics => trackings.first
    }
    options.merge!(:logscale => 'y') if log
    GNUPlotter.plot(options)
  end

  def gather_trackings(visits = nil)
    visits ||= self.visits
    visits.map { |visit| visit.trackings.last }.compact
  end

  def split_actions_by_country
    countries.map do |country|
      split_by_action(gather_trackings(visits.select { |visit| visit.ip_country_code == country })).transpose
    end
  end

  def split_by_action(trackings)
    trackings.inject(Hash.new(0)) do |hash, tracking|
      case tracking.controller
      when 'responses'
        case tracking.action
        when 'new'
          hash['vote'] += 1
        when 'index'
          hash['recent winners'] += 1
        when 'create'
          hash['[vote]'] += 1
        end
      when 'items'
        case tracking.action
        when 'new'
          hash['upload'] += 1
        when 'index'
          hash['list photos'] += 1
        when 'show'
          hash['view photo'] += 1
        when 'create'
          hash['[upload]'] += 1
        when 'comment'
          hash['[comment]'] += 1
        end
      when 'sessions'
        case tracking.action
        when 'destroy'
          hash['[logout]'] += 1
        when 'new'
          hash['login'] += 1
        when 'create'
          hash['[login]'] += 1
        end
      when 'users'
        case tracking.action
        when 'new'
          hash['signup'] += 1
        when 'create'
          hash['[signup]'] += 1
        end
      when 'profiles'
        case tracking.action
        when 'show'
          hash['view profile'] += 1
        when 'new'
          hash['new profile'] += 1
        when 'edit'
          hash['edit profile'] += 1
        when 'create'
          hash['[create profile]'] += 1
        when 'update'
          hash['[update profile]'] += 1
        end
      end
      hash
    end.sort_by { |array| -array.last }
  end

  def freq_divided(trackings)
    trackings = split_by_action(trackings)
    [trackings[0, trackings.length/2].transpose, trackings[trackings.length/2, trackings.length - 1].transpose]
  end

  def by_day
    today = Time.now
    by_day_data = [{}, {}, {}]
    visits.reverse.each do |visit|
      while (visit.created_at < today - 1.day) do today -= 1.day end
      locations.each do |country|
        by_day_data[0][country] ||= Hash.new(0)
        by_day_data[1][country] ||= Hash.new(0)
        by_day_data[2][country] ||= Hash.new(0)
        if country == locations.first || visit.ip_country_code == country
          by_day_data[0][country][today] += 1
          by_day_data[1][country][today] += visit.responses.length
          by_day_data[2][country][today] += visit.items.length
        end
      end
    end
    by_day_data.zip(
      ["Visitors per Day", "Votes per Day", "Uploads per Day"],
      ['Visitors', 'Votes', 'Uploads']
    )
  end

  def by_day_plots
    by_day.each do |hash, subject, ylabel|
      locations.each do |country|
        data = hash[country].sort_by(&:first).transpose
        next if data.empty?
        title = "#{country} #{subject}"
        GNUPlotter.plot({
          :file_name => "#{path}#{title.dashed}",
          :title => title,
          :xlabel => "Days",
          :ylabel => ylabel,
          :data => data.last,
          :size => [800, 300],
          :font_size => 10,
          :xtics => data.first.sparse(20).map { |date| date && "#{date.mon}/#{date.mday}" }
        })
      end
    end
  end

  def by_visitor_plots
    locations.each do |country|
      data = country == locations.first ? visits : visits.reject { |visit| visit.ip_country_code != country }
      next if data.empty?
      dates = data.sparse(20).map { |visit| visit && "#{visit.created_at.mon}/#{visit.created_at.mday}" }
      [["Votes", 'responses'], ["Uploads", 'items'], ["Actions", 'trackings']].each do |group, method|
        title = group + ' per Visitor'
        cur_data = data.map { |visit| visit.send(method).length }
        [ ['Day of Visit', cur_data, dates], ['Visit', cur_data.sort_by { |el| -el }, ['']]
        ].each do |xlabel, data_set, xtics|
        GNUPlotter.plot({
          :file_name => "#{path}#{country.downcase}_#{title.dashed}_#{xlabel.dashed}",
          :title => title,
          :xlabel => xlabel,
          :ylabel => "#{group} (log scale)",
          :data => data_set,
          :size => [800, 300],
          :font_size => 10,
          :xrange => [0, data.length],
          :xtics => xtics,
          :logscale => 'y'
        })
      end
      end
    end
  end

  def visit_histograms(visits, method, increment, min = 0)
    histograms = {}
    visits_hash = locations.inject({}) do |hash, country|
      hash[country] = visits.dup
      histograms[country] = { min => hash[country].find_all { |visit|
        visit.send(method).length == min && visit_for_country?(country, visit)
      } }
      hash[country] -= histograms[country][min]
      histograms[country][min] = histograms[country][min].length
      hash
    end

    currents = locations.inject({}) { |hash, country| hash[country] = increment; hash }
    while !visits_hash[locations.first].flatten.empty? do
      locations.each do |country|
        histograms[country][currents[country]] = visits_hash[country].find_all do |visit|
          num_visits = visit.send(method).length
          num_visits > min && visit_for_country?(country, visit) && (currents[country] > MAX_BIN || num_visits <= currents[country])
        end
        visits_hash[country] -= histograms[country][currents[country]]
        histograms[country][currents[country]] = histograms[country][currents[country]].length
        currents[country] += increment
      end
    end
    histograms
  end

  def histogram_plots
    votes_bins = 1
    uploads_bins = 1
    actions_bins = 1
    [
      visit_histograms(visits, :responses, votes_bins),
      visit_histograms(visits, :items, uploads_bins),
      visit_histograms(visits, :trackings, actions_bins)
    ].zip(["Votes Histogram", "Uploads Histogram", "Actions Histogram"],
      ["Votes (#{votes_bins} per bin)", "Uploads (#{uploads_bins} per bin)", "Actions (#{actions_bins} per bin)"]
    ).each do |hash, subject, xlabel|
      locations.each do |country|
        data = hash[country].sort_by(&:first).transpose
        title = "#{country} #{subject}"
        GNUPlotter.plot({
          :file_name => "#{path}#{title.downcase.gsub(/ /, '_')}",
          :title => "#{title} (log scale)",
          :xlabel => xlabel,
          :ylabel => "Visits",
          :data => data.last,
          :size => [800, 300],
          :font_size => 10,
          :xtics => data.first.sparse(20),
          :logscale => 'y'
        })
      end
    end
  end

  def actions_plots
    locations.each do |country|
      data = country == locations.first ? visits : visits.reject { |visit| visit.ip_country_code != country }
      next if data.empty?
      freq_divided(data.map(&:trackings).flatten).zip([
        "Popular Hits per Action",
        "Unpopular Hits per Action"
      ], [true, false]).each do |trackings, subject, log|
        title = "#{country} #{subject}"
        trackings_plot(trackings, "#{title}#{' (log scale)' if log}", title.downcase.downcase.gsub(/ /, '_'), log) unless trackings.last.nil?
      end
    end

    data = split_actions_by_country.unshift(split_by_action(gather_trackings).transpose)
    data.zip(locations.map { |country| "#{country} Last Hits per Action" }).each do |trackings, title|
      trackings_plot(trackings, "#{title} (log scale)", title.downcase.gsub(/ /, '_'), true) unless trackings.last.nil?
    end
  end
  
  def last_item_plots
    locations.each do |country|
      last_visit_items = visits.inject(Hash.new(0)) do |lasts, visit|
        # ignore visits without any votes
        if (country == locations.first || country == visit.ip_country_code) && visit.trackings.any? { |tracking| tracking.action == 'create' }
          visit.prompt && visit.prompt.items.map(&:id).each { |id| lasts[id] += 1 }
        end
        lasts
      end.reject { |last| last.last <= 1 }.sort_by(&:last).transpose
      store_items(:last, last_visit_items.transpose) if country == locations.first
      GNUPlotter.plot({
        :file_name => "#{path}#{country.downcase}_last_visit_items",
        :title => "#{country} Last Visit Items (minimum last item twice)",
        :xlabel => "Item",
        :ylabel => "Times Last Seen",
        :data => last_visit_items.last,
        :size => [900, 300],
        :font_size => 10,
        :xrange => [0, last_visit_items.last.length],
        :yrange => [0, last_visit_items.last.max + 1]
      }) unless last_visit_items.empty?
    end
  end
  
  def skipped_item_plots
    locations.each do |country|
      skipped_items = Response.all(:include => [:visit, :items, { :prompt => :items }], :conditions => 'items_responses.item_id IS NULL').inject(Hash.new(0)) do |skipped, response|
        response.prompt.items.map(&:id).each { |id| skipped[id] += 1 } if country == locations.first || country == response.visit.ip_country_code
        skipped
      end.reject { |skip| skip.last <= 1 }.sort_by(&:last).transpose
      store_items(:skipped, skipped_items.transpose) if country == locations.first
      GNUPlotter.plot({
        :file_name => "#{path}#{country.downcase}_skipped_items",
        :title => "#{country} Skipped Items (minimum skipped twice)",
        :xlabel => "Item",
        :ylabel => "Skip Count",
        :data => skipped_items.last,
        :size => [900, 300],
        :font_size => 10,
        :xrange => [0, skipped_items.last.length],
        :yrange => [0, skipped_items.last.max + 1]
      }) unless skipped_items.empty?
    end
  end

private
  def store_items(type, data)
    File.open("#{Constants::Config::Admin::Paths::DATA}#{type}.yml", 'w') { |file| file.print(YAML.dump(data)) }
  end

  def error(percent, ratings)
    ratings > 0 && (percent >= 0 || prob <= 100) ? Math.sqrt(percent * (100 - percent) / ratings) : 0
  end

  def visit_for_country?(country, visit)
    country == locations.first || visit.ip_country_code == country
  end
end