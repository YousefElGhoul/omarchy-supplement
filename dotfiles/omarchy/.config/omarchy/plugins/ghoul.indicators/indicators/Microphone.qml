import QtQuick
import Quickshell.Services.Pipewire
import qs.Ui

BarIndicator {
  id: root

  readonly property var source: Pipewire.defaultAudioSource
  readonly property bool muted: source && source.audio ? source.audio.muted : true
  readonly property real volume: source && source.audio ? source.audio.volume : 0
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property var activeStreams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i]
      if (node && node.isStream && node.isSink === false && !node.audio?.muted) list.push(node)
    }
    return list
  }
  readonly property bool inUse: activeStreams.length > 0 && !muted

  active: muted || inUse
  activeText: muted ? "󰍭" : "󰍬"
  inactiveText: "󰍬"
  activeTooltipText: muted ? "Microphone muted - click to unmute" : "Microphone in use - click to mute"
  inactiveTooltipText: "Microphone live - click to mute"
  useActiveColor: inUse

  PwObjectTracker { objects: root.source ? [root.source] : [] }

  onPressed: function(button) {
    if (button === Qt.MiddleButton) root.bar.run("omarchy-shell shell toggle omarchy.audio")
    else if (root.source && root.source.audio) root.source.audio.muted = !root.source.audio.muted
  }

  onWheelMoved: function(delta) {
    if (!root.source || !root.source.audio) return
    var step = 0.05
    root.source.audio.volume = Math.max(0, Math.min(1, root.volume + (delta > 0 ? step : -step)))
  }
}
