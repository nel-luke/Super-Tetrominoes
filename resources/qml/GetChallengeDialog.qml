import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15


Item {
	id: root
	state: "deactivated"

	property int time_left: 9
	property string username: ""

	function appear(username) { root.username = username; root.state = "activated" }
	function disappear() { root.state = "deactivated"; root.username = "" }

	function openDialog() {
		innerBox.visible = true
		shadow.visible = true
		declineTimer.start()
	}

	function closeDialog() {
		declineTimer.stop()
		innerBox.visible = false
		shadow.visible = false
		root.time_left = 9
	}

	signal acceptPressed(var username)
	signal declinePressed()

	Timer {
		id: declineTimer
		interval: 1000
		repeat: true
		onTriggered: { if (root.time_left-- === 0) root.declinePressed() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: "black"
		opacity: 0.8
	}

	MouseArea { anchors.fill: parent; hoverEnabled: true }

	Rectangle {
		id: innerBox
		visible: false

		width: parent.width * 0.4
		height: parent.height/5
		radius: 5
		anchors.centerIn: parent
		color: Material.primary

		Column {
			width: parent.width * 0.9
			height: parent.height * 0.8
			anchors.centerIn: parent

			Label {
				width: parent.width
				fontSizeMode: Text.HorizontalFit
				anchors.horizontalCenter: parent.horizontalCenter
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignBottom
				text: "Challenge request from"
				color: "white"
				font.bold: true
				font.pointSize: 34
			}
			Label {
				height: parent.height * 0.35
				fontSizeMode: Text.VerticalFit
				anchors.horizontalCenter: parent.horizontalCenter
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignTop
				font.bold: true
				font.pointSize: 50
				color: Material.background
				text: root.username
			}
			Row {
				width: parent.width * 0.8
				height: parent.height/5
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: 4

				Button {
					width: parent.width / 2
					text: "Accept"
					onClicked: { root.acceptPressed(root.username) }
				}
				Button {
					width: parent.width / 2
					text: "Decline (" + root.time_left + ")"
					onClicked: { root.declinePressed() }
				}
			}
		}

		states: [
			State {
				name: "invisible"
				PropertyChanges { target: innerBox; width: 1; height: 1 }
			},
			State {
				name: "visible"
				PropertyChanges { target: innerBox; width: parent.width/3; height: parent.height/5 }
			}

		]
	}

	DropShadow {
		id: shadow
		visible: false
		anchors.fill: innerBox
		horizontalOffset: 3
		verticalOffset: 3
		radius: 8.0
		samples: 17
		color: "#80000000"
		source: innerBox
	}

	states: [
		State {
			name: "deactivated"
			PropertyChanges { target: root; visible: false; focus: false }
			PropertyChanges { target: background; opacity: 0 }
		},
		State {
			name: "activated"
			PropertyChanges { target: root; visible: true; focus: true }
			PropertyChanges { target: background; opacity: 0.75 }
		}
	]
	transitions: [
		Transition {
			from: "deactivated"; to: "activated"
			SequentialAnimation {
				PropertyAnimation { properties: "visible, focus" }
				NumberAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: 250 }
				PauseAnimation { duration: 100 }
				ScriptAction { script: { root.openDialog() } }
			}
		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				ScriptAction { script: { root.closeDialog() } }
				PauseAnimation { duration: 100 }
				NumberAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: 500 }
				PropertyAnimation { properties: "visible, focus" }
				ScriptAction { script: { } }
			}
		}
	]
}
