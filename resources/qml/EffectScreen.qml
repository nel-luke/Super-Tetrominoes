import QtQuick 2.0
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
	id: root
	state: "deactivated"

	property alias backgroundColor: background.color
	property int repeat_shape_count: 0
	property int repeat_to_add: 0

	property int mix_controls_count: 0
	property int mix_to_add: 0

	function incrementRepeatShape() { root.repeat_to_add++ }
	function decrementRepeatShape() { root.repeat_to_add-- }

	function incrementMixControls() { root.mix_to_add++ }
	function decrementMixControls() { root.mix_to_add-- }

	function activate() {
		root.state = "activated"
	}

	function updateEffects() {
		root.serviceRepeat()
		root.serviceMix()
	}

	function serviceRepeat() {
		if (root.repeat_to_add > 0) {
			root.repeat_to_add--
			root.repeat_shape_count++
			repeatText.activate()
		} else if (root.repeat_to_add < 0) {
			root.repeat_to_add++
			root.repeat_shape_count--
			repeatText.activate()
		} else if (root.mix_to_add === 0) {
			root.state = "deactivated"
		}
	}

	function serviceMix() {
		if (root.mix_to_add > 0) {
			root.mix_to_add--
			root.mix_controls_count++
			mixText.activate()
		} else if (root.mix_to_add < 0) {
			root.mix_to_add++
			root.mix_controls_count--
			mixText.activate()
		} else if (root.repeat_to_add === 0) {
			root.state = "deactivated"
		}
	}

	signal done()

	Rectangle {
		id: background
		anchors.fill: parent

		Column {
			anchors.centerIn: parent

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				SwellingLabel {
					id: repeatText
					font.bold: true
					fontSize: 68
					color: "white"
					text: root.repeat_shape_count
					onDone: { root.serviceRepeat() }
				}
				Label {
					id: repeatShapeLabel
					font.bold: true
					font.pointSize: 68
					color: "white"
					text: "x "
				}
				Image {
					width: height
					height: repeatShapeLabel.height
					source: "qrc:/textures/repeat_shape.png"
				}
			}
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				SwellingLabel {
					id: mixText
					font.bold: true
					fontSize: 68
					color: "white"
					text: root.mix_controls_count
					onDone: { root.serviceMix() }
				}
				Label {
					id: mixControlsLabel
					font.bold: true
					font.pointSize: 68
					color: "white"
					text: "x "
				}
				Image {
					width: height
					height: mixControlsLabel.height
					source: "qrc:/textures/mix_controls.png"
				}
			}
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
				ScriptAction { script: { root.updateEffects() } }
			}
		},
		Transition {
			from: "activated"; to: "deactivated"
			SequentialAnimation {
				PauseAnimation { duration: 500 }
				NumberAnimation { properties: "opacity"; easing.type: Easing.InQuad; duration: 1000 }
				PropertyAnimation { properties: "visible" }
				ScriptAction { script: { root.done() } }
			}
		}

	]
}
