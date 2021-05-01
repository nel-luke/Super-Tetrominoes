import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

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
	readonly property int difficulty: 20
	readonly property int timerInt: 500
	readonly property int button_h: 50
	readonly property int button_w: 100

	readonly property variant color_list: ["#acd925", "#d925ac", "#d93d25", "#F7ED57", "#6df7d9", "#f7896d", "#f7ce6d", "#a26df7"]
	readonly property color color1: "#579bc2"
	readonly property color color2: "#c2b457"
	readonly property color color3: "#c25765"

	property int gridRows: 16
	property int gridColumns: 16
	property int score: 0
	property int player1: 0
	property variant player1_shapes: [0, 0, 0]
	property variant player1_colors: [0, 0, 0]

	TetrisGridQ {
		id: data; rows: gridRows; columns: gridColumns;
	}

	SoundEffect {
		id: hit1
		source: "qrc:/sounds/hit.mp3"
	}

	function startGame(rows, columns) {
			data.rows = rows
			data.columns = columns
			tick()
			background.focus = true
			tickTimer.running = true
	}

	function pauseGame() {
		tickTimer.running = false
		pauseMenu.state = "visible"
	}

	function resumeGame() {
		pauseMenu.state = "retracted"
		background.focus = true
		tickTimer.running = true
	}

	function quitGame() {
		Qt.callLater(Qt.quit)
	}

	function resetGame() {
		tickTimer.running = false
		tickTimer.interval = timerInt
		score = 0
		player1 = 0
		data.reset()
	}

	function tick() {
		var shape_type = player1_shapes[0]
		while (player1_shapes.includes(shape_type)) {
			shape_type = Math.floor(Math.random() * numShapes)
		}
		player1_shapes.shift()
		player1_shapes.push(shape_type)

		var shape_color = player1_colors[0]
		while (player1_colors.includes(shape_color)) {
			shape_color = Math.floor(Math.random() * color_list.length)
		}
		player1_colors.shift()
		player1_colors.push(shape_color)

		var didSpawn = data.spawn(++player1, shape_type, color_list[shape_color])
		if (didSpawn === false) {
				mainMenu.state = "visible"
				resetGame()
		}
	}

	function reduceTime() {
		//tickTimer.interval *= 1 - score/difficulty
	}

	//property int row_id: 0
	function checkDown() {
		if (data.moveShapeDown(player1) === false) {
			var rows = data.checkRows()
			for (var i = 0; i < rows.length; i++) {
				//vanishBar.y = headerHeight + rows[i]*(table.height/data.rows)
				//vanishBar.state = "on-screen"
				//row_id = rows[i]
				//delayTimer.start()
				data.deleteRow(rows[i])
				score++
				reduceTime()
			}

			tick()
		}
	}

	function dropShape(shape_id) {
		while (data.moveShapeDown(shape_id))
			;
	}

	Timer {
		id: tickTimer
		interval: timerInt
		repeat: true
		onTriggered: { checkDown(); hit1.play() }
	}

	Timer {
		id: delayTimer
		interval: 1000
		onTriggered: { data.deleteRow(row_id); vanishBar.state = "off-screen" }
	}

	onHeightChanged: table.forceLayout()
	onWidthChanged: table.forceLayout()

	Rectangle {
		id: background
		anchors.fill: parent
		color: color2
		Keys.onPressed: {
			if (event.key === Qt.Key_Up || event.key === Qt.Key_W)
				data.rotateShape(player1)
			else if (event.key === Qt.Key_Down || event.key === Qt.Key_S)
				dropShape(player1)
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
					color: color3

					Text {
						anchors.centerIn: parent
						font.bold: true
						font.pointSize: 16
						text: "Score: " + score
					}
				}
				Rectangle {
					height: parent.height
					width: parent.width/2
					color: color3

					Button {
						anchors.centerIn: parent
						width: button_w
						height: button_h
						text: "Pause"
						onClicked: pauseGame()
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
						color: "Black"
						property variant gridColors: ["#e0614b", "#d1e5be"]

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

	Rectangle {
		id: vanishBar
		width: parent.width
		height: table.height/data.rows
		color: "yellow"
		state: "off-screen"
		x: 0
		y: parent.height - height

		states:
			[ State {
					name: "off-screen"
					PropertyChanges { target: vanishBar; width: 0; visible: false }
				},
				State {
					name: "on-screen"
					PropertyChanges { target: vanishBar; width: parent.width; visible: true }
				} ]

		transitions:
			Transition {
					from: "off-screen"; to: "on-screen"
					SequentialAnimation {
							PropertyAnimation { properties: "visible" }
							NumberAnimation { properties: "width"; easing.type: Easing.InOutQuad; duration: 500 }
					}
			}
	}

	Item {
			id: mainMenu
			width: parent.width
			height: parent.height
			visible: true
			focus: true
			state: "visible"

			Rectangle {
					anchors.fill: parent
					color: Material.primary
			}

			Column {
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 2

					Button {
							id: startButton
							width: button_w
							height: button_h
							text: "Start"
							onClicked: { mainMenu.state = "retracted"; startGame(gridRows, gridColumns) }
					}

					Button {
						id: quitButton
						width: button_w
						height: button_h
						text: "Quit"
						onClicked: quitGame()
					}
			}

			states:
					[ State {
							name: "retracted"
							PropertyChanges { target: mainMenu; y: -parent.height; visible: false; focus: false }
						},
						State {
							name: "visible"
							PropertyChanges { target: mainMenu; y: 0; visible: true; focus: true }
						} ]

			transitions:
					Transition {
							from: "visible"; to: "retracted"; reversible: true
							SequentialAnimation {
									NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
									PropertyAnimation { properties: "visible, focus" }
							}
					}
	}

	Item {
			id: pauseMenu
			width: parent.width
			height: parent.height
			state: "retracted"
			visible: false
			focus: false

			Rectangle {
					anchors.fill: parent
					color: color2
			}

			Column {
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 2

					Button {
							id: resumeButton
							width: button_w
							height: button_h
							text: "Resume"
							onClicked: resumeGame()
					}

					Button {
						id: restartButton
						width: button_w
						height: button_h
						text: "Restart"
						onClicked: { resetGame(); pauseMenu.state = "retracted"; startGame(gridRows, gridColumns) }
					}

					Timer {
						id: resetTimer
						interval: 700
						onTriggered: { pauseMenu.state = "retracted" }
					}

					Button {
						id: pauseQuitButton
						width: button_w
						height: button_h
						text: "Quit"
						onClicked: quitGame()
					}
			}

			states:
					[ State {
							name: "retracted"
							PropertyChanges { target: pauseMenu; y: -parent.height; visible: false; focus: false }
						},
						State {
							name: "visible"
							PropertyChanges { target: pauseMenu; y: 0; visible: true; focus: true }
						} ]

			transitions:
					Transition {
							from: "visible"; to: "retracted"; reversible: true
							SequentialAnimation {
									NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
									PropertyAnimation { properties: "visible, focus" }
							}
					}
	}
}
