require 'gmp'
require 'digest'

p = '800000000000000089e1855218a0e7dac38136ffafa72eda7859f2171e25e65eac698c1702578b07dc2a1076da241c76c62d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebeac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc871a584471bb1'.to_i(16)
q = 17027479899911542979
g = GMP::Z.new('5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119458fef538b8fa4046c8db53039db620c094c9fa077ef389b5322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a0470f5b64c36b625a097f1651fe775323556fe00b3608c887892878480e99041be601a62166ca6894bdd41a7054ec89f756ba9fc95302291'.to_i(16))

msg = 'amelia'
m = Digest::SHA1.hexdigest(msg).to_i(16)

x = Random.new.rand(q)
y = g.powmod(x, q)

k = nil
r = nil
s = nil
loop do
  k = GMP::Z.new(Random.new.rand(q))
  r = g.powmod(k, p).fmod(q)
  next if r.zero?
  s = (k.invert(q) * (m + x * r)).fmod(q)
  next if s.zero?
  break
end

puts (k * k.invert(q)).fmod(q)

x2 = ((s * k - m) * r.invert(q)).fmod(q)
puts x, x2
puts 'ok' if x == x2
