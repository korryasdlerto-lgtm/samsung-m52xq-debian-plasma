#!/bin/sh
# M52XQ (Debian Plasma в5, 2026-11-22): do not sleep with a Wi-Fi that has lost its access point.
# When the AP disappears (router off, DFS channel switch: "CTRL-EVENT-BEACON-LOSS", "Ignoring ECSA ... considered stuck")
# and the phone then suspends with WoW armed, the WCN6750 firmware does not come back on the resume ("timed out while
# waiting for wow wakeup completion" x3, "failed to resume hif: -110", WPSS watchdog / crash loop) and only a reboot
# brings Wi-Fi back (seen 20.11 on Debian Phosh, 22.11 19:36 and 20:18 here).
# pre:  Wi-Fi radio on, wlan0 not associated -> unload ath11k_ahb (WPSS shut down cleanly, as the Wi-Fi tile does).
# post: load it again through m52xq-wifi-hw on (BT rebind + ath11k_ahb + autoconnect), in the background;
#       still not connected 20 s later -> nmcli dev connect wlan0 once.
F=/run/m52xq-wifi-lost
U=m52xq-wifi-lost-restore
case "$1" in
pre)
	# a restore from the previous wake-up still running: let it finish before deciding (max 60 s)
	i=0
	while [ $i -lt 60 ] && systemctl -q is-active $U 2>/dev/null; do sleep 1; i=$((i + 1)); done
	lsmod | grep -q '^ath11k_ahb' || exit 0
	[ -e /sys/class/net/wlan0 ] || exit 0
	# own hotspot (wlan1 AP, wlan0 unmanaged on purpose): leave it alone
	systemctl -q is-active m52xq-hotspot.service 2>/dev/null && exit 0
	[ "$(nmcli radio wifi 2>/dev/null)" = enabled ] || exit 0
	IW=$(command -v iw) || exit 0
	"$IW" dev wlan0 link 2>/dev/null | grep -q '^Connected to' && exit 0
	logger -t m52xq-wifi-lost "wlan0 not associated before the suspend: unloading ath11k_ahb"
	modprobe -r ath11k_ahb && touch $F
	;;
post)
	[ -e $F ] || exit 0
	rm -f $F
	logger -t m52xq-wifi-lost "resume: loading Wi-Fi again"
	# NetworkManager may keep the connection blocked after the failed activations of the lost AP (or after a manual
	# disconnect): if wlan0 is still not connected 20 s after the load, ask it once to connect the best saved network
	systemd-run --no-block --collect --unit=$U /bin/sh -c '/usr/local/sbin/m52xq-wifi-hw on >/dev/null 2>&1; sleep 20
		nmcli -t -f DEVICE,STATE dev | grep -q "^wlan0:connected$" && exit 0
		logger -t m52xq-wifi-lost "wlan0 not connected 20 s after the load: nmcli dev connect wlan0"
		nmcli dev connect wlan0 >/dev/null 2>&1; exit 0' >/dev/null 2>&1
	;;
esac
exit 0
