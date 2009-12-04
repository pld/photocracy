require File.dirname(__FILE__) + '/test_helper.rb'

class GNUPlotterTest < Test::Unit::TestCase
  def test_should_create_plot
    GNUPlotter.plot(default_options)
    assert File.exists?("#{default_options[:file_name]}.png")
  end

  def test_should_create_plot_with_label_options
    GNUPlotter.plot(label_options)
    assert File.exists?("#{label_options[:file_name]}.png")
  end

  def test_should_create_plot_with_log_scale
    GNUPlotter.plot(log_options)
    assert File.exists?("#{log_options[:file_name]}.png")
  end

  def test_should_create_therm_plot
    GNUPlotter.therm_plot(therm_options)
    assert File.exists?("#{therm_options[:file_name]}.png")
  end

private
  def default_options
    {
      :file_name => File.dirname(__FILE__) + '/plot_test',
      :title => 'Plot Test',
      :data => [1,2,4,5]
    }
  end

  def label_options
    default_options.merge({
      :file_name => File.dirname(__FILE__) + '/plot_test_labels',
      :xtics => ['a', 'b', 'd', 'e'],
      :ytics => ['', 'z', 'y', '', 'v', 'w'],
      :xlabel => 'X Label',
      :ylabel => 'Y Label',
      :yrange => [0, 5]
    })
  end

  def log_options
    default_options.merge({
      :file_name => File.dirname(__FILE__) + '/plot_test_log',
      :logscale => 'y'
    })
  end

  def therm_options
    default_options.merge({
      :file_name => File.dirname(__FILE__) + '/plot_test_therm',
      :data => [
        [['A', 0, 10],
        ['B', 25, 20],
        ['C', 50, 30],
        ['D', 75, 20],
        ['E', 100, 10]],
        [['A', 5, 30],
        ['B', 20, 20],
        ['C', 45, 10],
        ['D', 70, 20],
        ['E', 95, 30]]
      ]
    })
  end
end