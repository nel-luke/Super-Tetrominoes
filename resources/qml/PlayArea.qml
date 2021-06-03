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

	property int header_height: parent.height * 0.05
	property int footer_height: parent.height * 0.005
	readonly property int difficulty: 20
	readonly property int timerInt: 500
	readonly property int startPoints: 10

	property int gridRows: 20
	property int gridColumns: 16
	property double block_size: Math.min(root.width/root.gridColumns,
																			 root.height/(root.gridRows+1.5))

	property int points: startPoints
	property int points_to_add: 0

	property alias username: usernameLabel.text
	property bool show_wait_screen: false

	property var shape_colors: [
		Material.Red, Material.Purple, Material.Blue, Material.Green,
		Material.Yellow, Material.Orange, Material.Brown
	]

	property int shape_handle: 0

	property bool dummy: false

	property alias debug_enabled: data.debug_enabled
	property bool debug: false
	onDebugChanged: { playerTimer.running = !(root.debug || root.dummy) }

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

	signal getPoints(var num_points)
	signal sendSpecial(var special_type)
	signal shapeSpawned(var shape_type, var shape_color)
	signal playerService()
	signal gameFailed()

	function getSpecial(special_type) { Service.serviceSpecial(special_type) }
	function spawnShape(shape_type, shape_color) { root.shape_handle = data.spawnShape(shape_type, shape_color) }
	function servicePlayer() { Service.servicePlayer() }

	function startGame() { waitingScreen.deactivate() }
	function startGameHelper() { State.prepareGame(); countDown.activate() }
	function removePoints(num_points) { Service.removePoints(num_points) }
	function pauseGame() { State.pauseGame() }
	function resumeGame() { State.resumeGame() }
	function resumeGameNow() { State.goGame() }
	function restartGame() { State.restartGame() }
	function resetGame() { State.resetGameCompletely() }

	function keyUp() { Control.keyUp() }
	function keyDown() { Control.keyDown() }
	function keyLeft() { Control.keyLeft() }
	function keyRight() { Control.keyRight() }

	function getColor(color_id) {
		return Material.color(color_id)
	}

	TetroGridQ {
		id: data; rows: root.gridRows; columns: root.gridColumns
	}

	Timer {
		id: playerTimer
		interval: timerInt
		repeat: true
		onTriggered: { 	root.playerService(); Service.servicePlayer() }
	}

	Timer {
		id: vanishTimer
		interval: 500
		onTriggered: { Service.deleteRow() }
	}

	Timer {
		id: resetTimer
		interval: 1000
		onTriggered: { data.reset(); root.points = root.startPoints; waitingScreen.activate() }
	}

	Column {
		width: root.gridColumns * root.block_size
		height: parent.height
		anchors.horizontalCenter: parent.horizontalCenter

		Row {
			id: header
			width: parent.width * 0.95
			height: block_size * 1.3
			anchors.horizontalCenter: parent.horizontalCenter

			Label {
				id: usernameLabel
				width: parent.width * 0.5
				height: parent.height * 0.8
				anchors.verticalCenter: parent.verticalCenter
				font.bold: true
				fontSizeMode: Text.VerticalFit
				font.pointSize: 40
				color: "white"
			}

			Label {
				id: scoreLabel
				width: parent.width * 0.4
				height: parent.height * 0.8
				horizontalAlignment: Text.AlignRight
				anchors.verticalCenter: parent.verticalCenter
				font.bold: true
				fontSizeMode: Text.VerticalFit
				font.pointSize: 40
				color: "white"
				text: "Points: "
			}

			SwellingLabel {
				id: scoreText
				width: parent.width * 0.1
				height: parent.height * 0.8
				anchors.verticalCenter: scoreLabel.verticalCenter
				font.bold: true
				font_size: scoreLabel.fontInfo.pointSize
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

				rowHeightProvider: function() { return Math.min(root.width/data.columns, root.height/(data.rows+1.5)) }
				columnWidthProvider: function() { return Math.min(root.width/data.columns, root.height/(data.rows+1.5)) }

				rowSpacing: 0
				columnSpacing: 0

				model: data

				delegate: TetroBlock {}
			}

			WaitingScreen {
				id: waitingScreen
				visible: root.show_wait_screen
				anchors.fill: parent
				background_color: Material.foreground
				onDone: { root.startGameHelper() }
			}

			CountDownScreen {
				id: countDown
				anchors.fill: parent
				background_color: Material.foreground
				onDone: { State.goGame() }
			}

			EffectScreen {
				id: effectScreen
				anchors.fill: parent
				block_size: root.block_size
				background_color: Material.foreground
				onDone: { Service.servicePoints() }
			}

			VanishBar {
				id: vanishBar
				width: parent.width
				x: 0
			}
		}

		Rectangle {
			width: parent.width
			height: block_size * 0.2
			color: Material.primary
		}
	}

	onHeightChanged: { table.forceLayout() }
	onWidthChanged: { table.forceLayout() }
}
