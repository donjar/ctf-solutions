require 'mcrypt'
require 'base64'

def ascii_to_bin(text)
  text.unpack('B*').first
end

def bin_to_ascii(text)
  padded_length = (text.length / 16.0).ceil * 16
  text.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

def raw_xor(string1, string2)
  string1.bytes.zip(string2.bytes).map { |a, b| a ^ b }.pack('c*')
end

def encrypt(text, key, iv = nil, block_size = 128)
  char_size = block_size / 8
  char_array = text.chars.each_slice(char_size).map { |arr| arr.join }
  iv = "\x00" * char_size if iv.nil?
  cipher = Mcrypt.new :"rijndael_#{block_size}", :ecb, key

  xor = iv
  char_array.map do |elem|
    xord = raw_xor(elem, xor)
    encrypted_text = cipher.encrypt(xord)
    xor = encrypted_text
  end.join
end

def decrypt(text, key, iv = nil, block_size = 128)
  char_size = block_size / 8
  char_array = text.chars.each_slice(char_size).map { |arr| arr.join }
  iv = "\x00" * char_size if iv.nil?
  cipher = Mcrypt.new :"rijndael_#{block_size}", :ecb, key

  xor = iv
  char_array.map do |elem|
    decrypted = cipher.decrypt(elem)
    xord = raw_xor(xor, decrypted)

    xor = elem
    xord
  end.join
end
