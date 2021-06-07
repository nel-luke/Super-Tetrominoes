import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "qrc:/qml/types"

Page {
	id: root

	signal returnToMenu()

	function start() { root.forceActiveFocus() }

	Rectangle {
		id: background
		focus: false
		anchors.fill: parent
		color: Material.primary
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

			case Qt.Key_Q : if (player1.debug_enabled) { player1.debug ^= 1; player2.debug = !player1.debug }
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

	Grid {
			width: parent.width
			height: parent.height

			onWidthChanged: {
				if (width < height) {
					columns = 1
					rows = 2
					flow = Grid.TopToBottom
					forceLayout()
				} else {
					columns = 2
					rows = 1
					flow = Grid.LeftToRight
					forceLayout()
				}
			}

			PlayArea {
				id: player1
				username: "Player Left"
				width: parent.width < parent.height ? parent.width : parent.width/2
				height: parent.width < parent.height ? parent.height/2 : parent.height

				onSetFocus: { background.focus = true }
				onGetPoints: { player2.removePoints(num_points) }
				onSendSpecial: { player2.getSpecial(special_type) }
				onGameFailed: { player2.resetGame(); gameOverMenu.appear(player2.username + " Wins!") }
			}

			PlayArea {
				id: player2
				username: "Player Right"
				width: parent.width < parent.height ? parent.width : parent.width/2
				height: parent.width < parent.height ? parent.height/2 : parent.height

				debug: player2.debug_enabled
				//onSetFocus: { background.focus = true }
				onGetPoints: { player1.removePoints(num_points) }
				onSendSpecial: { player1.getSpecial(special_type) }
				onGameFailed: { player1.resetGame(); gameOverMenu.appear(player1.username + " Wins!") }
			}
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		quit_button_text: "Quit to Menu"
		onQuitButtonPressed: { root.returnToMenu() }
		onAfterAppear: { player1.resetLater(); player2.resetLater() }
	}

	InstructionsScreen {
		width: parent.width
		height: parent.height
		background_color: Material.background
		go_back_text: "Return to Menu"
		onGoBack: { root.returnToMenu() }
		onAfterDisappear: { player1.startGame(); player2.startGame() }
	}
}
