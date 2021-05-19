import QtQuick 2.0
import QtQuick.Controls 2.15

Label {
	id: root
	state: "deactivated"

	required property real fontSize

	function activate() { root.state = "activated" }

	states: [
		State {
			name: "deactivated"
			PropertyChanges {	target: root; font.pointSize: root.fontSize	}
		},
		State {
			name: "activated"
			PropertyChanges { target: root; font.pointSize: root.fontSize*1.25 }
		}
	]

	transitions: [
		Transition {
			from: "deactivated"; to: "activated"
			SequentialAnimation {
				NumberAnimation { properties: "font.pointSize"; easing.type: Easing.OutQuad; duration: 100 }
				//PauseAnimation { duration: 100 }
				ScriptAction { script: { root.state = "deactivated" } }
			}
		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				NumberAnimation { properties: "font.pointSize"; easing.type: Easing.InQuad; duration: 200 }
			}
		}

	]
}
