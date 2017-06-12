require 'digest'
require 'gmp'
require 'openssl'

def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

# Agreements
N = 'ffffffffffffffffc90fdaa22168c234c4c6628b80dc1cd129024e088a67cc74020bbea63b139b22514a08798e3404ddef9519b3cd3a431b302b0a6df25f14374fe1356d6d51c245e485b576625e7ec6f44c42e9a637ed6b0bff5cb6f406b7edee386bfb5a899fa5ae9f24117c4b1fe649286651ece45b3dc2007cb8a163bf0598da48361c55d39a69163fa8fd24cf5f83655d23dca3ad961c62f356208552bb9ed529077096966d670c354e4abc9804f1746c08ca237327ffffffffffffffff'.to_i(16)
g = GMP::Z.new(2)
k = 3
$email = 'mail@herbert.id'
password = 'amelia'

# Secret things
c = Random.new.rand N
s = Random.new.rand N

# Server init
$salt = Random.new.bytes(16)
x = Digest::SHA256.hexdigest($salt + password).to_i(16)
server_v = g.powmod(x, N)

# C -> S, S -> C
$B = (k * server_v + g.powmod(s, N)).fmod(N)
$A = 100 * N # MALICIOUS

# Compute u
u = Digest::SHA256.hexdigest(dec_to_ascii($A) + dec_to_ascii($B)).to_i(16)

# Compute S and K
client_S = GMP::Z.new($B - k * g.powmod(x, N)).powmod(c + u * x, N)
server_S = GMP::Z.new($A * GMP::Z.new(server_v).powmod(u, N)).powmod(s, N)
client_K = Digest::SHA256.digest "\x00" # MALICIOUS
server_K = Digest::SHA256.digest dec_to_ascii server_S.to_i

# Get hash
client_H = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), client_K, $salt)
server_H = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), server_K, $salt)
puts(client_H == server_H ? 'ok' : 'no')

# From the IETF docs:
# The server MUST abort the handshake with an "illegal_parameter" alert if A % N = 0.
