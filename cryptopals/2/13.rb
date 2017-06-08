require 'mcrypt'
$key = Random.new.bytes 16

def profile_for(email)
  { 'email' => email, 'uid' => '10', 'role' => 'user' }.map do |k, v|
    "#{k.tr('&', '').tr('=', '')}=#{v.tr('&', '').tr('=', '')}"
  end.join('&')
end

def encrypt(email)
  cipher = Mcrypt.new(:rijndael_128, :ecb, $key, nil, :pkcs7)
  cipher.encrypt(profile_for(email))
end

def decrypt(ciphertext)
  cipher = Mcrypt.new(:rijndael_128, :ecb, $key, nil, :pkcs7)
  res = cipher.decrypt(ciphertext)
  Hash[*(res.split('&').map { |x| x.split '=' }.flatten)]
end

# ["email=1234567890", "123&uid=10&role=", "user"]
user = encrypt('1234567890123')

# ["email=1234567890", "admin\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b", "&uid=10&role=use", "r"]
admin_block = encrypt('1234567890admin' + "\x0b" * 11)[16...32]

puts decrypt(user[0...32] + admin_block)
