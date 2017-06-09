require 'mcrypt'
require 'base64'
require 'uri'
require 'typhoeus'

$block_size = 16

def check_padding(str)
  res = Typhoeus::Request.new("http://natas28.natas.labs.overthewire.org/search.php/?query=#{URI.encode(Base64::encode64(str))}", { userpwd: "natas28:JWwR438wkgTsNKBbcJoowyysdM82YjeF" }).run
  res.response_body.include? 'Whack Computer Joke Database'
end

def hexsucc(string)
  (string.ord + 1).chr
end

def raw_xor(string1, string2)
  string1.bytes.zip(string2.bytes).map { |a, b| a ^ b }.pack('c*')
end

def decrypt_block(iv, current_block)
  plain_decrypted = "\x00" * $block_size

  (1..$block_size).each do |i|
    garbage = plain_decrypted.clone

    (1..(i - 1)).each do |j|
      garbage[-j] = raw_xor(garbage[-j], i.chr)
    end

    loop do
      break if check_padding(garbage + current_block)
      garbage[-i] = hexsucc(garbage[-i])
    end

    plain_decrypted[-i] = raw_xor(garbage[-i], i.chr)

    p plain_decrypted[-i]
  end

  plain_decrypted
end

def decipher_text(iv, ciphertext)
  res = ciphertext.chars.each_slice($block_size).map(&:join)
  puts "Number of blocks: #{res.length}"

  (1..res.length).map do |idx|
    previous_block = (idx == res.length) ? iv : res[-idx - 1]
    raw_xor(decrypt_block(iv, res[-idx]), previous_block)
  end.reverse.join
end

loop do
  iv = "\x00" * $block_size
  ciphertext = Base64::decode64 URI.decode 'G%2BglEae6W%2F1XjA7vRm21nNyEco%2Fc%2BJ2TdR0Qp8dcjPLof%2FYMma1yzL2UfjQXqQEop36O0aq%2BC10FxP%2FmrBQjq0eOsaH%2BJhosbBUGEQmz%2Fto%3D'

  begin
    p decipher_text iv, ciphertext
  rescue RangeError => e
    next
  end

  break
end
