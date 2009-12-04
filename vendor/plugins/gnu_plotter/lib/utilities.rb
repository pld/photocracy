require 'htmlentities'

module Utilities
  def log(message)
    time = Time.now
    puts "#{time.hour.lead_zero}:#{time.min.lead_zero} - #{message}"
  end
end

class Array
  def range
    self.max - self.min.to_f
  end

  def sumup(column = nil, &block)
    self.inject(0) do |total, obj|
      value = column.nil? ? obj : obj.send(column)
      total += block.nil? ? value : yield(value)
    end
  end

  def every(n, start = 0)
    select {|x| index(x) % n == start}
  end
end

class Numeric
  def relative(from, to = nil)
    res = from.range > 0 ? (from.max - self) / from.range.to_f : 0
    to.nil? ? res : res * to.range + to.min
  end

  def as_percentage(total, multiplier = 100)
    total.zero? ? 0.0 : multiplier * (self / total.to_f)
  end
end

class Fixnum
  def lead_zero
    self < 10 ? "0%i" % self : self.to_s
  end
end

class String
  def escape_single_quotes
    self.gsub(/[']/, '\\\\\'')
  end

  def remove_single_quotes
    self.gsub(/[']/, '')
  end

  def remove_quotes
    self.gsub(/['|"]/, '')
  end

  def underscore_ws
    self.gsub(/\W|\//, '_')
  end

  def decode
    self
    @coder ||= HTMLEntities.new
    @coder.decode(self)
  end

  def deunderscore
    self.gsub(/_/, ' ')
  end
end

class Hash
  def values_by_keys
    sort_by { |k, v| k }.transpose.last
  end
end