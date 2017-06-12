require 'gmp'
require 'digest'
require 'mcrypt'

def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

def generate_public(g, p, priv)
  GMP::Z.new(g).powmod(priv, p)
end

def get_secret(p, pub, priv)
  GMP::Z.new(pub).powmod(priv, p)
end

g = 2
p = 'ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552bb9ed529077096966d670c354e4abc9804f1746c08ca237327ffffffffffffffff'.to_i(16)
a = Random.new.rand(2 ** 64)
b = Random.new.rand(2 ** 64)
A = generate_public(g, p, a)
B = generate_public(g, p, b)

p "A: p = #{p}, g = #{g}, A = #{A}"
p "B: B = #{B}"

# ORIGINAL DIFFIE-HELLMAN EXCHANGE
# s = get_secret(p, A, b)
#
# # Send CBC(key = SHA1(s)[0...16], iv = random(16), msg = msg) + iv
# msg = 'abc'
# ivA = Random.new.bytes 16
# cipherA = Mcrypt.new :rijndael_128, :cbc, Digest::SHA1.hexdigest(dec_to_ascii(s))[0...16], ivA, :pkcs7
# msgA = cipherA.encrypt(msg) + ivA
# p "A: #{msgA}"
#
# # Send CBC(key = SHA1(s)[0...16], iv = random(16), msg = msgA) + iv
# ivB = Random.new.bytes 16
# cipherB = Mcrypt.new :rijndael_128, :cbc, Digest::SHA1.hexdigest(dec_to_ascii(s))[0...16], ivB, :pkcs7
# msgB = cipherB.encrypt(msgA)
# p "B: #{msgB + ivB}"

sa = get_secret(p, p, a) # 0
sb = get_secret(p, p, b) # 0
msg = 'amelia'

# Send CBC(key = SHA1(s)[0...16], iv = random(16), msg = msg) + iv
ivA = Random.new.bytes 16
cipherA = Mcrypt.new :rijndael_128, :cbc, Digest::SHA1.hexdigest(dec_to_ascii(sa))[0...16], ivA, :pkcs7
msgA = cipherA.encrypt(msg) + ivA
p "A: msgA = #{msgA}"

# Send CBC(key = SHA1(s)[0...16], iv = random(16), msg = msgA) + iv
ivB = Random.new.bytes 16
cipherB = Mcrypt.new :rijndael_128, :cbc, Digest::SHA1.hexdigest(dec_to_ascii(sb))[0...16], ivB, :pkcs7
msgB = cipherB.encrypt(msgA) + ivB
p "B: msgB = #{msgB}"

# Solution
key = Digest::SHA1.hexdigest("\x00")[0...16]
broken_messageB = msgB[0...-16]
broken_ivB = msgB[-16..-1]
broken_cipherB = Mcrypt.new :rijndael_128, :cbc, key, broken_ivB, :pkcs7
res_msgA = broken_cipherB.decrypt broken_messageB

broken_messageA = res_msgA[0...-16]
broken_ivA = res_msgA[-16..-1]
broken_cipherA = Mcrypt.new :rijndael_128, :cbc, key, broken_ivA, :pkcs7
puts broken_cipherA.decrypt(broken_messageA)
