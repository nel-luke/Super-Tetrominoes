import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Custom 1.0
import "qrc:/js/control_logic.js" as Control
import "qrc:/js/effects_logic.js" as Effects
import "qrc:/js/service_logic.js" as Service
import "qrc:/js/state_logic.js" as State
import "qrc:/qml/types"

Item {
	id: root

	readonly property int headerHeight: 50
	readonly property int difficulty: 20
	readonly property int timerInt: 500
	readonly property int startPoints: 10

	property int gridRows: 20
	property int gridColumns: 16
	property double block_size: Math.min(root.width/root.gridColumns, (root.height-root.headerHeight)/root.gridRows)

	property int points: startPoints
	property int points_to_add: 0

	property var shape_colors: [
		Material.Red, Material.Purple, Material.Blue, Material.Green,
		Material.Yellow, Material.Orange, Material.Brown
	]

	property int shape_handle: 0

	property bool debug: false
	onDebugChanged: { playerTimer.running = !root.debug }

	property bool game_started: false

	property int repeat_shape_count: 0
	property bool change_repeat: false

	property int mix_controls_count: 0

	property var vanish_height: 1
	property var vanish_rows: []

	property var current_shape_type: 0
	property var shape_history: [0, 0, 0]
	property var color_history: [0, 0, 0]
	property var controls_order: [0, 1, 2, 3]

	signal setFocus()
	signal enablePauseButton()
	signal disablePauseButton()
	signal gameRetry()
	signal returnToMenu()
	signal retractGameOverMenu()

	signal getPoints(var num_points)
	signal sendSpecial(var special_type)
	signal returnSpecial(var special_type)
	signal gameFailed()

	function getSpecial(special_type) { Service.serviceSpecial(special_type) }
	function getReturnedSpecial(special_type) { Service.serviceReturnedSpecial(special_type) }

	function startGame() { State.prepareGame(); countDown.activate() }
	function removePoints(num_points) { Service.removePoints(num_points) }
	function pauseGame() { State.pauseGame() }
	function resumeGame() { State.resumeGame() }
	function restartGame() { State.restartGame() }
	function winGame() { State.winGame() }

	function keyUp() { Control.keyUp() }
	function keyDown() { Control.keyDown() }
	function keyLeft() { Control.keyLeft() }
	function keyRight() { Control.keyRight() }

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
		onTriggered: { Service.servicePlayer() }
	}

	Timer {
		id: vanishTimer
		interval: 500
		onTriggered: { Service.deleteRow() }
	}

	Timer {
		id: resetTimer
		interval: 1000
		onTriggered: { data.reset(); root.points = root.startPoints }
	}

	Column {
		anchors.fill: parent

		Rectangle {
			width: parent.width
			height: root.headerHeight
			color: Material.background

			Label {
				id: scoreLabel
				anchors.centerIn: parent
				font.bold: true
				font.pointSize: 16
				color: "white"
				text: "Points: "
			}

			SwellingLabel {
				id: scoreText
				anchors.left: scoreLabel.right
				anchors.verticalCenter: scoreLabel.verticalCenter
				font.bold: true
				fontSize: 16
				color: "white"
				text: root.points
				onDone: { Service.servicePoints() }
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
				onDone: { State.goGame() }
			}

			EffectScreen {
				id: effectScreen
				anchors.fill: parent
				backgroundColor: Material.foreground
				onDone: { Service.servicePoints() }
			}

			VanishBar {
				id: vanishBar
				width: parent.width
				x: 0
			}
		}
	}

	onHeightChanged: { table.forceLayout() }
	onWidthChanged: { table.forceLayout() }
}
