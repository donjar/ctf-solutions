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

def dh_encrypt(secret, msg)
  iv = Random.new.bytes(16)
  cipher = Mcrypt.new :rijndael_128, :cbc, Digest::SHA1.digest(secret)[0...16], iv, :pkcs7
  cipher.encrypt(msg) + iv
end

g = 2
p = 'ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552bb9ed529077096966d670c354e4abc9804f1746c08ca237327ffffffffffffffff'.to_i(16)
a = Random.new.rand(2 ** 64)
b = Random.new.rand(2 ** 64)
A = generate_public(g, p, a)
B = generate_public(g, p, b)

mal = p - 1 # malicious p
p_wild = p
g_wild = g
A_wild = A # g^a mod p
B_wild = generate_public(mal, p, b) # mal^b mod p
sa = get_secret(p, B_wild, a) # mal^ab mod p
sb = get_secret(p, A_wild, b) # g^ab mod p

msgA = dh_encrypt dec_to_ascii(sa), 'amelia'
msgB = dh_encrypt dec_to_ascii(sb), msgA

messageA = msgA[0...-16]
ivA = msgA[-16..-1]

if mal == 1
  key = Digest::SHA1.digest("\x01")[0...16]

  cipher = Mcrypt.new :rijndael_128, :cbc, key, ivA, :pkcs7
  puts "With mal=1, msg=#{cipher.decrypt messageA}"
elsif mal == p
  key = Digest::SHA1.digest("\x00")[0...16]

  cipher = Mcrypt.new :rijndael_128, :cbc, key, ivA, :pkcs7
  puts "With mal=p, msg=#{cipher.decrypt messageA}"
elsif mal == p - 1
  key1 = Digest::SHA1.digest("\x01")[0...16]
  key2 = Digest::SHA1.digest(dec_to_ascii(p - 1))[0...16]

  cipher1 = Mcrypt.new :rijndael_128, :cbc, key1, ivA, :pkcs7
  cipher2 = Mcrypt.new :rijndael_128, :cbc, key2, ivA, :pkcs7
  puts "With mal=p-1, msg1=#{cipher1.decrypt messageA}" rescue ''
  puts "With mal=p-1, msg2=#{cipher2.decrypt messageA}" rescue ''
end
