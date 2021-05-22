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

	property int gridRows: 20
	property int gridColumns: 16
	property double block_size: Math.min(root.width/root.gridColumns, (root.height-root.headerHeight)/root.gridRows)
	property int points: 10

	property var shape_colors: [
		Material.Red, Material.Purple, Material.Blue, Material.Green,
		Material.Yellow, Material.Orange, Material.Brown
	]

	property int shape_handle: 0

	property bool debug: false
	onDebugChanged: { playerTimer.running = !root.debug }

	property bool effects_active: false
	property bool repeat_shape: false
	property bool mix_controls: false
	property bool drop_locked: false

	property var vanish_height: 1
	property var vanish_rows: []

	property var current_shape_type: 0
	property var shape_history: [0, 0, 0]
	property var color_history: [0, 0, 0]
	property var controls_order: [0, 1, 2, 3]

	signal setFocus()
	signal getPoints(var num_points)
	signal sendSpecial(var special_type)
	signal returnSpecial(var special_type)
	signal gamePaused()
	signal gameResumed()
	signal gameFailed()

	function getSpecial(special_type) { Logic.serviceSpecial(special_type) }
	function getReturnedSpecial(special_type) { Logic.serviceReturnedSpecial(special_type) }
	function startGame() { countDown.activate() }
	function removePoints(num_points) { Logic.removePoints(num_points) }
	function pauseGame() { Logic.pauseGame() }
	function resumeGame() { Logic.resumeGame() }
	function winGame() { Logic.winGame() }

	function keyUp() { Logic.keyUp() }
	function keyDown() { Logic.keyDown() }
	function keyLeft() { Logic.keyLeft() }
	function keyRight() { Logic.keyRight() }

	function getColor(color_id) {
		return Material.color(color_id)
	}

	TetroGridQ {
		id: data; rows: root.gridRows; columns: root.gridColumns;
	}

	Timer {
		id: playerTimer
		interval: timerInt
		repeat: true
		onTriggered: { Logic.servicePlayer() }
	}

	Timer {
		id: vanishTimer
		interval: 500
		onTriggered: { Logic.deleteRow() }
	}

	Timer {
		id: resetTimer
		interval: 1000
		onTriggered: { data.reset(); root.points = 10 }
	}

	Timer {
		id: specialTimer
		interval: 50
		onTriggered: { Logic.activateSpecial() }
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
					text: "Points:"
				}

				SwellingLabel {
					id: scoreText
					anchors.left: scoreLabel.right
					anchors.verticalCenter: scoreLabel.verticalCenter
					font.bold: true
					fontSize: 16
					color: "white"
					text: root.points
				}
			}

			Rectangle {
				height: parent.height
				width: parent.width/3
				color: Material.background
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
					onClicked: { root.gamePaused(); Logic.pauseGame() }
				}
			}
		}

		Item {
			anchors.horizontalCenter: parent.horizontalCenter
			height: root.gridRows * root.block_size
			width: root.gridColumns * root.block_size

			TableView {
				id: table
				anchors.fill: parent

				reuseItems: false

				rowHeightProvider: function() { return Math.min(table.height/data.rows, table.width/data.columns)}
				columnWidthProvider: function() { return Math.min(table.height/data.rows, table.width/data.columns)}

				rowSpacing: 0
				columnSpacing: 0

				model: data

				delegate: TetroBlock {}
			}

			CountDownScreen {
				id: countDown
				anchors.fill: parent
				backgroundColor: Material.foreground
				onDone: { Logic.goGame() }
			}

			EffectScreen {
				id: effectScreen
				anchors.fill: parent
				backgroundColor: Material.foreground
			}

			VanishBar {
				id: vanishBar
				width: parent.width
				x: 0
			}
		}
	}

	PauseMenu {
		id: pauseMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onResumeButtonPressed: { 	root.gameResumed(); Logic.resumeGame() }
		onRestartButtonPressed: { root.gameRestarted(); Logic.restartGame() }
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

	onHeightChanged: { table.forceLayout() }
	onWidthChanged: { table.forceLayout() }
}
