require 'gmp'
def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

e = 3

n1 = nil
et1 = nil
loop do
  p = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime
  q = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime

  n1 = p * q
  et1 = (p - 1) * (q - 1)
  break unless et1.divisible?(e)
end

n2 = nil
et2 = nil
loop do
  p = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime
  q = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime

  n2 = p * q
  et2 = (p - 1) * (q - 1)
  break unless et2.divisible?(e)
end

n3 = nil
et3 = nil
loop do
  p = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime
  q = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime

  n3 = p * q
  et3 = (p - 1) * (q - 1)
  break unless et3.divisible?(e)
end

msg = GMP::Z.new('amelia'.unpack1('H*').to_i(16))
c1 = msg.powmod(e, n1)
c2 = msg.powmod(e, n2)
c3 = msg.powmod(e, n3)

ms1 = n2 * n3
ms2 = n3 * n1
ms3 = n1 * n2

res = (c1 * ms1 * GMP::Z.new(ms1).invert(n1) + c2 * ms2 * GMP::Z.new(ms2).invert(n2) + c3 * ms3 * GMP::Z.new(ms3).invert(n3)).fmod(n1 * n2 * n3)
puts res.root(3)
p dec_to_ascii res.root(3).to_i
