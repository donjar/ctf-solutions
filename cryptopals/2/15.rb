def valid?(text, block_size = 8)
  return false if text.length % block_size != 0
  bytes = text.bytes
  last = bytes.last
  if (last >= 1 && last <= block_size)
    if bytes.last(last).uniq.length == 1
      return true
    end
  end
  false
end

puts valid? "ICE ICE BABY\x04\x04\x04\x04"
puts valid? "ICE ICE BABY\x05\x05\x05\x05"
puts valid? "ICE ICE BABY\x01\x02\x03\x04"
puts valid? "ICE ICE BABYYEA\x01"
puts valid? "ICE ICE BABYYEAH\x08\x08\x08\x08\x08\x08\x08\x08"
