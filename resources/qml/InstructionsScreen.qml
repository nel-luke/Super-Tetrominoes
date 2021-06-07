import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
	id: root
	state: "visible"

	property alias go_back_text: exitButton.text
	property color background_color
	property alias go_back_visible: exitButton.visible

	function disappear() { root.state = "retracted" }
	function appear() { swipeView.currentIndex = 0; root.state = "visible" }

	signal goBack()
	signal afterDisappear()

	SwipeView {
		id: swipeView

		currentIndex: 0
		anchors.fill: parent

		Page {
			Rectangle { anchors.fill: parent; color: root.background_color}

			Label {
				width: parent.width
				height: parent.height * 0.2
				anchors.horizontalCenter: parent.horizontalCenter
				horizontalAlignment: Text.AlignHCenter
				text: "Instructions"
				font.pointSize: 68
				font.bold: true
				color: "white"
			}
			Column {
				width: controlsImage.width
				height: parent.height * 0.9
				anchors.horizontalCenter: parent.horizontalCenter
				y: parent.height * 0.2

				Label {
					text: "Controls"
					font.pointSize: 40
					font.bold: true
					color: "white"
				}
				Label {
					width: parent.width
					text: "Move the falling shape with the WASD or directional keys."
					fontSizeMode: Label.HorizontalFit
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
				AnimatedImage {
					id: controlsImage
					anchors.horizontalCenter: parent.horizontalCenter
					//width: parent.width
					height: parent.height * 0.5
					fillMode: Image.PreserveAspectFit
					source: "qrc:/textures/controls.gif"
					playing: swipeView.currentIndex === 0
				}
				Label {
					width: parent.width
					text: "Use the above controls to move to the next slide."
					fontSizeMode: Label.HorizontalFit
					font.pixelSize: 24
					font.bold: true
					color: "white"
					horizontalAlignment: Text.AlignHCenter
				}
			}

			Button {
				id: exitButton
				anchors.left: parent.left
				anchors.leftMargin: parent.width * 0.05
				anchors.bottom: parent.bottom
				anchors.bottomMargin: parent.height * 0.05
				onClicked: { root.goBack() }
			}
		}
		Item {
			Rectangle { anchors.fill: parent; color: root.background_color }

			Column {
				width: pointsImage.width
				height: parent.height * 0.9
				anchors.centerIn: parent

				Label {
					text: "Points"
					font.pointSize: 40
					font.bold: true
					color: "white"
				}
				Label {
					width: parent.width
					text: "Fill a row with blocks to steal a point from your opponent."
					fontSizeMode: Label.HorizontalFit
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
				AnimatedImage {
					id: pointsImage
					anchors.horizontalCenter: parent.horizontalCenter
					//width: parent.width
					height: parent.height * 0.35
					fillMode: Image.PreserveAspectFit
					source: "qrc:/textures/steal_points.gif"
					playing: swipeView.currentIndex === 1
				}
				Label {
					width: parent.width
					text: "Heads up: More points makes the game harder!"
					fontSizeMode: Label.HorizontalFit
					font.pixelSize: 24
					font.bold: true
					color: "white"
					//horizontalAlignment: Text.AlignHCenter
				}
				Item { width: parent.width; height: parent.height * 0.05 }
				Label {
					width: parent.width
					text: "When your shapes stack too high, you lose the game."
					fontSizeMode: Label.HorizontalFit
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
				AnimatedImage {
					anchors.horizontalCenter: parent.horizontalCenter
					//width: parent.width
					height: parent.height * 0.35
					fillMode: Image.PreserveAspectFit
					source: "qrc:/textures/overflow.gif"
					playing: swipeView.currentIndex === 1
				}
			}
		}
		Item {
			Rectangle { anchors.fill: parent; color: root.background_color }

			Column {
				width: pointsImage.width
				height: parent.height * 0.9
				anchors.centerIn: parent

				Label {
					text: "Status Effects"
					font.pointSize: 40
					font.bold: true
					color: "white"
				}
				Label {
					width: parent.width
					text: "Clearing adjacent rows adds effects to your opponent."
					fontSizeMode: Label.HorizontalFit
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
				AnimatedImage {
					anchors.horizontalCenter: parent.horizontalCenter
					//width: parent.width
					height: parent.height * 0.35
					fillMode: Image.PreserveAspectFit
					source: "qrc:/textures/effects.gif"
					playing: swipeView.currentIndex === 2
				}
				Row {
					width: parent.width
					height: parent.height * 0.1

					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "2 adjacent rows:"
						horizontalAlignment: Label.AlignRight
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 24
						font.bold: true
						color: "white"
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Image {
						width: parent.width * 0.1
						height: parent.height
						verticalAlignment: Image.AlignVCenter
						fillMode: Image.PreserveAspectFit
						source: "qrc:/textures/repeat_shape_plain.svg"
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "Spawn the next shape\nrepeatedly."
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 16
						font.bold: true
						color: "white"
					}
				}
				Row {
					width: parent.width
					height: parent.height * 0.1

					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "3 adjacent rows:"
						horizontalAlignment: Label.AlignRight
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 24
						font.bold: true
						color: "white"
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Image {
						width: parent.width * 0.1
						height: parent.height
						verticalAlignment: Image.AlignVCenter
						fillMode: Image.PreserveAspectFit
						source: "qrc:/textures/mix_controls_plain.svg"
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "Shuffle the controls."
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 16
						font.bold: true
						color: "white"
					}
				}
				Row {
					width: parent.width
					height: parent.height * 0.2

					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "4 adjacent rows:"
						horizontalAlignment: Label.AlignRight
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 24
						font.bold: true
						color: "white"
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Column {
						width: parent.width * 0.1
						height: parent.height*0.9
						anchors.verticalCenter: parent.verticalCenter

						Image {
							width: parent.width
							height: parent.height/2
							verticalAlignment: Image.AlignVCenter
							fillMode: Image.PreserveAspectFit
							source: "qrc:/textures/repeat_shape_plain.svg"
						}
						Image {
							width: parent.width
							height: parent.height/2
							verticalAlignment: Image.AlignVCenter
							fillMode: Image.PreserveAspectFit
							source: "qrc:/textures/mix_controls_plain.svg"
						}
					}
					Item { width: parent.width * 0.05; height: parent.height }
					Label {
						width: parent.width * 0.4
						height: parent.height
						text: "Double trouble!"
						verticalAlignment: Label.AlignVCenter
						fontSizeMode: Label.HorizontalFit
						font.pointSize: 16
						font.bold: true
						color: "white"
					}
				}
				Label {
					width: parent.width
					text: "Clear rows to remove status effects.\nYou cannot steal points while effects are active!"
					fontSizeMode: Label.HorizontalFit
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
			}
		}

		Item {
			Rectangle { anchors.fill: parent; color: root.background_color }

			Column {
				width: parent.width
				anchors.centerIn: parent

				Label {
					width: parent.width
					anchors.horizontalCenter: parent.horizontalCenter
					horizontalAlignment: Text.AlignHCenter
					text: "Have fun!"
					font.pointSize: 68
					font.bold: true
					color: "white"
				}
				Label {
					width: parent.width
					anchors.horizontalCenter: parent.horizontalCenter
					horizontalAlignment: Text.AlignHCenter
					text: "Press 'W' to start the game."
					font.pointSize: 24
					font.bold: true
					color: "white"
				}
			}
		}
	}

	PageIndicator {
		id: indicator

		count: swipeView.count
		currentIndex: swipeView.currentIndex

		anchors.bottom: swipeView.bottom
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Keys.onPressed: {
		switch (event.key) {
		case Qt.Key_Left:
		case Qt.Key_A:
			if(swipeView.currentIndex > 0)
					swipeView.currentIndex--
			break;
		case Qt.Key_Right:
		case Qt.Key_D:
			if(swipeView.currentIndex < swipeView.count-1)
					swipeView.currentIndex++
			break;
		case Qt.Key_Up:
		case Qt.Key_W:
			if (swipeView.currentIndex === swipeView.count-1)
				root.disappear()
		}
	}

	states: [
		State {
			name: "retracted"
			PropertyChanges { target: root; y: -height; visible: false; focus: false }
		},
		State {
			name: "visible"
			PropertyChanges { target: root; y: 0; visible: true; focus: true }
		}
	]

	transitions: [
		Transition {
			from: "visible"; to: "retracted"
			SequentialAnimation {
				ScriptAction { script: { root.afterDisappear() } }
				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
				PropertyAnimation { properties: "visible, focus" }
			}
		}
//		Transition {
//			from: "retracted"; to: "visible"
//			SequentialAnimation {
//				PropertyAnimation { properties: "visible, focus" }
//				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
//			}
//		}
	]
}
