# ???
require 'digest'
require 'gmp'

hash = Digest::SHA1.hexdigest('hi mom')
asn = '3021300906052b0e03021a05000414'

f_blocks = 1
loop do
  prefix = '0001' + 'ff' * f_blocks + '00' + asn + hash
  break if prefix.length > 128
  forged = prefix.ljust(128, '0')

  forged_i = forged.to_i(16)
  res = GMP::Z.new(forged_i - 1).root(3) + 1

  check = (res ** 3).to_i.to_s(16).rjust(128, '0')
  if check.start_with?(prefix)
    puts check
    break
  end

  f_blocks += 1
end

sol = "\x01BT\x83\xb3\xdc\xac\x9b~j\xa9\xb4qt\xca\x8e\x1f\x8e\xcdwM\x8e\x0eOGg\xf4>\xf6\xef-io\x18s:3J\n\x9e\x11\xac\xf1".unpack1('H*').to_i(16)
puts (sol ** 3).to_s(16).rjust(128, '0')
