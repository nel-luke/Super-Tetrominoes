import QtQuick 2.0
import QtGraphicalEffects 1.15

Item {
	id: root
	state: "deactivated"

	property alias backgroundColor: background.color
	property int digit: 3

	function activate(singleSource) {
		background.visible = true
		fadedBackground.visible = false
		image.source = singleSource
		root.state = "activated"
	}

	function activateCancelEffects() {
		background.visible = false
		fadedBackground.visible = true
		root.state = "activated"
	}

	Rectangle {
		id: background
		anchors.fill: parent

		Image {
			id: image
			anchors.centerIn: parent
			width: parent.width/3
			height: parent.height/3
		}
	}

	RadialGradient {
		id: fadedBackground
		anchors.fill: parent
		horizontalRadius: width/2
		verticalRadius:  height*2
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#00000000" }
			GradientStop { position: 0.7; color: "#00000000" }
			GradientStop { position: 1.0; color: "white" }
		}
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
