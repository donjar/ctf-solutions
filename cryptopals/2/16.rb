require 'mcrypt'

key = Random.new.bytes 16
iv = Random.new.bytes 16
$cipher = Mcrypt.new :rijndael_128, :cbc, key, iv, :pkcs7

def encrypt(text)
  text.gsub!(';', '%3B')
  text.gsub!('=', '%3D')
  plaintext = "comment1=cooking%20MCs;userdata=#{text};comment2=%20like%20a%20pound%20of%20bacon"
  $cipher.encrypt plaintext
end

def decrypt(text)
  plaintext = $cipher.decrypt text 
  [plaintext.include?(';admin=true;')] + plaintext.chars.each_slice(16).map(&:join)
end

# ["comment1=cooking", "%20MCs;userdata=", "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", "\x00\x00\x00\x00\x00\x00;comment2=", "%20like%20a%20po", "und%20of%20bacon"]
res = encrypt("\x00" * 22)

second = res[16...32]

second2 = second.chars.zip(";admin=true;".chars + ["\x00"] * 4).map { |x| (x[0].ord ^ x[1].ord).chr }.join

# ["comment1=cooking", (junk), ";admin=true;\x00\x00\x00\x00", "\x00\x00\x00\x00\x00\x00;comment2=", "%20like%20a%20po", "und%20of%20bacon"]
decrypt(res[0...16] + second + res[32...112])
