encrypted = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

frequent = %w(a n i h o r t e s A N I H O R T E S)

res = 128.times.map do |key|
  total = 0
  decrypted = encrypted.scan(/../).map do |part|
    res_char = (part.to_i(16) ^ key).chr
    total += 1 if frequent.include? res_char
    res_char
  end.join
  [decrypted, total]
end.sort { |f, s| f[1] - s[1] }

puts res
