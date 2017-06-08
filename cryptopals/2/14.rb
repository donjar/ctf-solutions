require 'mcrypt'
require 'base64'

key = Random.new.bytes 16
$cipher = Mcrypt.new(:rijndael_128, :ecb, key, nil, :pkcs7)

def encrypt(input)
  secret = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg\naGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq\ndXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg\nYnkK"
  $cipher.encrypt(Random.new.bytes(Random.new.rand(100)) + input + Base64::decode64(secret))
end

# WIP

# Get the encrypted form of 'a' * 16
encrypted_as = encrypt('a' * 32).chars.each_slice(16).map(&:join)
loop do
  encrypted_as = encrypted_as & encrypt('a' * 32).chars.each_slice(16).map(&:join)
  break if encrypted_as.length == 1
end
encrypted_as = encrypted_as.first

answer = ''

loop do
  prev = answer
  str_len = 16 - ((answer.length + 1) % 16)
  length = ((answer.length + 1) / 16.0 + 1).floor * 16

  # Try and get the second one of: encrypted('a' * 16), encrypted('a' * 15 + i.chr)
  encrypted_dictionary = 128.times.map do |i|
    res = nil
    loop do
      length_of_as = length + 15
      encrypt_trial = encrypt('a' * length_of_as + i.chr).chars.each_slice(16).map(&:join)
      length_of_as += 1 if i.chr == 'a'

      if length_of_as % 16 == 0
        res = encrypted_as
        break
      end

      unless encrypt_trial.select { |enc| enc == encrypted_as }.length == length_of_as / 16
        next
      end

      index = encrypt_trial.rindex encrypted_as
      unless index.nil?
        res = encrypt_trial[index + 1]
        break
      end
    end
    res
  end
  require 'byebug'; byebug

  loop do
    sol = encrypt('a' * str_len).chars.each_slice(16).map(&:join)

    found = false
    encrypted_dictionary.each_with_index do |c, i|
      if sol.include? c
        answer += i.chr
        found = true
        break
      end
    end
    break if found
  end

  puts answer
end

puts Base64::encode64 answer
