import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import Custom 1.0

Window {
	id: windowRoot
	visible: true
	width: 720
	height: width + 100
	title: qsTr("Tetris")

	property int borderSize: 2

	TetrisGridQ {
		id: data; rows: 16; columns: 16;
	}

//	Timer {
//		id: tickTimer
//		interval: 1000
//		repeat: true
//		onTriggered: { data.
//	}

	onHeightChanged: table.forceLayout()
	onWidthChanged: table.forceLayout()

	Rectangle {
		id: background
		anchors.fill: parent
		focus: true
		color: "blue"
		Keys.onLeftPressed: { data.moveShapeLeft(data.shape1) }
		Keys.onRightPressed: { data.moveShapeRight(data.shape1) }
		Keys.onDownPressed: { data.moveShapeDown(data.shape1) }
		Keys.onUpPressed: { data.moveShapeUp(data.shape1) }
		Keys.onPressed: {
			if (event.key === Qt.Key_R)
				data.rotateShape(data.shape1)
			else if (event.key === Qt.Key_E)
				data.c_rotateShape(data.shape1)
		}

		Keys.onSpacePressed: { data.spawn() }
	}

	Column {
		anchors.fill: parent

		Button {
			onClicked: { data.spawn(); background.focus = true }
		}

		TableView {
			id: table
			height: parent.height - 100
			width: parent.width
			reuseItems: false

			rowHeightProvider: function() { return table.height/data.rows - 0.05*data.rows}
			columnWidthProvider: function() { return table.width/data.columns - 0.05*data.columns}

			rowSpacing: 0
			columnSpacing: 0

			model: data

			delegate:
					Rectangle {
						id: blockBorder
						height: table.cellHeight
						width: table.cellWidth
						color: "green"

						Rectangle {
							id: blockFront
							height: parent.height - borderSize * (hasBorderTop + hasBorderBottom)
							width: parent.width - borderSize * (hasBorderLeft + hasBorderRight)
							color: blockColor
							x: borderSize * hasBorderLeft
							y: borderSize * hasBorderTop
						}

			}
		}
	}
}
