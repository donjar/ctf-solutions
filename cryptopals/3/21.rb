def lowest_32bits(x)
  0xffffffff & x
end

class Rand
  def initialize(seed)
    @index = 624
    @mt = [0] * 624
    @mt[0] = seed

    (1...624).each do |i|
      @mt[i] = lowest_32bits(1812433253 * (@mt[i - 1] ^ @mt[i - 1] >> 30) + i)
    end
  end

  def extract
    twist if @index >= 624
    y = @mt[@index]

    # Right shift by 11 bits
    y = y ^ y >> 11
    # Shift y left by 7 and take the bitwise and of 2636928640
    y = y ^ y << 7 & 2636928640
    # Shift y left by 15 and take the bitwise and of y and 4022730752
    y = y ^ y << 15 & 4022730752
    # Right shift by 18 bits
    y = y ^ y >> 18

    @index = @index + 1

    return lowest_32bits(y)
  end

  def twist
    624.times do |i|
      y = lowest_32bits((@mt[i] & 0x80000000) + (@mt[(i + 1) % 624] & 0x7fffffff))
      @mt[i] = @mt[(i + 397) % 624] ^ y >> 1
      @mt[i] = @mt[i] ^ 0x9908b0df if y.odd?
    end
    @index = 0
  end
end
