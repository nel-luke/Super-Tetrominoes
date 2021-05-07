import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Custom 1.0
import "qrc:/js/single_classic_logic.js" as Logic

Item {
	id: root

	readonly property int headerHeight: 50
	readonly property int difficulty: 20
	readonly property int timerInt: 500

	property int gridRows: 16
	property int gridColumns: 16
	property int score: 0

	required property var shape_colors

	property int player1: 0
	property var player1_shape_history: [0, 1, 2]
	property var player1_color_history: [0, 1, 2]

	signal returnToMenu()

	function getColor(color_id) {
		return Material.color(color_id)
	}

	TetrisGridQ {
		id: data; rows: gridRows; columns: gridColumns;
	}

	onHeightChanged: { table.forceLayout() }
	onWidthChanged: { table.forceLayout() }

	Timer {
		id: player1Timer
		interval: timerInt
		repeat: true
		onTriggered: { Logic.servicePlayer1() }
	}

	property var vanish_rows: []
	Timer {
		id: vanishTimer
		interval: 500
		onTriggered: { Logic.deleteRow() }
	}

	Timer {
		id: resetTimer
		interval: 1000
		onTriggered: { data.reset() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: Material.background
		Keys.onPressed: {
			if (event.key === Qt.Key_Up || event.key === Qt.Key_W)
				data.rotateShape(player1)
			else if (event.key === Qt.Key_Down || event.key === Qt.Key_S)
				Logic.dropShape(player1)
			else if (event.key === Qt.Key_Left || event.key === Qt.Key_A)
				data.moveShapeLeft(player1)
			else if (event.key === Qt.Key_Right || event.key === Qt.Key_D)
				data.moveShapeRight(player1)
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
					color: Material.background

					Label {
						anchors.centerIn: parent
						font.bold: true
						font.pointSize: 16
						color: "white"
						text: "Score: " + score
					}
				}
				Rectangle {
					height: parent.height
					width: parent.width/2
					color: Material.background

					Button {
						anchors.centerIn: parent
						text: "Pause"
						onClicked: Logic.pauseGame()
					}
				}
			}
		}

		TableView {
			id: table
			height: parent.height - headerHeight
			width: parent.width
			reuseItems: false

			rowHeightProvider: function() { return table.height/data.rows}// - 0.05*data.rows}
			columnWidthProvider: function() { return table.width/data.columns}// - 0.05*data.columns}

			rowSpacing: 0
			columnSpacing: 0

			model: data

			delegate:
					Rectangle {
						id: blockBorder
						color: "black"
						readonly property int borderSize: 1
						property variant gridColors: [
							Material.color(Material.Grey, Material.Shade300),
							Material.color(Material.Grey, Material.Shade400)]

						Rectangle {
							id: blockFront
							height: parent.height - borderSize * (hasBorderTop + hasBorderBottom)
							width: parent.width - borderSize * (hasBorderLeft + hasBorderRight)
							color: blockColor != "#000000" ? blockColor : gridColors[((row%2)+(column%2))%2]
							x: borderSize * hasBorderLeft
							y: borderSize * hasBorderTop

						}

			}
		}
	}

	VanishBar {
		id: vanishBar
		width: parent.width
		height: table.height/data.rows
	}

	PauseMenu {
			id: pauseMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.background
			onResumeButtonPressed: { Logic.resumeGame() }
			onRestartButtonPressed: { Logic.restartGame() }
			onQuitButtonPressed: { root.returnToMenu() }
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onRetryButtonPressed: { Logic.restartGame() }
		onQuitButtonPressed: { root.returnToMenu() }
	}
}
