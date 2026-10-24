import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarIndicator {
  id: root

  readonly property string controlScript: Quickshell.env("HOME")
    + "/.config/omarchy/plugins/ghoul.keyboard/keyboard-control"
  property bool present: false
  property bool keyboardEnabled: true

  active: !keyboardEnabled
  activeText: "󰌐"
  inactiveText: "󰌌"
  activeTooltipText: "Laptop keyboard disabled - click to enable"
  inactiveTooltipText: present
    ? "Laptop keyboard enabled - click to disable"
    : "Built-in laptop keyboard not found"
  interactive: belongsInBlock && (effectiveActive || indicatorBlock === "inactive" || inactiveRevealed) && present

  function updateStatus(raw) {
    var values = {}
    var lines = String(raw || "").trim().split("\n")
    for (var i = 0; i < lines.length; i++) {
      var pair = lines[i].split("=")
      if (pair.length === 2) values[pair[0]] = pair[1]
    }
    present = values.present === "1"
    keyboardEnabled = values.enabled !== "0"
  }

  function run(action) {
    if (controlProcess.running) return
    controlProcess.command = [controlScript, action]
    controlProcess.running = true
  }

  Component.onCompleted: run("sync")

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: root.run("status")
  }

  Process {
    id: controlProcess
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateStatus(text)
    }
  }

  onPressed: function() {
    if (present) run("toggle")
  }
}
