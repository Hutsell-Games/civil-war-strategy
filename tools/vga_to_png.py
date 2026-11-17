"""Convert the game's .VGA picture files to indexed PNG files with the same pixels.

Usage: python -I tools/vga_to_png.py <graphics folder> [--check]

A .VGA file is a BSAVE of an array that GET filled on SCREEN 12 (7 bytes of BSAVE header, then the
GET data): a word with the width, a word with the height, then for each row and each of the four
color planes ceil(width / 8) bytes. The array is larger than the picture; the rest is ignored.
Plane 0 is the low bit of the color number. The PNG holds the 16 colors of SCREEN 12 as QB64pe
gives them (its default palette, entries 0 to 15), and the color number of each pixel is its
palette index, so loading it with _LOADIMAGE(file$, 256) gives back the same numbers.

With --check each PNG is read back and compared with the .VGA file's pixels.
"""
import os
import struct
import sys
import zlib

# The 16 colors of SCREEN 12 in QB64pe (libqb.cpp, file_qb64_pal, entries 0 to 15).
PALETTE = [
    (0, 0, 0), (0, 0, 170), (0, 170, 0), (0, 170, 170),
    (170, 0, 0), (170, 0, 170), (170, 85, 0), (170, 170, 170),
    (85, 85, 85), (85, 85, 255), (85, 255, 85), (85, 255, 255),
    (255, 85, 85), (255, 85, 255), (255, 255, 85), (255, 255, 255),
]


def read_vga(path):
    data = open(path, 'rb').read()
    if data[0] != 0xFD:
        raise ValueError('not a BSAVE file: ' + path)
    body = data[7:]
    width, height = struct.unpack('<HH', body[:4])
    per_plane = (width + 7) // 8
    need = 4 + height * 4 * per_plane
    if need > len(body):
        raise ValueError('file too short: ' + path)
    # What follows the picture is the rest of the array: its 1,564 integers are twice the 1,564 bytes
    # that a 41 by 65 picture takes. It is leftover memory, and some files hold nonzero bytes there.
    rows = []
    pos = 4
    for _ in range(height):
        planes = []
        for _p in range(4):
            planes.append(body[pos:pos + per_plane])
            pos += per_plane
        row = []
        for x in range(width):
            byte, bit = x // 8, 7 - x % 8
            value = 0
            for p in range(4):
                value |= ((planes[p][byte] >> bit) & 1) << p
            row.append(value)
        rows.append(row)
    return width, height, rows


def chunk(kind, payload):
    body = kind + payload
    return struct.pack('>I', len(payload)) + body + struct.pack('>I', zlib.crc32(body) & 0xFFFFFFFF)


def write_png(path, width, height, rows):
    raw = b''.join(b'\x00' + bytes(row) for row in rows)
    plte = b''.join(bytes(c) for c in PALETTE)
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 3, 0, 0, 0))
    png += chunk(b'PLTE', plte)
    png += chunk(b'IDAT', zlib.compress(raw, 9))
    png += chunk(b'IEND', b'')
    open(path, 'wb').write(png)


def read_png(path):
    data = open(path, 'rb').read()
    pos, width, height, idat = 8, 0, 0, b''
    while pos < len(data):
        size, kind = struct.unpack('>I4s', data[pos:pos + 8])
        payload = data[pos + 8:pos + 8 + size]
        if kind == b'IHDR':
            width, height = struct.unpack('>II', payload[:8])
        elif kind == b'IDAT':
            idat += payload
        pos += 12 + size
    raw = zlib.decompress(idat)
    rows = []
    for y in range(height):
        line = raw[y * (width + 1):(y + 1) * (width + 1)]
        assert line[0] == 0
        rows.append(list(line[1:]))
    return width, height, rows


def main():
    folder = sys.argv[1]
    check = '--check' in sys.argv
    for name in sorted(os.listdir(folder)):
        if not name.upper().endswith('.VGA'):
            continue
        src = os.path.join(folder, name)
        dst = os.path.join(folder, name[:-4] + '.PNG')
        width, height, rows = read_vga(src)
        if check:
            same = read_png(dst) == (width, height, rows)
            print(name, width, 'x', height, 'png matches' if same else 'PNG DIFFERS')
            if not same:
                sys.exit(1)
        else:
            write_png(dst, width, height, rows)
            print(name, width, 'x', height, '->', os.path.basename(dst))


main()
