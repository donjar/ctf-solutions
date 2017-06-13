require 'gmp'
require 'digest'

p = GMP::Z(0x800000000000000089e1855218a0e7dac38136ffafa72eda7859f2171e25e65eac698c1702578b07dc2a1076da241c76c62d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebeac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc871a584471bb1)
q = GMP::Z(0xf4f47f05794b256174bba6e9b396a7707e563c5b)
g = GMP::Z(0x5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119458fef538b8fa4046c8db53039db620c094c9fa077ef389b5322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a0470f5b64c36b625a097f1651fe775323556fe00b3608c887892878480e99041be601a62166ca6894bdd41a7054ec89f756ba9fc95302291)

msg = 'amelia'
m = Digest::SHA1.hexdigest(msg).to_i(16)

x = Random.new.rand(q.to_i)
y = g.powmod(x, q)

k = nil
r = nil
s = nil
loop do
  k = GMP::Z.new(Random.new.rand(q.to_i))
  r = g.powmod(k, p).fmod(q)
  next if r.zero?
  s = (k.invert(q) * (m + x * r)).fmod(q)
  next if s.zero?
  break
end

x2 = ((s * k - m) * r.invert(q)).fmod(q)
puts x, x2
puts 'ok' if x == x2

y = GMP::Z(0x84ad4719d044495496a3201c8ff484feb45b962e7302e56a392aee4abab3e4bdebf2955b4736012f21a08084056b19bcd7fee56048e004e44984e2f411788efdc837a0d2e5abb7b555039fd243ac01f0fb2ed1dec568280ce678e931868d23eb095fde9d3779191b8c0299d6e07bbb283e6633451e535c45513b2d33c99ea17)
msg = "For those that envy a MC it can be hazardous to your health\r\nSo be friendly, a matter of life and death, just like a etch-a-sketch"
m = Digest::SHA1.hexdigest(msg).to_i(16)
puts m.to_s(16)
r = GMP::Z(548099063082341131477253921760299949438196259240)
s = GMP::Z(857042759984254168557880549501802188789837994940)

k = 65536.times.find do |i|
  g.powmod(GMP::Z(i), p).fmod(q) == r
end

new_x = ((s * k - m) * r.invert(q)).fmod(q)
puts new_x
