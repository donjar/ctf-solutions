require 'base64'

def hamming(f, s)
  f.chars.zip(s.chars).reduce(0) do |accum, pair|
    first = pair[0].ord.to_s(2).rjust(8, '0').chars
    second = pair[1].ord.to_s(2).rjust(8, '0').chars

    char_hamming = first.zip(second).reduce(0) do |a, n|
      if n[0] == n[1]
        a
      else
        a + 1
      end
    end

    accum += char_hamming
  end
end

text = Base64::decode64 File.read '6.txt'

# Guess for keysize by calculating Hamming distance between close keys
res = (2..40).map do |keysize|
  res = 10.times.map do |i|
    text[(i * keysize)...((i + 1) * keysize)]
  end.combination(2).map do |x, y|
    hamming(x, y) / (keysize + 0.0)
  end.reduce(:+)

  [keysize, res]
end

res.sort { |a, b| a[1] - b[1] }.each { |x| p x }

keysize = 29

# Split and transpose text into groups of characters
splitted = text.scan(Regexp.new('.' * keysize)).map { |str| str.chars }.transpose

# Single char decrypt
def decrypt(encrypted, threshold, allow_nonalphabet = true)
  frequent = %w(a n i h o r t e s A N I H O R T E S)

  res = 128.times.map do |key|
    total = 0
    decrypted = encrypted.scan(/../).map do |part|
      res_char = (part.to_i(16) ^ key).chr
      total += 1 if frequent.include? res_char
      res_char
    end.join
    [key, decrypted, total]
  end.sort { |f, s| f[2] - s[2] }.select { |p| p[2] >= threshold }

  unless allow_nonalphabet
    res.select! do |p|
      p[1].chars.all? { |c| c.ord >= 32 && c.ord <= 126 }
    end
  end

  res
end

keysize.times do |i|
  File.write("res#{i}.txt", decrypt(splitted[i].join, 0, true).flatten.join("\n"))
end
