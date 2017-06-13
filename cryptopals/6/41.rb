require 'gmp'

e = 3

n = nil
et = nil
loop do
  p = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime
  q = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime

  n = p * q
  et = (p - 1) * (q - 1)
  break unless et.divisible?(e)
end

ans = GMP::Z.new(Random.new.rand(2 ** 128))
encrypted = ans.powmod(e, n)
s = n + 2
new_encrypted = (GMP::Z.new(s).powmod(e, n) * encrypted).fmod(n)

d = GMP::Z.new(e).invert(et)

decrypted = new_encrypted.powmod(d, n)
result = (decrypted * GMP::Z.new(s).invert(n)).fmod(n)

puts result
puts ans
puts result == ans
