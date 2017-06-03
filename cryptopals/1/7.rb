require 'openssl'
require 'base64'

str = Base64::decode64 File.read('7.txt')

cipher = OpenSSL::Cipher.new('AES-128-ECB')
cipher.decrypt
cipher.key = "YELLOW SUBMARINE"

puts cipher.update(str) + cipher.final
