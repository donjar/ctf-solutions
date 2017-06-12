require 'digest'
require 'gmp'

N = 'ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552bb9ed529077096966d670c354e4abc9804f1746c08ca237327ffffffffffffffff'.to_i(16)
g = 2
k = 3
email = 'mail@herbert.id'
password = 'amelia'

class Server
  def initialize(N, g, k, email, password)
    @N = N
    @g = g
    @k = k
    @email = email
    @password = password

    @salt = Random.new.bytes(16)
    xH = Digest::SHA256.hexdigest(salt + password)
    x = xH.to_i(16)
    @v = GMP::Z.new(g).powmod(x, N)

    @B = (@v + GMP::Z.new(g).powmod(b, N)) % N
  end

  def get_IA(email, A)
    @uH = Digest::SHA256.hexdigest(salt + password)
  end

  def check_pass(hmac)
  end
end

class Client
  def initialize(N, g, k, email, password)
    @N = N
    @g = g
    @k = k
    @email = email
    @password = password
  end
end



puts 'What is I = Email?'
c_I = gets
puts 'What is A = g^a mod N?'
A = gets

puts 'This is salt'
p salt
puts 'This is B = v + g^b mod N'
B = (v + GMP::Z.new(g).powmod(b, N)) % N
p B


