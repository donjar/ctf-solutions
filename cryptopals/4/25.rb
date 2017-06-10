require 'mcrypt'
require 'base64'

plaintext = Base64::decode64(File.read('25.txt'))
key = Random.new.bytes(16)
$cipher = Mcrypt.new(:rijndael_128, :ctr, key)
$ciphertext = cipher.encrypt(plaintext)

def edit(ciphertext, offset, new_text)
  decrypted = $cipher.decrypt(ciphertext)
  new_text.chars.each_with_index do |char, idx|
    decrypted[offest + idx] = char
  end
  decrypted
end
