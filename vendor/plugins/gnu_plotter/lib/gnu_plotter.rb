class GNUPlotter
  class << self
    include Utilities

    # Default font face.
#    FONT = "/usr/share/fonts/truetype/Arial.ttf"
     FONT = "/Library/Fonts/Arial.ttf"
    # Default font size.
    FONT_SIZE = 28
    # Default minimum jitter font size.
    FS_MIN = 11
    # Default maximum jitter font size.
    FS_MAX = 48
    # Default location jitter max.
    JITTER_MAX = 0.2
    # Default location jitter if percent differrence less than this value
    JITTER_RANGE = 0.5
    # Default plot width.
    WIDTH = 800
    # Default plot height.
    HEIGHT = 600
    # Default file name.
    FILE_NAME = 'plot'
    # Default file type.
    FILE_TYPE = 'png'
    # Default box width.
    BOX_WIDTH = 0.5

    # Create a thermometer plot.
    #
    # options:: the plot options.
    #
    # options::data The therm data should be formatted as a set of column arrays.  Each column array
    # must be an array of triple the first member being the title to jitter, the second the y-position
    # of that title, and the third the scale size of that title.
    def therm_plot(options = {})
      options[:xtics].push("") if options[:xtics]
      data = options[:data]
      percents = data.flatten.every(3, 1)
      options[:yrange] = [percents.min, percents.max] unless options[:yrange]
      options[:data] = Array.new(data.length + 1, 0)
      plot(options) do |plot|
        count = 0
        data.each do |values|
          values.each do |title, percent, votes|
            plot.label "\"#{title.gsub(/\W/, ' ')}\" at first #{jitter(count, percent, values.transpose[1])}, first #{percent} font \"#{FONT},#{font_scale(values.transpose.last, votes)})\""
          end
          count += 1
        end
      end
    end

    # Create a GNU plot.
    #
    # options::font the font to use if not default.
    #
    # options::font_size the font size to use if not default
    #
    # options::data the plot data as a value passable to Gnuplot::DataSet.new (e.g. an Array).
    #
    # options::file_name the file name.  Defaults to 'plot'.
    #
    # options::file_type the file type.  Default to 'png'.
    #
    # options::title the graph title.
    #
    # options::xlabel the x-axis labels.
    #
    # options::ylabel the y-axis labels.
    #
    # options::size the size of the graph as a [width, height] array.  Defaults to [800, 600]
    #
    # options::logscale if passed the logscale string.  You cannot pass a yrange if a logscale is passed.
    #
    # options::yrange if passed the y-range as a [min, max] array.  You cannot pass a logscale if
    # a yrange is passed.
    #
    # options::xrange if passed the x-range as a [min, max] array.
    #
    # options::xtics if passed the xtics as an array of labels.
    #
    # options::ytics if passed the xtics as an array of labels.
    def plot(options = {}, &blk)
      Gnuplot.open do |gp|
        Gnuplot::Plot.new( gp ) do |plot|
          plot, data, options = assign_options(plot, options)
          yield(plot) unless blk.nil?
          plot.data << Gnuplot::DataSet.new(data) do |ds|
            ds.notitle
            ds.with = "boxes fs solid 1" unless options[:no_box]
            ds.using = options[:using] if options[:using]
            ds.with = options[:error_bars] if options[:error_bars]
          end
        end
      end
    end

private
    def assign_options(plot, options)
      sized(plot, options.delete(:size), options.delete(:font) || FONT, options.delete(:font_size) || FONT_SIZE)
      data = options.delete(:data)
      plot.output "#{options.delete(:file_name) || FILE_NAME}.#{options.delete(:file_type) || FILE_TYPE}"
      ds = options.delete(:ds) || {}
      plot.boxwidth options[:box_width] || BOX_WIDTH unless ds[:no_box]
      options.each do |k,v|
        v = options.delete(k)
        v && case k
        when :title, :xlabel, :ylabel, :logscale
          plot.send(k, v.remove_single_quotes)
        when :yrange, :xrange
          plot.send(k, "[#{v.join(':')}]")
        when :xtics, :ytics
          plot.send(k, tics(v))
        end
      end
      [plot, data, ds]
    end

    def sized(plot, size, font, font_size)
      size ||= [WIDTH, HEIGHT]
      plot.term "png font \"#{font}\" #{font_size} size #{size.first},#{size.last}"
    end

    def tics(v)
      count = -1
      "(#{v.map { |el| "\"#{el}\" #{count += 1}"}.join(",")})"
    end

    # scale to int [MIN_FS,MAX_FS]
    def font_scale(all, current)
      current.relative(all, [FS_MIN, FS_MAX]).round
    end

    # jitter value by subtracting random [0, JITTER_MAX]
    # if multiple values are within JITTER_RANGE percent range
    def jitter(num, percent, percentages)
      percentages.any? { |el| percent < el + JITTER_RANGE/2 && percent > el - JITTER_RANGE/2 } ? num - rand.relative([0, 1], [0, JITTER_MAX]) : num
    end
  end
end