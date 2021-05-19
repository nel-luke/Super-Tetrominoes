import QtQuick 2.0

Item {
	id: root
	state: "deactivated"

	property alias backgroundColor: background.color
	property int digit: 3

	function activate(singleSource) { image.source = singleSource; root.state = "activated" }

	Rectangle {
		id: background
		anchors.fill: parent
	}

	Image {
		id: image
		anchors.centerIn: parent
		width: parent.width/3
		height: parent.height/3
	}

	states: [
		State {
			name: "deactivated"
			PropertyChanges {	target: root; opacity: 0; visible: false	}
		},
		State {
			name: "activated"
			PropertyChanges { target: root; opacity: 0.8; visible: true }
		}
	]

	transitions: [
		Transition {
			from: "deactivated"; to: "activated"
			SequentialAnimation {
				PropertyAnimation { properties: "visible" }
				NumberAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: 500 }
				PauseAnimation { duration: 500 }
				ScriptAction { script: { root.state = "deactivated" } }
			}
		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				NumberAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: 1000 }
				PropertyAnimation { properties: "visible" }
			}
		}

	]
}
