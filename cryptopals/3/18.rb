require 'mcrypt'
require 'base64'

def raw_xor(string1, string2)
  len = [string1.length, string2.length].min
  string1.bytes.zip(string2.bytes).first(len).map { |a, b| a ^ b }.pack('c*')
end

def dec_to_ascii(int)
  bin = int.to_s(2)
  padded_length = (bin.length / 8.0).ceil * 8
  bin.rjust(padded_length, '0').scan(/......../).map do |bin_str|
    bin_str.to_i(2).chr
  end.join
end

def ctr(text, key, nonce = "\x00" * 8)
  cipher = Mcrypt.new(:rijndael_128, :ecb, key)

  text.chars.each_slice(16).each_with_index.map do |blk, idx|
    counter = dec_to_ascii(idx).rjust(8, "\x00").reverse
    raw_xor(blk.join, cipher.encrypt(nonce + counter))
  end.join
end

# puts ctr(Base64::decode64('L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='), 'YELLOW SUBMARINE', "\x00" * 8)
