import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "qrc:/qml/types"

Item {
	id: root

	required property var shape_colors

	signal returnToMenu()

	function start() { root.forceActiveFocus(); player1.startGame(); player2.startGame() }

	Rectangle {
		id: background
		anchors.fill: parent
		color: Material.background
		Keys.onPressed: {
			switch(event.key) {
			case Qt.Key_W : player1.keyUp();
				break;
			case Qt.Key_S : player1.keyDown();
				break;
			case Qt.Key_A : player1.keyLeft();
				break;
			case Qt.Key_D : player1.keyRight();
				break;

			case Qt.Key_Q : player1.debug ^= 1; player2.debug = !player1.debug
				break

			case Qt.Key_Up : player2.keyUp();
				break;
			case Qt.Key_Down : player2.keyDown();
				break;
			case Qt.Key_Left : player2.keyLeft();
				break;
			case Qt.Key_Right : player2.keyRight();
				break;

			default: ;
			}
		}
	}

	Row {
			width: parent.width
			height: parent.height

			PlayArea {
				id: player1
				width: parent.width/2
				height: parent.height
				shape_colors: root.shape_colors
				onSetFocus: { background.focus = true }
				onGetPoints: { player2.removePoints(num_points) }
				onSendSpecial: { player2.getSpecial(special_type) }
				onReturnSpecial: { player2.getReturnedSpecial(special_type) }
				onGamePaused: player2.pauseGame()
				onGameResumed: player2.resumeGame()
				onGameFailed: player2.winGame()
			}

			PlayArea {
				id: player2
				width: parent.width/2
				height: parent.height
			debug: true
				shape_colors: root.shape_colors
				onSetFocus: { background.focus = true }
				onGetPoints: { player1.removePoints(num_points) }
				onSendSpecial: { player1.getSpecial(special_type) }
				onReturnSpecial: { player1.getReturnedSpecial(special_type) }
				onGamePaused: player1.pauseGame()
				onGameResumed: player1.resumeGame()
				onGameFailed: player1.winGame()
			}
	}
}
