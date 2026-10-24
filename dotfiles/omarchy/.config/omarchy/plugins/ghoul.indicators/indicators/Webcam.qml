import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  readonly property string controlScript: Quickshell.env("HOME")
    + "/.config/omarchy/plugins/ghoul.webcam/webcam-control"
  property int deviceCount: 0
  property bool canBlock: false
  property bool blocked: false
  property bool inUse: false

  active: blocked || inUse
  activeText: blocked ? "󰗟" : "󰄀"
  inactiveText: "󰄀"
  activeTooltipText: blocked
    ? "Webcam blocked system-wide - click to enable"
    : "Webcam in use - click to block system-wide"
  inactiveTooltipText: deviceCount === 0
    ? "No webcam detected"
    : canBlock
      ? "Webcam enabled - click to block system-wide"
      : "Webcam cannot be blocked by this device's driver"
  interactive: belongsInBlock && (effectiveActive || indicatorBlock === "inactive" || inactiveRevealed) && canBlock

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function updateStatus(raw) {
    var values = {}
    var lines = String(raw || "").trim().split("\n")
    for (var i = 0; i < lines.length; i++) {
      var pair = lines[i].split("=")
      if (pair.length === 2) values[pair[0]] = pair[1]
    }
    deviceCount = Number(values.devices || 0)
    canBlock = values.canBlock === "1"
    blocked = values.blocked === "1"
    inUse = values.active === "1"
  }

  Process {
    id: statusProcess
    command: [root.controlScript, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateStatus(text)
    }
  }

  Process {
    id: toggleProcess
    command: ["pkexec", root.controlScript, "toggle"]
    onExited: root.refresh()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  onPressed: function() {
    if (root.canBlock && !toggleProcess.running) toggleProcess.running = true
  }
}
