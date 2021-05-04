import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

import Custom 1.0
import "logic.js" as Logic

Window {
	readonly property int headerHeight: 50

	id: windowRoot
	visible: true
	width: 720
	height: width + headerHeight
	title: qsTr("Tetris")

	readonly property int borderSize: 1
	readonly property int numShapes: 7
	readonly property int difficulty: 20
	readonly property int timerInt: 500
	readonly property int button_h: 50
	readonly property int button_w: 100

	readonly property var shape_colors:
			[Material.Red, Material.Purple, Material.Blue, Material.Green,
			Material.Yellow, Material.Orange, Material.Brown]

	property int gridRows: 16
	property int gridColumns: 16
	property int score: 0
	property int player1: 0
	property var player1_shape_history: [0, 0, 0]
	property var player1_color_history: [0, 0, 0]

	TetrisGridQ {
		id: data; rows: gridRows; columns: gridColumns;
	}

	function getColor(color_id) {
		return Material.color(color_id)
	}

	SoundEffect {
		id: hit1
		//source: "qrc:/sounds/hit.mp3"
	}

	Timer {
		id: tickTimer
		interval: timerInt
		repeat: true
		onTriggered: { Logic.checkDown(); hit1.play() }
	}

	property int row_id: 0
	Timer {
		id: delayTimer
		interval: 500
		onTriggered: { data.deleteRow(row_id); vanishBar.disappear() }
	}

	Timer {
		id: resetTimer
		interval: 1000
		onTriggered: { data.reset() }
	}

	onHeightChanged: { table.forceLayout() }
	onWidthChanged: { table.forceLayout() }

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
					color: Material.foreground

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
					color: Material.foreground

					Button {
						anchors.centerIn: parent
						width: button_w
						height: button_h
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
						//height: table.cellHeight
						//width: table.cellWidth
						color: "black"
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

	MainMenu {
			id: mainMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onQuitButtonPressed: { Logic.quitGame() }
			onStartButtonPressed: { mainMenu.disappear(); Logic.startGame(gridRows, gridColumns) }
	}

	PauseMenu {
			id: pauseMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onResumeButtonPressed: { Logic.resumeGame() }
			onRestartButtonPressed: { Logic.resetGame(); data.reset(); pauseMenu.disappear();
				Logic.startGame(gridRows, gridColumns) }
			onQuitButtonPressed: { Logic.quitGame() }
	}
}
