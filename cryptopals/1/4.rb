frequent = %w(a n i h o r t e s A N I H O R T E S)

File.read('4.txt').split("\n").each_with_index do |encrypted, idx|
  puts "=== LINE #{idx} ==="
  res = 128.times.map do |key|
    total = 0
    decrypted = encrypted.scan(/../).map do |part|
      res_char = (part.to_i(16) ^ key).chr
      total += 1 if frequent.include? res_char
      res_char
    end.join
    [decrypted, total]
  end.sort { |f, s| f[1] - s[1] }.select { |p| p[1] >= 15 }

  puts res
end
