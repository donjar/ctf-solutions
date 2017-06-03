require 'openssl'
require 'base64'

str_list = File.read('8.txt').split("\n").map { |x| [x].pack('H*') }

str_list.each do |s|
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.decrypt
  cipher.key = 'YELLOW SUBMARINE'

  puts cipher.update(s)
end
