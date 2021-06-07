import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15


Item {
	id: root
	state: "deactivated"

	property string username: ""

	property bool emit_signal: false

	function appear(username) { root.username = username; root.state = "activated"; timeoutTimer.start() }
	function disappear() { root.state = "deactivated"; root.username = ""; timeoutTimer.stop() }

	signal dialogClosed()

	function closeWithMessage(message, emit_signal) {
		indicator.visible = false
		root.emit_signal = emit_signal
		resultMessage.text = message
		resultMessage.visible = true
		closeTimer.start()
	}

	function openDialog() {
		innerBox.visible = true
		shadow.visible = true
	}

	function closeDialog() {
		innerBox.visible = false
		shadow.visible = false

		indicator.visible	= true
		resultMessage.visible = false

		if (root.emit_signal)
			root.dialogClosed()
	}

	Timer {
		id: closeTimer
		interval: 1000
		onTriggered: { root.disappear() }
	}

	Timer {
		id: timeoutTimer
		interval: 15000
		onTriggered: { root.closeWithMessage("Connection lost", false) }
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
				text: "Waiting for reply from"
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
			Item {
				width: parent.width * 0.8
				height: parent.height / 3
				anchors.horizontalCenter: parent.horizontalCenter

				Label {
					id: resultMessage
					visible: false
					width: parent.width
					fontSizeMode: Text.HorizontalFit
					anchors.horizontalCenter: parent.horizontalCenter
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignBottom
					color: "white"
					font.bold: true
					font.pointSize: 34
				}

				BusyIndicator {
					id: indicator
					running: true
					anchors.fill: parent
				}

//					Label {
//						width: parent.width * 0.95
//						height: parent.height * 0.95
//						anchors.centerIn: parent
//						horizontalAlignment: Text.AlignHCenter
//						verticalAlignment: Text.AlignVCenter
//						fontSizeMode: Text.Fit
//						font.bold: true
//						font.pointSize: 24
//						color: "white"
//						text: root.time_left
//					}
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
