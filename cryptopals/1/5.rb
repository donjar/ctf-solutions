def encrypt(str, key)
  idx = 0
  str.chars.map do |c|
    res = (c.ord ^ key[idx].ord).to_s(16).rjust(2, '0')
    idx = (idx + 1) % (key.length)
    res
  end.join
end

puts encrypt("Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal", "ICE")
