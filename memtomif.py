#!/usr/bin/env python3

import sys
import os


def listBig16(input):
    array = []
    cnt = 0
    with open(input, 'r') as f:
        l = f.readlines()
        for i in l:
            a = i.split()
            for j in a:
                if (cnt % 2 == 0):
                    array.append(j)
                else:
                    array.insert(-1, j)
                cnt += 1
    return array


def mifGen(input):
    addr = 0x0
    array = listBig16(input)  # convert to big endian
    cnt = 0
    buf = f'DEPTH=2048;\nWIDTH=16;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n\n{0:04x} :'
    for i in array:
        if (addr != 0) and ((addr % 8 == 0) and cnt % 2 == 0):
            buf += f';\n{addr:04x} :'

        if ((cnt % 2) == 0):
            buf += f' {i}'
            addr += 1
        else:
            buf += f'{i}'
        cnt += 1
    buf += ';\nEND;'
    with open(os.path.splitext(os.path.basename(input))[0] + ".mif", 'w') as f:
        f.write(buf)


if __name__ == "__main__":
    input = sys.argv[1]
    mifGen(input)
