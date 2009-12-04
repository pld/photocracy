require File.dirname(__FILE__) + '/../profile_test_helper'

class ResponsesTest < ActionController::IntegrationTest
  include RubyProf::Test

  def setup
    RubyProf.measurement_mode = RubyProf::MEMORY
  end

  def test_new
    puts "responses/new:"
    benchmark_time :get, 'responses/new'
    benchmark_memory :get, 'responses/new'
  end

  def benchmark_time(method, url)
      measured_times = []
      10.times { measured_times << Benchmark.realtime { send(method, url) } }
      puts "time: #{mean(measured_times).to_f} ± #{deviation(measured_times).to_f}\n"
  end

  def benchmark_memory(method, url)
      gc_statistics("memory: ") { send(:method, url) }
  end

  def mean(values)
      values.sum / values.length
  end

  def deviation(values)
      m = mean(values)
      Math.sqrt(values.inject(0){|sum, a| sum + (a - m)**2} / values.length)
  end

  #Executes block and collects GC statistics during the block execution.
  #Collected stats are printed to stdout (or to the file set in $RUBY_GC_DATA_FILE env var):
  # - allocated memory size (in KB) during block execution
  # - number of memory allocations during block execution
  # - number of GC collections during block execution
  # - time (in milliseconds ) spent in GC
  #
  #Description string appears in stdout before statistics
  #Options are
  # - :disable_gc => true    - disables GC during execution
  # - :show_gc_dump => true  - shows GC heap dump after statistics
  def gc_statistics(description = "", options = {})
      #do nothing if we don't have patched Ruby GC
      yield and return unless GC.respond_to? :enable_stats

      GC.enable_stats || GC.clear_stats
      GC.disable if options[:disable_gc]

      yield

      stat_string = description + ": "
      stat_string += "allocated: #{GC.allocated_size/1024}K total in #{GC.num_allocations} allocations, "
      stat_string += "GC calls: #{GC.collections}, "
      stat_string += "GC time: #{GC.time / 1000} msec"

      GC.log stat_string
      GC.dump if options[:show_gc_dump]

      GC.enable if options[:disable_gc]
      GC.disable_stats
  end
end