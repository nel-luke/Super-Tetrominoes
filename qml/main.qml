import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import Custom 1.0

Window {
	readonly property int headerHeight: 50

	id: windowRoot
	visible: true
	width: 720
	height: width + headerHeight
	title: qsTr("Tetris")

	readonly property int borderSize: 1
	readonly property int numShapes: 7
	property int score: 0
	property int user1: 0

	TetrisGridQ {
		id: data; rows: 16; columns: 16;
	}

	function tick() {
		if (data.spawn(++user1, Math.floor(Math.random() * (numShapes + 1)),
									 Qt.rgba(Math.random(),Math.random(),Math.random(),1)) === false) {
				tickTimer.running = false
				prepareOverlay.enabled = true
				data.reset()
				score = 0
				user1 = 0
			}
	}

	Timer {
		id: tickTimer
		interval: 500
		repeat: true
		onTriggered: {
			if (data.moveShapeDown(user1) === false) {
				score++
				var rows = data.checkRows()
				for (var i = 0; i < rows.length; i++) {
					data.deleteRow(rows[i])
				}

				tick()
			}
		}
	}

	onHeightChanged: table.forceLayout()
	onWidthChanged: table.forceLayout()

	Rectangle {
		id: background
		anchors.fill: parent
		color: "cornflowerblue"
		Keys.onLeftPressed: { data.moveShapeLeft(user1) }
		Keys.onRightPressed: { data.moveShapeRight(user1) }
		Keys.onDownPressed:  { data.moveShapeDown(user1) }
		Keys.onPressed: {
			if (event.key === Qt.Key_R)
				data.rotateShape(user1)
			else if (event.key === Qt.Key_E)
				data.c_rotateShape(user1)
		}
	}

	Column {
		anchors.fill: parent

		Rectangle {
			id: header
			height: headerHeight
			width: parent.width
			Row {
				anchors.fill: parent
				Rectangle {
					height: parent.height
					width: parent.width/2
					color: "cornflowerblue"

					Text {
						anchors.centerIn: parent
						text: "Score: " + score
					}
				}
				Rectangle {
					height: parent.height
					width: parent.width/2
					color: "cornflowerblue"
				}
			}
		}

		TableView {
			id: table
			height: parent.height - headerHeight
			width: parent.width
			reuseItems: false

			rowHeightProvider: function() { return table.height/data.rows} //- 0.05*data.rows}
			columnWidthProvider: function() { return table.width/data.columns} // - 0.05*data.columns}

			rowSpacing: 0
			columnSpacing: 0

			model: data

			delegate:
					Rectangle {
						id: blockBorder
						height: table.cellHeight
						width: table.cellWidth
						color: "black"

						Rectangle {
							id: blockFront
							height: parent.height - borderSize * (hasBorderTop + hasBorderBottom)
							width: parent.width - borderSize * (hasBorderLeft + hasBorderRight)
							color: blockColor ? blockColor : "transparent"
							x: borderSize * hasBorderLeft
							y: borderSize * hasBorderTop
						}

			}
		}
	}

	MouseArea {
			id: prepareOverlay
			anchors.fill: parent
			enabled: false
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onClicked: {
					overlay.state = ""
					enabled = false
			}
	}

	Item {
			id: overlay
			width: parent.width
			height: parent.height

			function start(rows, columns) {
					data.rows = rows
					data.columns = columns
					overlay.state = "retracted"
					tick()
					background.focus = true
					tickTimer.running = true
			}

			Rectangle {
					anchors.fill: parent
					color: "cornflowerblue"
			}

			MouseArea {
					//antialiasing: true
					anchors.fill: parent
			}

			Column {
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 2

					Button {
							id: easyButton
							width: 100
							height: 50
							text: "Start"
							onClicked: overlay.start(16, 16)
					}
			}

			states: State {
					name: "retracted";
					PropertyChanges { target: overlay; y: -parent.height; visible: false }
			}

			transitions:
					[Transition {
							from: ""; to: "retracted"
							SequentialAnimation {
									NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
									PropertyAnimation { properties: "visible" }
							}
					}, Transition {
							from: "retracted"; to: ""
							SequentialAnimation {
									PropertyAnimation { properties: "visible" }
									NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
							}
					}]
	}
}
