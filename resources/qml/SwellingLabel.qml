import QtQuick 2.0
import QtQuick.Controls 2.15

Label {
	id: root
	state: "deactivated"

	property real font_size

	function activate() { root.state = "activated" }

	signal done()

	states: [
		State {
			name: "deactivated"
			PropertyChanges {	target: root; font.pointSize: root.font_size	}
		},
		State {
			name: "activated"
			PropertyChanges { target: root; font.pointSize: root.font_size * 1.25 }
		}
	]

	transitions: [
		Transition {
			from: "deactivated"; to: "activated"
			SequentialAnimation {
				NumberAnimation { properties: "font.pointSize"; easing.type: Easing.OutQuad; duration: 100 }
				ScriptAction { script: { root.state = "deactivated" } }
			}
		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				NumberAnimation { properties: "font.pointSize"; easing.type: Easing.InQuad; duration: 200 }
				PauseAnimation { duration: 100 }
				ScriptAction { script: { root.done() } }
			}
		}

	]
}
