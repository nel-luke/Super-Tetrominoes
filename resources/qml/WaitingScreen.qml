import QtQuick 2.0

Item {
	id: root
	state: "activated"

	property alias background_color: background.color

	function activate() { root.state = "activated" }
	function deactivate() { root.state = "deactivated" }

	signal done()

	Rectangle {
		id: background
		anchors.fill: parent
		opacity: 0.75
	}
	Text {
		id: countDownText
		anchors.centerIn: parent
		width: parent.width * 0.8
		height: parent.height / 3
		horizontalAlignment: Text.AlignHCenter
		visible: true
		font.bold: true
		fontSizeMode: Text.HorizontalFit
		font.pointSize: 512
		color: "white"
		text: "Waiting for opponent..."
	}

	states: [
		State {
			name: "deactivated"
			PropertyChanges { target: root; visible: false }
			PropertyChanges {	target: background; opacity: 0	}
		},
		State {
			name: "activated"
			PropertyChanges { target: background; opacity: 0.75 }
		}
	]
	transitions: [
//		Transition {
//			from: "deactivated"; to: "activated"
//			SequentialAnimation {
//				PropertyAnimation { properties: "visible" }
//				NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 500 }
//				PauseAnimation { duration: 500 }
//				ScriptAction { script: { root.startCounting() } }
//			}
//		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				ScriptAction { script: { root.done() } }
				NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 500 }
				PropertyAnimation { properties: "visible" }
			}
		}

	]
}
