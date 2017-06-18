import random
import re
import json
import base64
import zlib
import click
from gmpy2 import *

with click.open_file('rzt.pub', 'rb') as key_file:
  key = re.sub("\-{5}(\w+\s){3}\w+\-{5}\n", "", key_file.read())

pub = json.loads(zlib.decompress(base64.b64decode(key.replace('\n', ''))))
pub = [mpz(i) for i in pub]

q = max(pub)
q_found = False
wstart_r_map = {}

while not q_found:
  print(q)
  wstart_r_map = {}

  for wstart in range(2, 10001):
    try:
      wstart_r_map[wstart] = divm(pub[0], wstart, q)
    except ZeroDivisionError:
      pass

  #print(wstart_r_map)
  #import pdb; pdb.set_trace()

  for idx, item in enumerate(pub):
    if idx + 1 == len(pub):
      break

    for wstart, r in wstart_r_map.iteritems():
      total = sum([divm(pub[index], r, q) for index in range(idx + 1)])
      min_w = total + 1
      max_w = 2 * total

      try:
        next_pub = divm(pub[idx + 1], r, q)
        if not (min_w <= next_pub and next_pub <= max_w):
          wstart_r_map[wstart] = None
      except ZeroDivisionError:
        wstart_r_map[wstart] = None

    wstart_r_map = {k: wstart_r_map[k] for k in list(wstart_r_map) if wstart_r_map[k] is not None}
    if len(wstart_r_map) == 0:
      break

  if len(wstart_r_map) != 0:
    q_found = True
  else:
    q += 1

print(wstart_r_map)
wstart = list(wstart_r_map)[0]
r = wstart_r_map[wstart]

w = [divm(p, r, q) for p in pub]

print(w, q, r)
