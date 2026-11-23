#!/usr/bin/python3
# m52xq: Telegram crashed when the camera was switched off / on in a call: the race checks of tg_owt video_capture_v4l2.cc
# (CaptureProcess, line 418; destructor, line 109) abort. Both "tbnz w0, #0" that lead to the abort become "nop" (8 bytes).
# usage: telegram-desktop-5.7.2-m52xq-camera-patch.py <original telegram-desktop 5.7.2+ds-6 arm64> <output>
import hashlib, sys
ORIG, NEW = '72ff8e363776d6bc582a6d2da27ddd2e', 'd1ec1967d009f3c29fdb97021e9e9d18'
NOP = bytes.fromhex('1f2003d5')
EDITS = {70143220: bytes.fromhex('40120037'), 70145588: bytes.fromhex('40030037')}   # file offset: original bytes
b = bytearray(open(sys.argv[1], 'rb').read())
if hashlib.md5(b).hexdigest() != ORIG: sys.exit('not the 5.7.2+ds-6 arm64 binary, nothing written')
for o, old in EDITS.items():
    if bytes(b[o:o+4]) != old: sys.exit('unexpected bytes at %d' % o)
    b[o:o+4] = NOP
if hashlib.md5(b).hexdigest() != NEW: sys.exit('result md5 differs')
open(sys.argv[2], 'wb').write(b)
print(sys.argv[2], NEW)
