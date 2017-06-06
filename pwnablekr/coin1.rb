require 'socket'

def process(socket, coins, _)
  coins = coins.to_i
  s = 0
  e = coins - 1

  loop do
    m = (s + e) / 2
    msg = (s..m).to_a.join ' '
    send socket, msg

    res = socket.gets

    if res[-2] == '9'
      # Coin is in first half
      e = m
    elsif res[-2] == '0'
      # Coin is in second half
      s = m + 1
    else
      puts res
      break
    end
  end
end

s = TCPSocket.open 'pwnable.kr', 9007

loop do
  line = s.gets
  puts line

  break if line.to_s.empty?

  match = /^N=(.*) C=(.*)/.match line
  unless match.nil?
    process(s, match[1], match[2])
  end
end
