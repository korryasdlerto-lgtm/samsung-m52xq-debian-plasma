import QtQuick 2.15

import org.kde.plasma.private.mobileshell.quicksettingsplugin as QS
import org.kde.plasma.plasma5support as P5Support

// M52XQ (Debian Plasma, 2026-11-21): the "Speakerphone" app as a tile, like the Speakerphone tile of Debian Phosh в6.
// Tap: /usr/local/bin/m52xq-speakerphone (during a Telegram call earpiece -> loud speaker -> USB headset / Bluetooth ->
// earpiece; outside a call it only says so). Shows the route of m52xq-audio-route, highlighted during a Telegram call
// ($XDG_RUNTIME_DIR/m52xq-voip-active of m52xq-voip-audio). Polled every 5 s like the GPS and NFC tiles.
QS.QuickSetting {
    id: root

    property string route: ""
    property bool inCall: false
    property bool busy: false

    readonly property string statusCmd: "sh -c 'r=$(/usr/local/bin/m52xq-audio-route status 2>/dev/null); [ -e \"$XDG_RUNTIME_DIR/m52xq-voip-active\" ] && c=1 || c=0; echo \"$r $c\"'"

    text: i18n("Speakerphone")
    icon: route === "earpiece" ? "call-start-symbolic"
        : route === "usb" ? "audio-headset-symbolic"
        : route === "bt" ? "bluetooth-active-symbolic"
        : "audio-speakers-symbolic"
    enabled: inCall
    status: busy ? "…"
        : route === "earpiece" ? i18n("Earpiece")
        : route === "usb" ? i18n("USB headset")
        : route === "bt" ? i18n("Bluetooth")
        : i18n("Loud speaker")

    function toggle() {
        busy = true
        runner.connectSource("/usr/local/bin/m52xq-speakerphone")
    }

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (source, data) => {
            if (source === root.statusCmd) {
                const f = (data["stdout"] || "").trim().split(" ")
                if (f.length === 2) {
                    root.route = f[0]
                    root.inCall = f[1] === "1"
                }
            } else {
                root.busy = false
                connectSource(root.statusCmd)
            }
            disconnectSource(source)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!root.busy) runner.connectSource(root.statusCmd)
    }
}
