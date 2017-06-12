require 'gmp'
def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

e = 3
p = nil
q = nil
n = nil
et = nil
loop do
  p = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime
  q = GMP::Z.new(Random.new.rand(2 ** 128)).nextprime

  n = p * q
  et = (p - 1) * (q - 1)
  break unless et.divisible?(e)
end

d = GMP::Z.new(e).invert(et)

msg = GMP::Z.new('amelia'.unpack1('H*').to_i(16))
encrypted_msg = msg.powmod(e, n)

decrypted_int = encrypted_msg.powmod(d, n)
res = dec_to_ascii decrypted_int.to_i
p res
