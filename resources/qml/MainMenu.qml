import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
	id: root
	state: "visible"

	property alias backgroundColor: background.color

	function disappear() { root.state = "retracted" }
	function appear() { root.state = "visible"; mainButtons.reset() }
	function appearNow() { root.state = ""; root.appear() }

	signal quitButtonPressed()
	signal singleplayerEasyPressed()

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
		state: "normal"
		width: parent.width/3

		function moveAside() { mainButtons.state = "aside" }
		function moveBack() { mainButtons.state = "normal" }
		function reset() {
			mainButtons.moveBack()
			singleplayerTypes.disappear()
			multiplayerTypes.disappear()
		}

		Button {
			id: singleplayerButton
			text: "Singleplayer"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { mainButtons.moveAside(); singleplayerTypes.appear()  }
		}

		Button {
			id: multiplayerButton
			text: "Multiplayer"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { mainButtons.moveAside(); multiplayerTypes.appear() }
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

		states: [
			State {
				name: "normal"
				PropertyChanges { target: mainButtons; x: parent.width/2 - width/2 }
			},
			State {
				name: "aside"
				PropertyChanges { target: mainButtons; x: parent.width/3 - width/2 - 10}
			}
		]

		transitions: [
				Transition {
					from: "normal"; to: "aside"
					NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 500 }
				},
			Transition {
				from: "aside"; to: "normal"
				SequentialAnimation {
					NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 500 }
					ScriptAction { script: { mainButtons.reset() } }
				}
			}
		]

	}

	ColumnLayout {
		id: singleplayerTypes
		visible: false

		width: parent.width/6
		anchors.left: mainButtons.right
		anchors.leftMargin: 10

		x: 2*parent.width/3 - width/2
		y: mainButtons.y + singleplayerButton.y + singleplayerButton.height/2 - height/2

		spacing: 2

		function appear() { singleplayerTypes.visible = true }
		function disappear() { singleplayerTypes.visible = false }

		Button {
			text: "Easy"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { root.singleplayerEasyPressed() }
		}

		Button {
			text: "Normal"
			Layout.fillHeight: true
			Layout.fillWidth: true
		}

		Button {
			text: "Back"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { mainButtons.moveBack() }
		}
	}

	ColumnLayout {
		id: multiplayerTypes
		visible: false

		width: parent.width/6
		anchors.left: mainButtons.right
		anchors.leftMargin: 10

		x: 2*parent.width/3 - width/2
		y: mainButtons.y + multiplayerButton.y + multiplayerButton.height/2 - height/2

		spacing: 2

		function appear() { multiplayerTypes.visible = true }
		function disappear() { multiplayerTypes.visible = false }

		Button {
			text: "Classic"
			Layout.fillHeight: true
			Layout.fillWidth: true
		}

		Button {
			text: "Extreme!"
			Layout.fillHeight: true
			Layout.fillWidth: true
		}

		Button {
			text: "Back"
			Layout.fillHeight: true
			Layout.fillWidth: true
			onClicked: { mainButtons.moveBack() }
		}
	}

	Rectangle {
		id: sideHider
		color: background.color

		width: parent.width/3
		height: parent.height

		x: 2*parent.width/3 + 5
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
