import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import Custom 1.0

import "qrc:/qml/types"

Item {
	id: root

	property string username
	property string opponent_username
	property int score: 0
	property var online_players: []
	property var leaderboard: []

	signal returnToMenu()

	function start() { background.forceActiveFocus() }

	TetroClientQ {
		id: client
		server_address: "http://www.server.super-tetrominoes.online/server.php"

		onLoginSuccessful: {
			root.username = username
			loginMenu.disappear()
			lobby.startRefresh()
			pollTimer.start()
		}
		onLoginFail: { loginMenu.usernameExists() }
		onPlayerListReady: {
			root.score = score
			root.online_players = online_players
			root.leaderboard = leaderboard
		}
		onChallengeSent: { }
		onChallengeAlert: { lobby.challengeAlert(username) }
		onDisconnected: { player1.resetGame(); player2.resetGame(); gameOverMenu.appear("Connection lost") }
		onChallengeAccepted: { lobby.challengeAccepted() }
		onChallengeDeclined: { lobby.challengeDeclined() }
		onStartGame: { player1.startGame(); player2.startGame() }

		onGetRemovePoints: { player1.removePoints(num_points) }
		onGetGetSpecial: { player1.getSpecial(special_type) }
		onGetWinGame: { player1.resetGame(); player2.resetGame(); gameOverMenu.appear("You win!") }

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
		focus: false
		anchors.fill: parent
		color: Material.primary
		Keys.onPressed: {
			switch (event.key) {
			case Qt.Key_Up:
			case Qt.Key_W : player1.keyUp(); client.sendKeyUp()
				break;
			case Qt.Key_Down:
			case Qt.Key_S : player1.keyDown(); client.sendKeyDown()
				break;
			case Qt.Key_Left:
			case Qt.Key_A : player1.keyLeft(); client.sendKeyLeft()
				break;
			case Qt.Key_Right:
			case Qt.Key_D : player1.keyRight(); client.sendKeyRight()
				break;

			case Qt.Key_Q : if (player1.debug_enabled) { player1.debug ^= 1; client.sendDebug(player1.debug) }
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
				username: root.username
				width: parent.width < parent.height ? parent.width : parent.width/2
				height: parent.width < parent.height ? parent.height/2 : parent.height
				onSetFocus: { background.focus = true }
				//onGameRetry: { pauseButton.visible = true} //; player2.restartGame() }
				//onEnablePauseButton: { pauseButton.enabled = true }
				//onDisablePauseButton: { pauseButton.enabled = false }

				onGetPoints: { client.sendRemovePoints(num_points); player2.removePoints(num_points) }
				onSendSpecial: { client.sendGetSpecial(special_type); player2.getSpecial(special_type) }
				onGameFailed: { client.sendWinGame(); player2.resetGame(); gameOverMenu.appear("You Lose") }

				onShapeSpawned: { client.sendSpawnShape(shape_type, shape_color) }
				onPlayerService: { client.sendServicePlayer() }
			}

			PlayArea {
				id: player2
				username: root.opponent_username
				width: parent.width < parent.height ? parent.width : parent.width/2
				height: parent.width < parent.height ? parent.height/2 : parent.height
				dummy: true
				show_wait_screen: true

				//onSetFocus: { background.focus = true }
				//onGameRetry: { player1.restartGame() }
				//onGetPoints: { player1.removePoints(num_points) }
				//onSendSpecial: { player1.getSpecial(special_type) }
				//onGameFailed: { player1.winGame(); gameOverMenu.appear("Left-Side Wins!") }
			}
	}

	InstructionsScreen {
		id: instructions
		focus: false
		width: parent.width
		height: parent.height
		background_color: Material.background
		go_back_visible: false
		//go_back_text: "Return to Menu"
		//onGoBack: { root.returnToMenu() }
		onAfterDisappear: { instructions.focus = false; client.sendReady() }
	}

	GameOverMenu {
		id: gameOverMenu
		width: parent.width
		height: parent.height
		backgroundColor: Material.background
		quit_button_text: "Back to Lobby"
		onQuitButtonPressed: { lobby.appear() }

		onAfterAppear: { instructions.appear(); player1.resetLater(); player2.resetLater() }
	}

	Lobby {
		id: lobby
		width: parent.width
		height: parent.height

		username: root.username
		score: root.score
		online_players: root.online_players
		leaderboard: root.leaderboard

		onAcceptChallenge: { client.acceptChallenge() }
		onDeclineChallenge: { client.declineChallenge() }

		onReturnToMenu: { root.returnToMenu() }
		onRefreshPlayers: { client.getOnlinePlayers() }
		onSendChallenge: { client.sendChallenge(player_id) }
		onSetUsername: { root.opponent_username = username }
		onAfterAppear: { gameOverMenu.disappearNow() }
		onAfterDisappear: { instructions.focus = true; gameOverMenu.disappearNow() }
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
