import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs.Commons
import qs.Ui

// Kuromi power menu: banner, lock / logout / reboot / shutdown, last login + uptime.
// Keys: ←/→ or h/l to move, 1-4 to pick, Enter to run, Esc to close.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property int selected: 0
  property string lastLogin: "…"
  property string uptime: "…"
  property string host: "…"
  readonly property string user: Quickshell.env("USER")

  readonly property var actions: [
    { icon: "󰌾", label: "Lock", command: ["omarchy", "system", "lock"] },
    { icon: "󰍃", label: "Logout", command: ["omarchy", "system", "logout"] },
    { icon: "󰜉", label: "Reboot", command: ["omarchy", "system", "reboot"] },
    { icon: "󰐥", label: "Shutdown", command: ["omarchy", "system", "shutdown"] }
  ]

  readonly property string fontFamily: Style.fontFamily
  readonly property color accent: Color.accent
  readonly property color background: Color.menu.background
  readonly property color foreground: Color.menu.text
  readonly property color selectedText: Color.menu.selectedText
  readonly property color tile: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.06)
  readonly property color tileHover: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
  readonly property int radius: Math.max(6, Style.cornerRadius)

  readonly property int cardWidth: Math.min(Style.space(560), panel.width - Style.gapsOut * 4)
  readonly property int pad: Style.space(10)
  readonly property int gap: Style.space(8)

  function open(payloadJson) {
    root.selected = 0
    root.opened = true
    infoProc.running = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "rualisher.powermenu")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function run(index) {
    var action = root.actions[index]
    if (!action) return
    root.dismiss()
    Quickshell.execDetached(action.command)
  }

  Process {
    id: infoProc
    command: ["sh", "-c",
      "date -d \"$(lastlog2 -u \"$USER\" | tail -1 | awk '{print $4, $5, $8, $6}')\" '+%b %d %H:%M' 2>/dev/null || echo unknown;" +
      "uptime -p | sed 's/^up //';" +
      "cat /etc/hostname"]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = String(text || "").trim().split("\n")
        root.lastLogin = lines[0] || "unknown"
        root.uptime = lines[1] || "unknown"
        root.host = lines[2] || "localhost"
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "rualisher-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: Color.menu.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    Rectangle {
      id: card
      anchors.centerIn: parent
      width: root.cardWidth
      height: column.implicitHeight
      radius: root.radius
      color: root.background
      border.color: root.accent
      border.width: 1

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
          var n = root.actions.length
          if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
            root.dismiss()
          } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H || event.key === Qt.Key_Backtab) {
            root.selected = (root.selected + n - 1) % n
          } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_Tab) {
            root.selected = (root.selected + 1) % n
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.run(root.selected)
          } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_4) {
            root.selected = event.key - Qt.Key_1
          } else {
            return
          }
          event.accepted = true
        }
      }

      Column {
        id: column
        width: parent.width
        spacing: 0

        // Banner with the user@host chip.
        Item {
          width: parent.width
          height: Math.round(width * 11 / 32)

          ClippingRectangle {
            anchors.fill: parent
            anchors.margins: 1
            topLeftRadius: root.radius - 1
            topRightRadius: root.radius - 1
            color: "transparent"

            Image {
              anchors.fill: parent
              source: Qt.resolvedUrl("banner.jpg")
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              smooth: true
            }
          }

          Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: root.pad
            width: chipText.implicitWidth + root.pad * 2
            height: chipText.implicitHeight + root.pad
            radius: root.radius
            color: Qt.rgba(root.background.r, root.background.g, root.background.b, 0.92)

            Text {
              id: chipText
              anchors.centerIn: parent
              text: "  " + root.user + "@" + root.host
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
            }
          }
        }

        // Action tiles.
        Row {
          id: tiles
          x: root.pad
          topPadding: root.pad
          bottomPadding: root.pad
          spacing: root.gap
          readonly property int tileWidth: Math.floor((card.width - root.pad * 2 - root.gap * (root.actions.length - 1)) / root.actions.length)

          Repeater {
            model: root.actions

            Rectangle {
              required property var modelData
              required property int index
              readonly property bool active: root.selected === index

              width: tiles.tileWidth
              height: Math.round(tiles.tileWidth * 0.6)
              radius: root.radius
              color: active ? root.accent : (hover.containsMouse ? root.tileHover : root.tile)

              Behavior on color { ColorAnimation { duration: 120 } }

              Text {
                anchors.centerIn: parent
                text: modelData.icon
                color: active ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Math.round(tiles.tileWidth * 0.26)
              }

              MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selected = index
                onClicked: root.run(index)
              }
            }
          }
        }

        // Footer: last login + uptime.
        Rectangle {
          width: parent.width
          height: footerText.implicitHeight + root.pad * 2
          color: "transparent"

          Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
          }

          Text {
            id: footerText
            anchors.centerIn: parent
            text: "  Last Login: " + root.lastLogin + "  |  󰔟  Uptime: " + root.uptime
            color: root.foreground
            opacity: 0.85
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
        }
      }
    }
  }
}
