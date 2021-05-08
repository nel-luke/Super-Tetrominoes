import QtQuick 2.0

Item {
	id: root
	state: "deactivated"

	property alias backgroundColor: background.color
	property int digit: 3

	function activate() { root.state = "activated" }
	function deactivate() { root.state = "deactivated" }

	function startCounting() {
		root.digit = 3
		countDownText.visible = true
		countDownTimer.start()
	}

	function count() {
		if (digit-- === 1) {
			countDownTimer.stop()
			countDownText.visible = false
			root.deactivate()
		}
	}

	signal done()

	Timer {
		id: countDownTimer
		interval: 1000
		repeat: true
		onTriggered: { root.count() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
	}

	Text {
		id: countDownText
		anchors.centerIn: parent
		visible: false
		font.bold: true
		font.pointSize: 128
		color: "white"
		text: root.digit
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
				NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 500 }
				PauseAnimation { duration: 500 }
				ScriptAction { script: { root.startCounting() } }
			}
		},
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
