import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import Custom 1.0

import "qrc:/qml/types"

Item {
	id: root

	property var username
	property int score
	property var online_players
	property var leaderboard

	signal returnToMenu()

	function start() { background.forceActiveFocus() }

	TetroClientQ {
		id: client
		server_address: "http://www.server.super-tetrominoes.online/server.php"

		onLoginSuccessful: {
			root.username = username; root.score = score
			loginMenu.disappear()
			lobby.startRefresh()
		}
		onLoginFail: { loginMenu.usernameExists() }
		onOnlinePlayersReady: { root.online_players = list; pollTimer.start() }
		onLeaderboardReady: { root.leaderboard = list }
		onChallengeSent: { }
		onChallengeAlert: { lobby.activateDialog(username + " has challenged you.") }
		onDisconnected: { player1.winGame(); gameOverMenu.appear("You win!"); root.score++ }
		onChallengeAccepted: { lobby.disappear() }
		onChallengeDeclined: { }

		onGetRemovePoints: { player1.removePoints(num_points) }
		onGetGetSpecial: { player1.getSpecial(special_type) }
		onGetWinGame: { player1.winGame(); gameOverMenu.appear("You win!") }

		onGetSpawnShape: { player2.spawnShape(shape_type, shape_color) }
		onGetServicePlayer: { player2.servicePlayer() }
		onGetKeyUp: { player2.keyUp() }
		onGetKeyDown: { player2.keyDown() }
		onGetKeyLeft: { player2.keyLeft() }
		onGetKeyRight: { player2.keyRight() }
		onGetDebug: { player2.debug = result }
	}

	Timer {
		id: pollTimer
		interval: 250
		repeat: true
		onTriggered: { client.pollChange() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: Material.background
		Keys.onPressed: {
			switch(event.key) {
			case Qt.Key_W : player1.keyUp(); client.sendKeyUp()
				break;
			case Qt.Key_S : player1.keyDown(); client.sendKeyDown()
				break;
			case Qt.Key_A : player1.keyLeft(); client.sendKeyLeft()
				break;
			case Qt.Key_D : player1.keyRight(); client.sendKeyRight()
				break;

			case Qt.Key_Q : player1.debug ^= 1; client.sendDebug(player1.debug)
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
				//onGameRetry: { pauseButton.visible = true} //; player2.restartGame() }
				//onEnablePauseButton: { pauseButton.enabled = true }
				//onDisablePauseButton: { pauseButton.enabled = false }

				onGetPoints: { client.sendRemovePoints(num_points); player2.removePoints(num_points) }
				onSendSpecial: { client.sendGetSpecial(special_type); player2.getSpecial(special_type) }
				onGameFailed: { client.sendWinGame(); gameOverMenu.appear("You Lose"); root.score-- }

				onShapeSpawned: { client.sendSpawnShape(shape_type, shape_color) }
				onPlayerService: { client.sendServicePlayer() }
			}

			Rectangle {
				width: parent.width/8
				height: parent.height
				color: Material.background

				Rectangle {
					width: parent.width
					height: root.header_height
					color: Material.background

//					Button {
//						id: pauseButton
//						enabled: false
//						anchors.centerIn: parent
//						text: "Pause"
//						onClicked: {
//							player1.pauseGame()
//							client.sendPauseGame()
//							pauseMenu.appear()
//						}
//					}
				}
			}

			PlayArea {
				id: player2
				width: 7*parent.width/16
				height: parent.height
				dummy: true
				//onSetFocus: { background.focus = true }
				//onGameRetry: { player1.restartGame() }
				//onGetPoints: { player1.removePoints(num_points) }
				//onSendSpecial: { player1.getSpecial(special_type) }
				//onGameFailed: { player1.winGame(); gameOverMenu.appear("Left-Side Wins!") }
			}
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onQuitButtonPressed: { lobby.appear() }

		onAfterDisappear: { root.start() }
	}

	Lobby {
		id: lobby
		width: parent.width
		height: parent.height

		username: root.username
		score: root.score
		online_players: root.online_players

		onAcceptChallenge: { client.acceptChallenge(); lobby.disappear() }
		onDeclineChallenge: { client.declineChallenge() }

		onReturnToMenu: { root.returnToMenu() }
		onRefreshPlayers: { client.getOnlinePlayers() } //; client.sendChallenge(6) }
		onSendChallenge: { client.sendChallenge(player_id) }
		onAfterDisappear: { player1.startGame(); player2.startGame() }
	}

	LoginMenu {
		id: loginMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		onLoginPressed: { client.login(username, real_name) }
		onBackToMenuPressed: { root.returnToMenu() }
	}

}
