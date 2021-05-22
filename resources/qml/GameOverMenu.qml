import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
	id: root
	state: "retracted"

	property alias backgroundColor: background.color

	function disappear() { root.state = "retracted" }
	function appear(message) { bigText.text = message; root.state = "visible" }

	signal retryButtonPressed()
	signal quitButtonPressed()

	signal afterDisappear()

	Rectangle {
		id: background
		anchors.fill: parent
	}

	Column {
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: 2

		Label {
			id: bigText
			font.pointSize: 68
			color: "white"
		}

		Button {
				text: "Retry"
				onClicked: retryButtonPressed()
		}

		Button {
			text: "Quit to Menu"
			onClicked: quitButtonPressed()
		}
	}

	states:
		[ State {
				name: "retracted"
				PropertyChanges { target: root; y: -height; visible: false; focus: false }
			},
			State {
				name: "visible"
				PropertyChanges { target: root; y: 0; visible: true; focus: true }
			} ]

	transitions: [
		Transition {
				from: "visible"; to: "retracted"
				SequentialAnimation {
						ScriptAction { script: { root.afterDisappear() } }
						NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
						PropertyAnimation { properties: "visible, focus" }
				}
		},
		Transition {
			from: "retracted"; to: "visible"
			SequentialAnimation {
				PropertyAnimation { properties: "visible, focus" }
				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
			}
		}
	]
}
