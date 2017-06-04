require 'mcrypt'

def encryption_oracle(input)
  key = Random.new.bytes 16

  before = Random.new.bytes(Random.new.rand(5..10))
  after = Random.new.bytes(Random.new.rand(5..10))

  if Random.new.rand(2).zero?
    cipher = Mcrypt.new(:rijndael_128, :ecb, key, nil, :pkcs7)
  else
    cipher = Mcrypt.new(:rijndael_128, :cbc, key, "\x00" * 16, :pkcs7)
  end

  [cipher.encrypt(before + input + after), cipher.mode]
end

def guess_oracle(output)
  chars_slice = output.chars.each_slice(8).map { |str| str.join }
  if chars_slice.uniq.length == chars_slice.length
    'cbc'
  else
    'ecb'
  end
end

10000.times do |i|
  (res, sol) = encryption_oracle('12345678' * 16)
  unless guess_oracle(res) == sol
    puts "#{res} is wrong, should be #{sol}"
    exit
  end
end

puts 'OK'
