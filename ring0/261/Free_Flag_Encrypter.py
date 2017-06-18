#!/usr/bin/env python2
#-*- coding:utf-8 -*-
#
# UMDCTF 2017 - Free Flag Encrypter Tool
import random
import click
import re
import json
import base64
import zlib

def r_int(a, b):
    r = random.SystemRandom()
    return r.randint(a, b)

def coprime(a, b):
    while b:
        a, b = b, a % b
    return a == 1

def minv(a, b):
    c = b
    x, y, u, v = 0, 1, 1, 0
    while a != 0:
        q, r = b // a, b % a
        m, n = x - u * q, y - v * q
        b, a, x, y, u, v = a, r, u, v, m, n
    return -1 if b != 1 else x % c

# Returns q, r. r in [3, q], q in [sum(w) + 1, 2sum(w)]
def get_num(w):
    r = q = sum(w) + r_int(1, sum(w))
    while not coprime(q, r):
        r = r_int(3, q)
    return q, r

# Returns an increasing sequence such that a_{n + 1} < 2sum(a_n)
def gen_seq(n):
    w = [r_int(2,10000)]
    for i in range(n - 1):
        w.append(r_int(sum(w) + 1, 2 * sum(w)))
    return w

def gen_keys(n, name):
    w = gen_seq(n)
    q, r = get_num(w)
    pub_key, priv_key = [ (r * i) % q for i in w], (w, q, r)

    # Write public key
    data = base64.b64encode(zlib.compress(json.dumps(pub_key, ensure_ascii = False)))
    with click.open_file(name + '.pub', 'wb') as f:
        f.write('-----BEGIN UMDCTF PUBLIC FFEKEY-----\n')
        for i in range(0, len(data), 50):
            f.write(data[i:i + 50] + '\n')
        f.write('-----END UMDCTF PUBLIC FFEKEY-----\n')

    # Write private key
    data = base64.b64encode(zlib.compress(json.dumps(priv_key, ensure_ascii = False)))
    with click.open_file(name, 'wb') as f:
        f.write('-----BEGIN UMDCTF PRIVATE FFEKEY-----\n')
        for i in range(0, len(data), 50):
            f.write(data[i:i + 50] + '\n')
        f.write('-----END UMDCTF PRIVATE FFEKEY-----\n')

def parse_key(f):
    with click.open_file(f, 'rb') as key_file:
        key = re.sub("\-{5}(\w+\s){3}\w+\-{5}\n", "", key_file.read())
    return json.loads(zlib.decompress(base64.b64decode(key.replace('\n',''))))

# encrypt message with key
def encrypt_flag(msg, key):
    bits = ''.join(format(ord(x), '08b') for x in msg)
    n = len(bits)

    # If the key is too small, exit
    if n > len(key):
        click.secho('ERROR: Key too small for message', fg = 'red', bold = True)
        raise click.Abort

    return str(sum([key[i] * int(bits[i]) for i in range(n)]))

def decrypt_flag(c, priv_key, sol = ''):
    w, q, r = priv_key
    w = w[::-1]
    s = minv(r, q)
    if s == -1:
        click.secho('ERROR: Invalid Key', fg = 'red', bold = True)
        raise click.Abort

    block = (c * s) % q
    for x in w:
        if x != block:
            sol += '1' if x < block else '0'
            if sol[-1] == '1':
                block -= x
        else:
            sol = ('1' + sol[::-1]).zfill(len(w))
            break
    return ''.join(chr(int(sol[i:i + 8], 2)) for i in range(0, len(sol), 8))

# Setup the cli arguments
@click.command(context_settings = dict(help_option_names = ['-h', '--help']))
@click.option('-g', '--genkeys', is_flag = True, default = False, help = 'Generate a public/private key pair')
@click.option('-d', '--decrypt', is_flag = True, default = False, help = 'Decrypt an FFE encrypted string')
@click.option('-e', '--encrypt', is_flag = True, default = False, help = 'Encrypt a flag message with FFE')
def main(genkeys, decrypt, encrypt):
    '''Free Flag Encrypter -- Safely store all of your flags for free! We use magic crypto that no one else does!'''

    # Generate key files
    if (genkeys):
        bits = click.prompt('Max message size in bits for key use', type = int)
        name = click.prompt('Enter desired key name')
        click.echo('Generating keys and saving to current directory...')
        gen_keys(bits, name)
        click.echo('Keys Generated!')

    # Decrypt a flag
    elif (decrypt):
        FILE = click.prompt('Enter the name of the private key file')
        ENC  = click.prompt('Enter your encrypted data', type = int)
        click.secho(decrypt_flag(ENC, parse_key(FILE)), fg = 'green', bold = True)

    # Encrypt a flag
    elif (encrypt):
        f = click.prompt('Enter the name of the public key file')
        MSG = click.prompt('Enter your data', type = str)
        click.secho(encrypt_flag(MSG, parse_key(f)), fg = 'blue', bold = True)

    # No option given
    else:
        click.secho('No option selected. See -h/--help for more information', fg = 'yellow', bold = True)
        raise click.Abort

if __name__ == '__main__':
    main()
