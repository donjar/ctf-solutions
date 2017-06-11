require 'digest'
require 'benchmark'

def raw_xor(string1, string2)
  len = [string1.length, string2.length].min
  string1.bytes.zip(string2.bytes).first(len).map { |a, b| a ^ b }.pack('c*')
end

def hmac(key, msg)
  key = Digest::SHA1.digest(key) if key.length > 64
  key = key.ljust(64, "\x00") if key.length < 64
  ko = raw_xor(key, ("\x5c" * 64))
  ki = raw_xor(key, ("\x36" * 64))
  Digest::SHA1.hexdigest(ko + Digest::SHA1.digest(ki + msg))
end

$key = Random.new.bytes(64)

def test(file, signature)
  hmac = hmac($key, file)

  hmac.chars.zip(signature.chars).all? do |p|
    sleep(0.0002)
    p[0] == p[1]
  end
end

res = ''
40.times do
  char = 16.times.to_a.max_by do |i|
    Benchmark.realtime do
      test('amelia', (res + i.to_s(16)).ljust(40, '0'))
    end
  end

  res += char.to_s(16)
  puts res
end

puts hmac($key, 'amelia')
