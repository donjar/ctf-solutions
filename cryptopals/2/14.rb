require 'mcrypt'
require 'base64'

$key = Random.new.bytes 16
$secret = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg\naGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq\ndXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg\nYnkK"

def encrypt(input)
  cipher = Mcrypt.new(:rijndael_128, :ecb, $key, nil, :pkcs7)
  cipher.encrypt(Random.new.bytes(Random.new.rand(100)) + input + Base64::decode64($secret))
end

# WIP

answer = ''
loop do
  prev = answer
  str_len = 16 - ((answer.length + 1) % 16)
  length = ((answer.length + 1) / 16.0 + 1).floor * 16
  sol = encrypt('a' * str_len).chars.take(length)

  128.times do |i|
    if sol == encrypt('a' * str_len + answer + i.chr).chars.take(length)
      answer += i.chr
      break
    end
  end

  break if prev == answer
end

puts Base64::encode64 answer
