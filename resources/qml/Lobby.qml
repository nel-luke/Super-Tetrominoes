import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15


Item {
	id: root

	state: "visible"

	property string username: ""
	property var score: 0
	property var online_players: []
	property var leaderboard: []

	function disappear() { root.state = "retracted"; root.stopRefresh() }
	function appear() { root.refreshPlayers(); root.state = "visible"; root.startRefresh() }
	//function appearNow() { root.state = ""; root.appear() }

	function startRefresh() { listTimer.start() }
	function stopRefresh() { listTimer.stop() }

	function challengeAlert(username) { getChallengeDialog.appear(username) }

	function makeChallenge(player_id, player_username) {
		sendChallengeDialog.appear(player_username)
		root.sendChallenge(player_id, player_username)
	}

	function challengeDeclined() {
		sendChallengeDialog.closeWithMessage("Challenge declined", false)
	}

	function challengeAccepted() {
		sendChallengeDialog.closeWithMessage("Challenge accepted!", true)
	}

	signal returnToMenu()
	signal refreshPlayers()
	signal sendChallenge(var player_id)
	signal setUsername(var username)

	signal acceptChallenge()
	signal declineChallenge()

	signal afterDisappear()
	signal afterAppear()

	Timer {
		id: listTimer
		interval: 1000
		repeat: true
		onTriggered: { root.refreshPlayers() }
	}

	Rectangle {
		anchors.fill: parent
		color: Material.primary
	}

	ColumnLayout {
		anchors.fill: parent

		RowLayout {
			Layout.minimumHeight: 50

			Item {
				Layout.minimumWidth: parent.width/3
				Label {
					anchors.centerIn: parent
					color: "white"
					font.pointSize: 24
					font.bold: true
					text: "Welcome, " + root.username + "!"
				}
			}
			Item {
				Layout.minimumWidth: parent.width/3
				Label {
					anchors.centerIn: parent
					color: "white"
					font.pointSize: 24
					font.bold: true
					text: "Score: " + root.score
				}
			}
			Item {
				Layout.fillWidth: true
				Button {
					anchors.centerIn: parent
					text: "Logout"
					onClicked: { root.returnToMenu() }

				}
			}
		}

		TabBar {
			id: tabButtons
			Layout.fillWidth: true
			Layout.minimumHeight: 50

			background: Rectangle {
				color: Material.primary
			}

			TabButton {
				text: "Online Players"
				Layout.minimumWidth: parent.width/2
			}
			TabButton {
				text: "Leaderboard"
				Layout.fillWidth: true
			}
		}

		SwipeView {
			id: view

			currentIndex: tabButtons.currentIndex
			Layout.fillWidth: true
			Layout.fillHeight: true

			OnlinePlayers {
				background_color: Material.color(Material.Grey, Material.shade300)
				online_players: root.online_players

				onSendChallenge: { root.makeChallenge(player_id, username) }
			}

			Leaderboard {
				id: leaderboardViewer
				background_color: Material.color(Material.Grey, Material.shade300)
				leaderboard: root.leaderboard
				username: root.username
			}
		}

		Rectangle {
			Layout.fillWidth: true
			Layout.minimumHeight: root.height * 0.01
			color: Material.primary
		}
	}

	SendChallengeDialog {
		id: sendChallengeDialog
		anchors.fill: parent
		onDialogClosed: { root.disappear() }
	}

	GetChallengeDialog {
		id: getChallengeDialog
		anchors.fill: parent
		onAcceptPressed: { root.acceptChallenge(); root.setUsername(username); getChallengeDialog.disappear(); root.disappear() }
		onDeclinePressed: { root.declineChallenge(); getChallengeDialog.disappear() }
	}

	states: [
		State {
			name: "retracted"
			PropertyChanges { target: root; y: -height; visible: false; focus: false }
		},
		State {
			name: "visible"
			PropertyChanges { target: root; y: 0; visible: true; focus: true }
		}
	]

	transitions: [
		Transition {
				from: "visible"; to: "retracted"
				SequentialAnimation {
					ScriptAction { script: { root.afterDisappear() } }
					NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
					PropertyAnimation { properties: "visible, focus" }
				}
		},
		Transition {
			from: "retracted"; to: "visible"
			SequentialAnimation {
				PropertyAnimation { properties: "visible, focus" }
				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
				ScriptAction { script: { root.afterAppear() } }
			}
		}
	]
}
