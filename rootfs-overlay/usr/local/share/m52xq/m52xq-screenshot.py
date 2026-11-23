# M52XQ (Debian Plasma Mobile): screenshot of the whole screen through KWin org.kde.KWin.ScreenShot2.
# KWin serves ScreenShot2 only to executables listed in a desktop file with
# X-KDE-DBUS-Restricted-Interfaces=org.kde.KWin.ScreenShot2, so this script runs with the python copy
# /usr/local/bin/m52xq-screenshot-py (desktop file /usr/local/share/applications/m52xq-screenshot.desktop).
# usage: m52xq-screenshot-py /usr/local/share/m52xq/m52xq-screenshot.py <out.png> [--notify]
# --notify: the same notification as the Plasma Mobile screenshot quick setting (screenshotutil.cpp: KNotification
# "captured" of plasma_mobile_quicksetting_screenshot, title "New Screenshot", the file as URL -> preview), texts from
# its catalog plasma_org.kde.plasma.quicksetting.screenshot in the session language.
import gettext
import os
import struct
import sys
import zlib

import gi
gi.require_version('Gio', '2.0')
from gi.repository import Gio, GLib


def png(path, width, height, rows):
	def chunk(kind, data):
		return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
	raw = b''.join(b'\0' + r for r in rows)
	with open(path, 'wb') as f:
		f.write(b'\x89PNG\r\n\x1a\n')
		f.write(chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)))
		f.write(chunk(b'IDAT', zlib.compress(raw, 6)))
		f.write(chunk(b'IEND', b''))


def main(out):
	bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
	r, w = os.pipe()
	fds = Gio.UnixFDList.new_from_array([w])
	reply, _ = bus.call_with_unix_fd_list_sync(
		'org.kde.KWin', '/org/kde/KWin/ScreenShot2', 'org.kde.KWin.ScreenShot2', 'CaptureActiveScreen',
		GLib.Variant('(a{sv}h)', ({'native-resolution': GLib.Variant('b', True)}, 0)),
		GLib.VariantType('(a{sv})'), Gio.DBusCallFlags.NONE, 30000, fds, None)
	# the fd list owns w now (closed with it)
	del fds
	meta = reply.unpack()[0]
	data = b''
	with os.fdopen(r, 'rb') as f:
		while True:
			b = f.read(1 << 20)
			if not b:
				break
			data += b
	width, height, stride, fmt = meta['width'], meta['height'], meta['stride'], meta.get('format', 0)
	# QImage::Format_RGB32 (4) / ARGB32 (5) / ARGB32_Premultiplied (6): 0xAARRGGBB = B G R A in memory;
	# Format_RGBX8888 (16) / RGBA8888 (17) / RGBA8888_Premultiplied (18): R G B A in memory (KWin 6.8 on the M52)
	if fmt in (4, 5, 6):
		order = (2, 1, 0)
	elif fmt in (16, 17, 18):
		order = (0, 1, 2)
	else:
		sys.exit('unsupported QImage format %d' % fmt)
	rows = []
	for y in range(height):
		line = data[y * stride:y * stride + width * 4]
		rgb = bytearray(width * 3)
		rgb[0::3] = line[order[0]::4]
		rgb[1::3] = line[order[1]::4]
		rgb[2::3] = line[order[2]::4]
		rows.append(bytes(rgb))
	png(out, width, height, rows)
	print(out)
	if '--notify' in sys.argv:
		notify(bus, out)


def notify(bus, path):
	t = gettext.translation('plasma_org.kde.plasma.quicksetting.screenshot', fallback=True)
	title = t.gettext('New Screenshot')
	text = t.gettext('New screenshot saved to %1').replace('%1', path)
	hints = {
		'x-kde-appname': GLib.Variant('s', 'plasma_mobile_quicksetting_screenshot'),
		'x-kde-eventId': GLib.Variant('s', 'captured'),
		'x-kde-urls': GLib.Variant('as', [Gio.File.new_for_path(path).get_uri()]),
	}
	bus.call_sync('org.freedesktop.Notifications', '/org/freedesktop/Notifications', 'org.freedesktop.Notifications',
	              'Notify', GLib.Variant('(susssasa{sv}i)', ('Plasma', 0, 'preferences-system-windows-effect-screenshot',
	                                                         title, text, [], hints, -1)),
	              GLib.VariantType('(u)'), Gio.DBusCallFlags.NONE, 10000, None)


if __name__ == '__main__':
	main(sys.argv[1])
