class Array
  # evaluate on outside of loop
  def sumup(on = nil)
    on ? self.inject(0) { |sum, el| sum += el.send(on).to_f } : self.inject(0) { |sum, el| sum += el.to_f }
  end

  def avg(on = nil)
    return 0 if self.empty?
    self.sumup(on) / self.length.to_f
  end

  def sparse(max)
    return self unless max > 3 && self.length > max
    current = start = new_start = 1
    step = (self.length / max.to_f).ceil
    step = 2 if step < 2
    array = self.dup
    while array.compact.length > max
      array[current] = nil
      current = (current < array.length - step) ? current + step : start += 1
    end
    array
  end

  def to_hash
    self.inject({}) do |hash, array|
      hash[array.first.to_i] = array.last
      hash
    end
  end

  def obj_id_to_hash
    self.inject({}) do |hash, obj|
      hash[obj.id] = obj
      hash
    end
  end

  def to_percent
    total = self[0] + self[1]
    total.zero? ? 0 : 100 * (self[0].to_f / total)
  end
end

class String
  def dashed
    self.downcase.gsub(/ /, '_')
  end

  def strip_tags
    self.gsub(/<\/?[^>]*>/, "")
  end
end

class Net::HTTP
  alias_method :old_initialize, :initialize

  # pairwise uses a unverified SSL cert so ignore warnings
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end