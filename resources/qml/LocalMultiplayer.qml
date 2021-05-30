import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import "qrc:/qml/types"

Item {
	id: root

	property int header_height: 50

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
				width: 7*parent.width/16
				height: parent.height
				onSetFocus: { background.focus = true }
				onGameRetry: { pauseButton.visible = true; player2.restartGame() }
				onEnablePauseButton: { pauseButton.enabled = true }
				onDisablePauseButton: { pauseButton.enabled = false }

				onGetPoints: { player2.removePoints(num_points) }
				onSendSpecial: { player2.getSpecial(special_type) }
				onGameFailed: { player2.winGame(); gameOverMenu.appear("Right-Side Wins!") }
			}

			Rectangle {
				width: parent.width/8
				height: parent.height
				color: Material.background

				Rectangle {
					width: parent.width
					height: root.header_height
					color: Material.background

					Button {
						id: pauseButton
						enabled: false
						anchors.centerIn: parent
						text: "Pause"
						onClicked: {
							player1.pauseGame()
							player2.pauseGame()
							pauseMenu.appear()
						}
					}
				}
			}

			PlayArea {
				id: player2
				width: 7*parent.width/16
				height: parent.height
			debug: true
				//onSetFocus: { background.focus = true }
				onGameRetry: { player1.restartGame() }
				onGetPoints: { player1.removePoints(num_points) }
				onSendSpecial: { player1.getSpecial(special_type) }
				onGameFailed: { player1.winGame(); gameOverMenu.appear("Left-Side Wins!") }
			}
	}

	PauseMenu {
		id: pauseMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onResumeButtonPressed: { pauseMenu.disappear() }
		onRestartButtonPressed: { player1.restartGame(); player2.restartGame(); pauseMenu.disappear() }
		onQuitButtonPressed: { root.returnToMenu() }

		onAfterDisappear: { player1.resumeGame(); player2.resumeGame() }
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onRetryButtonPressed: { gameOverMenu.disappear() }
		onQuitButtonPressed: { root.returnToMenu() }

		onAfterDisappear: { root.start() }
	}
}
