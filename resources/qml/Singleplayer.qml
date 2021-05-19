import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Custom 1.0
import "qrc:/js/singleplayer_logic.js" as Logic
import "qrc:/qml/types"

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

	property bool player1_drop_locked: false

	property var player1_shape_history: [0, 1, 2]
	property var player1_color_history: [0, 1, 2]
	property var player1_spawn_special: []
	property var player1_activate_special: []

	signal returnToMenu()

	function start() { root.forceActiveFocus(); countDown.activate() }

	function getColor(color_id) {
		return Material.color(color_id)
	}

	TetroGridQ {
		id: data; rows: root.gridRows; columns: root.gridColumns;
		onActivateSpecial: { Logic.serviceSpecial(special_type) }
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

	Timer {
		id: specialTimer
		interval: 50
		onTriggered: { Logic.activateSpecial() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: Material.background
		Keys.onPressed: {
			if (event.key === Qt.Key_Slash || event.key === Qt.Key_Q) {
				Logic.buyEffect()
			} else if (!root.player1_rotation_locked && (event.key === Qt.Key_Up || event.key === Qt.Key_W)) {
				data.rotateShape(player1)
			} else if (!root.player1_drop_locked && (event.key === Qt.Key_Down || event.key === Qt.Key_S)) {
				Logic.dropShape(player1)
			} else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
				data.moveShapeLeft(player1)
			} else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
				data.moveShapeRight(player1)
			}
		}
	}

	Column {
		anchors.fill: parent

		Row {
			width: parent.width
			height: headerHeight

			Rectangle {
				width: parent.width/3
				height: parent.height
				color: Material.background

				Label {
					id: scoreLabel
					anchors.centerIn: parent
					font.bold: true
					font.pointSize: 16
					color: "white"
					text: "Score:"
				}

				SwellingLabel {
					id: scoreText
					anchors.left: scoreLabel.right
					anchors.verticalCenter: scoreLabel.verticalCenter
					font.bold: true
					fontSize: 16
					color: "white"
					text: score
				}
			}

			Rectangle {
				height: parent.height
				width: parent.width/3
				color: Material.background

				Image {
					id: specialSelector
					anchors.centerIn: parent
					height: parent.height
					width: height

					source: data.getSingle(TetroGridQ.NoDrop)
				}
			}

			Rectangle {
				height: parent.height
				width: parent.width/3
				color: Material.background

				Button {
					id: pauseButton
					enabled: false
					anchors.centerIn: parent
					text: "Pause"
					onClicked: { Logic.pauseGame() }
				}
			}
		}

		TableView {
			id: table
			height: Math.min(parent.height/2, parent.width)
			width: height
			reuseItems: false

			rowHeightProvider: function() { return Math.min(table.height/data.rows, table.width/data.columns)}
			columnWidthProvider: function() { return Math.min(table.height/data.rows, table.width/data.columns)}

			rowSpacing: 0
			columnSpacing: 0

			model: data

			delegate: TetroBlock {}
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

			onAfterDisappear: { countDown.activate() }
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onRetryButtonPressed: { Logic.restartGame() }
		onQuitButtonPressed: { root.returnToMenu() }

		onAfterDisappear: { countDown.activate() }
	}

	CountDownScreen {
		id: countDown
		width: parent.width
		height: parent.height - headerHeight
		y: table.y
		backgroundColor: Material.foreground
		onDone: { Logic.goGame() }
	}

	EffectScreen {
		id: effectScreen
		width: table.width
		height: table.height
		backgroundColor: Material.foreground
	}
}
