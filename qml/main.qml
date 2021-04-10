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
		id: data; rows: 6; columns: 6;
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
		Keys.onLeftPressed: { data.moveShapeLeft(1) }
		Keys.onRightPressed: { data.moveShapeRight(1) }
		Keys.onDownPressed: { data.moveShapeDown(1) }
		Keys.onUpPressed: { data.moveShapeUp(1) }
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
