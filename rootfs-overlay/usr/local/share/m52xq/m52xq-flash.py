# M52XQ (Debian Plasma Mobile): white screen flash after a volume-key screenshot (like a camera flash):
# a fullscreen white GTK4 window that fades out in about 0.3 s, then quits.
import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gdk, Gtk, GLib

STEPS, STEP_MS = 10, 30


def activate(app):
	css = Gtk.CssProvider()
	css.load_from_string('window { background: white; }')
	Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
	win = Gtk.ApplicationWindow(application=app, decorated=False)
	win.set_can_target(False)
	win.fullscreen()
	win.present()
	left = [STEPS]

	def fade():
		left[0] -= 1
		win.set_opacity(left[0] / STEPS)
		if left[0] <= 0:
			app.quit()
			return False
		return True
	GLib.timeout_add(80, lambda: GLib.timeout_add(STEP_MS, fade) and False)


app = Gtk.Application(application_id='org.m52xq.ScreenshotFlash')
app.connect('activate', activate)
app.run(None)
