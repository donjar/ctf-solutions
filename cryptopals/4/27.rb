require 'mcrypt'

key = Random.new.bytes(16)
cipher = Mcrypt.new :rijndael_128, :cbc, key, key

ciphertext = cipher.encrypt(Random.new.bytes(16))

def raw_xor(string1, string2)
  len = [string1.length, string2.length].min
  string1.bytes.zip(string2.bytes).first(len).map { |a, b| a ^ b }.pack('c*')
end

res = cipher.decrypt(ciphertext + "\x00" * 16 + ciphertext)
recovered_key = raw_xor(res.chars.first(16).join, res.chars.last(16).join)

puts key == recovered_key
