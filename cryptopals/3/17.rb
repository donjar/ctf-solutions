require 'mcrypt'
require 'base64'

$key = Random.new.bytes 16
$texts = ['MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=', 'MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=', 'MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==', 'MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==', 'MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl', 'MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==', 'MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==', 'MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=', 'MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=', 'MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93']

def encrypt(id = Random.new.rand($texts.length))
  iv = Random.new.bytes 16
  cipher = Mcrypt.new(:rijndael_128, :cbc, $key, iv, :pkcs7)
  [iv, cipher.encrypt(Base64::decode64($texts[id]))]
end

def consume(iv, ciphertext)
  Mcrypt.new(:rijndael_128, :cbc, $key, iv, :pkcs7).decrypt(ciphertext)
  true
rescue Mcrypt::PaddingError
  false
end

def hexsucc(string)
  (string.ord + 1).chr
end

def raw_xor(string1, string2)
  string1.bytes.zip(string2.bytes).map { |a, b| a ^ b }.pack('c*')
end

def decrypt_block(iv, current_block)
  plain_decrypted = "\x00" * 16

  (1..16).each do |i|
    garbage = plain_decrypted.clone

    (1..(i - 1)).each do |j|
      garbage[-j] = raw_xor(garbage[-j], i.chr)
    end

    loop do
      break if consume(iv, garbage + current_block)
      garbage[-i] = hexsucc(garbage[-i])
    end

    plain_decrypted[-i] = raw_xor(garbage[-i], i.chr)
  end

  plain_decrypted
end

def decipher_text(iv, ciphertext)
  res = ciphertext.chars.each_slice(16).map(&:join)

  (1..res.length).map do |idx|
    previous_block = (idx == res.length) ? iv : res[-idx - 1]
    raw_xor(decrypt_block(iv, res[-idx]), previous_block)
  end.reverse.join
end

txt_id = 0
loop do
  iv, ciphertext = encrypt txt_id

  begin
    p decipher_text iv, ciphertext
  rescue RangeError => e
    next
  end

  txt_id += 1
  break if txt_id == $texts.length
end
