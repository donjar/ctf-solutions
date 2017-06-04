def pkcs7(str, length)
  pad_length = length - str.length
  str + pad_length.chr * pad_length
end

p pkcs7 "YELLOW SUBMARINE", 20
