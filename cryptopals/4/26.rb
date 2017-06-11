require 'mcrypt'

key = Random.new.bytes 16
iv = Random.new.bytes 16
$cipher = Mcrypt.new :rijndael_128, :ctr, key, iv, :pkcs7

def encrypt(text)
  text.gsub!(';', '%3B')
  text.gsub!('=', '%3D')
  plaintext = "comment1=cooking%20MCs;userdata=#{text};comment2=%20like%20a%20pound%20of%20bacon"
  $cipher.encrypt plaintext
end

def raw_xor(string1, string2)
  len = [string1.length, string2.length].min
  string1.bytes.zip(string2.bytes).first(len).map { |a, b| a ^ b }.pack('c*')
end

def decrypt(text)
  plaintext = $cipher.decrypt text
  [plaintext.include?(';admin=true;')] + plaintext.chars.each_slice(16).map(&:join)
end

# ["comment1=cooking", "%20MCs;userdata=", "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "\x00\x00\x00\x00\x00\x00;comment2=", "%20like%20a%20po", "und%20of%20bacon"]
res = encrypt("\x00" * 22)

relevant = res[33...45]

result = raw_xor res[33...45], ";admin=true;"

# ["comment1=cooking", "%20MCs;userdata=", "\x00;admin=true;\x00\x00\x00", "\x00\x00\x00\x00\x00\x00;comment2=", "%20like%20a%20po", "und%20of%20bacon"]
p decrypt(res[0...33] + result + res[45...112])
