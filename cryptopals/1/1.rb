require 'base64'

def hex_to_base64(text)
  (Base64::encode64 [text].pack('H*')).tr("\n", '')
end
