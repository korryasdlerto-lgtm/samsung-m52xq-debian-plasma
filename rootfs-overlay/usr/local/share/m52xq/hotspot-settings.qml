// M52XQ (Debian Plasma, 2026-11-21): settings of our Wi-Fi hotspot (long press on the "Hotspot" tile): network name and
// password of m52xq-hotspot.service. Input goes to m52xq-hotspot-config URI-encoded (no shell characters).
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support as P5Support

Kirigami.ApplicationWindow {
    id: win
    title: "Hotspot"
    width: 360
    height: 720
    visible: true

    property string message: ""

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (source, data) => {
            const out = (data["stdout"] || "").replace(/\n$/, "")
            if (source.indexOf(" get") >= 0) {
                const l = out.split("\n")
                ssidField.text = l[0] || ""
                passField.text = l.length > 1 ? l[1] : ""
            } else {
                win.message = out.indexOf("ok") === 0 ? "Saved" : out.replace(/^error: /, "")
            }
            disconnectSource(source)
        }
    }

    Component.onCompleted: runner.connectSource("/usr/local/bin/m52xq-hotspot-config get")

    pageStack.initialPage: Kirigami.ScrollablePage {
        title: "Hotspot"
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            QQC2.Label { text: "Network name"; Layout.fillWidth: true }
            QQC2.TextField {
                id: ssidField
                Layout.fillWidth: true
                maximumLength: 32
            }
            QQC2.Label { text: "Password (8 to 63 characters)"; Layout.fillWidth: true }
            RowLayout {
                Layout.fillWidth: true
                QQC2.TextField {
                    id: passField
                    Layout.fillWidth: true
                    maximumLength: 63
                    echoMode: showPass.checked ? TextInput.Normal : TextInput.Password
                }
                QQC2.CheckBox { id: showPass; text: "Show" }
            }
            QQC2.Button {
                text: "Save"
                enabled: ssidField.text.length > 0 && passField.text.length >= 8
                onClicked: {
                    win.message = "…"
                    runner.connectSource("/usr/local/bin/m52xq-hotspot-config set \"" + encodeURIComponent(ssidField.text) +
                                         "\" \"" + encodeURIComponent(passField.text) + "\" #" + Date.now())
                }
            }
            QQC2.Label {
                text: win.message
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            QQC2.Label {
                text: "A running hotspot restarts with the new name and password."
                wrapMode: Text.WordWrap
                opacity: 0.7
                Layout.fillWidth: true
            }
        }
    }
}
