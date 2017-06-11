require 'mcrypt'
require 'base64'

plaintext = Base64::decode64(File.read('25.txt'))
$cipher = Mcrypt.new(:rijndael_128, :ctr,
                     Random.new.bytes(16), Random.new.bytes(16))
$ciphertext = $cipher.encrypt(plaintext)

def edit(ciphertext, offset, new_text)
  decrypted = $cipher.decrypt(ciphertext)
  new_text.chars.each_with_index do |char, idx|
    decrypted[offset + idx] = char
  end
  $cipher.encrypt(decrypted)
end

def raw_xor(string1, string2)
  len = [string1.length, string2.length].min
  string1.bytes.zip(string2.bytes).first(len).map { |a, b| a ^ b }.pack('c*')
end

raw_xor($ciphertext, edit($ciphertext, 0, "\x00" * $ciphertext.length))
