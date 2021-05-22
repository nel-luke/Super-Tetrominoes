import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
	id: root
	state: "visible"

	property alias backgroundColor: background.color

	function disappear() { root.state = "retracted" }
	function appear() { root.state = "visible" }
	function appearNow() { root.state = ""; root.appear() }

	signal localMultiplayerPressed()
	signal onlineMultiplayerPressed()
	signal quitButtonPressed()

	signal afterDisappear()
	signal afterAppear()

	Rectangle {
		id: background
		anchors.fill: parent
	}

	ColumnLayout {
		id: mainButtons
		spacing: 2
		y: parent.height/2 - height/2
		width: parent.width/3
		anchors.horizontalCenter: parent.horizontalCenter

		Button {
			text: "Play Split-Screen"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { root.localMultiplayerPressed() }
		}

		Button {
			text: "Play Online"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { root.onlineMultiplayerPressed() }
		}

		Button {
			text: "Credits"
			Layout.fillHeight: true
			Layout.fillWidth: true
		}

		Button {
			text: "Quit"
			Layout.fillWidth: true
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
						NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
						PropertyAnimation { properties: "visible, focus" }
						ScriptAction { script: { root.afterDisappear() } }
					}
			},
		Transition {
				from: "retracted"; to: "visible"
				SequentialAnimation {
					PropertyAnimation { properties: "visible, focus" }
					NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
					ScriptAction { script: { root.afterAppear() } }
				}
		}
	]
}
