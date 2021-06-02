import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
	id: root
	state: "deactivated"

	property int block_size

	property alias background_color: background.color
	property int repeat_shape_count: 0
	property int repeat_to_add: 0

	property int mix_controls_count: 0
	property int mix_to_add: 0

	function incrementRepeatShape() {
		root.repeat_to_add++
	}
	function decrementRepeatShape() {
		root.repeat_to_add--
	}

	function incrementMixControls() {
		root.mix_to_add++
	}
	function decrementMixControls() {
		root.mix_to_add--
	}

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

	signal done

	Rectangle {
		id: background
		anchors.fill: parent
	}
	Column {
		id: columns
		anchors.centerIn: parent
		width: parent.width
		height: root.block_size * 10
		spacing: root.block_size * 2

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.width
			height: root.block_size * 4

			Row {
				width: parent.width / 2
				height: parent.height

				SwellingLabel {
					id: repeatText
					width: parent.width * 0.7
					height: parent.height
					horizontalAlignment: Text.AlignRight
					font.bold: true
					font_size: repeatShapeLabel.fontInfo.pointSize
					color: "white"
					text: root.repeat_shape_count
					onDone: {
						root.serviceRepeat()
					}
				}
				Label {
					id: repeatShapeLabel
					height: parent.height
					font.bold: true
					fontSizeMode: Text.VerticalFit
					font.pointSize: 128
					color: "white"
					text: "x"
				}
			}
			Image {
				width: parent.width / 2
				height: parent.height
				horizontalAlignment: Image.AlignLeft
				verticalAlignment: Image.AlignVCenter
				fillMode: Image.PreserveAspectFit
				source: "qrc:/textures/repeat_shape_plain.svg"
			}
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.width
			height: root.block_size * 4

			Row {
				width: parent.width / 2
				height: parent.height

				SwellingLabel {
					id: mixText
					width: parent.width * 0.7
					height: parent.height
					horizontalAlignment: Text.AlignRight
					font.bold: true
					font_size: repeatShapeLabel.fontInfo.pointSize
					color: "white"
					text: root.mix_controls_count
					onDone: {
						root.serviceMix()
					}
				}
				Label {
					id: mixControlsLabel
					height: parent.height
					font.bold: true
					fontSizeMode: Text.VerticalFit
					font.pointSize: 128
					color: "white"
					text: "x"
				}
			}
			Image {
				width: parent.width / 3
				height: parent.height
				anchors.verticalCenter: parent.verticalCenter
				fillMode: Image.PreserveAspectFit
				source: "qrc:/textures/mix_controls_plain.svg"
			}
		}
	}

	states: [
		State {
			name: "deactivated"
			PropertyChanges { target: root; opacity: 0; visible: false }
		},
		State {
			name: "activated"
			PropertyChanges { target: root; opacity: 0.75; visible: true }
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
