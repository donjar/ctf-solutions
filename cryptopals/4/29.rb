def leftrotate(value, shift)
  ((value << shift) | (value >> (32 - shift))) & 0xffffffff
end

def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

def sha1_chunked(text, h0 = nil, h1 = nil, h2 = nil, h3 = nil, h4 = nil)
  h0 = 0x67452301 if h0.nil?
  h1 = 0xEFCDAB89 if h1.nil?
  h2 = 0x98BADCFE if h2.nil?
  h3 = 0x10325476 if h3.nil?
  h4 = 0xC3D2E1F0 if h4.nil?

  result = []

  bit_string = sha1_pad(text.unpack1('B*'))

  puts 'Bit string'
  puts bit_string.chars.each_slice(512).map(&:join)

  bit_string.chars.each_slice(512) do |chunk|
    # Extend 16 32-bit words to 80 32-bit words
    words = chunk.each_slice(32).map { |c| c.join.to_i(2) }
    (16..79).each do |i|
      words[i] = leftrotate(words[i - 3] ^ words[i - 8] ^ words[i - 14] ^ words[i - 16], 1)
    end

    # Main loop
    a = h0
    b = h1
    c = h2
    d = h3
    e = h4
    f = nil
    k = nil

    # 80 times: update h0, h1, h2, h3, h4
    80.times do |i|
      if i <= 19
        f = (b & c) | (~b & d)
        k = 0x5A827999
      elsif i <= 39
        f = b ^ c ^ d
        k = 0x6ED9EBA1
      elsif i <= 59
        f = (b & c) | (b & d) | (c & d)
        k = 0x8F1BBCDC
      elsif i <= 79
        f = b ^ c ^ d
        k = 0xCA62C1D6
      end

      temp = (leftrotate(a, 5) + f + e + k + words[i]) & 0xffffffff
      e = d
      d = c
      c = leftrotate(b, 30)
      b = a
      a = temp
    end

    h0 = (h0 + a) & 0xffffffff
    h1 = (h1 + b) & 0xffffffff
    h2 = (h2 + c) & 0xffffffff
    h3 = (h3 + d) & 0xffffffff
    h4 = (h4 + e) & 0xffffffff

    result << [h0, h1, h2, h3, h4]
  end
  result
end

def sha1(message, h0 = nil, h1 = nil, h2 = nil, h3 = nil, h4 = nil)
  res = sha1_chunked(message, h0, h1, h2, h3, h4)
  res.last.map { |i| i.to_s(16) }.join
end

def sha1_mac(message, key)
  sha1(key + message)
end

def sha1_pad(bin_msg)
  ml = bin_msg.length
  res = bin_msg.clone

  res += '1'
  loop do
    break if res.length % 512 == 448
    res += '0'
  end
  res += ml.to_s(2).rjust(64, '0')
end

key = 'amelia'
msg = 'comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon'
hash = sha1_mac(msg, key)

forged = ';admin=true;'.encode('ascii-8bit')

# new_text = pad(key + msg) + forged
new_text = key + msg
new_text = [sha1_pad(new_text.unpack1('B*'))].pack('B*')
new_text += forged

state = hash.chars.each_slice(8).map { |c| c.join.to_i(16) }

# forged_text = last part of new_text
forged_bits = forged.unpack1('B*')
forged_bits += '1'
loop do
  break if forged_bits.length % 512 == 448
  forged_bits += '0'
end

forged_length = ((key + msg).length / 64.0).ceil * 64 + forged.length
forged_bits += (forged_length * 8).to_s(2).rjust(64, '0')

forged_text = [forged_bits].pack('B*')

p sha1_chunked(forged_text, *state)[0].map { |x| x.to_s(16) }.join
p sha1(new_text)
