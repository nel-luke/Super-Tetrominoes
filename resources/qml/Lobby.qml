import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import "qrc:/qml/types"

Item {
	id: root

	state: "visible"

	required property var username
	required property var score
	required property var online_players

	function disappear() { root.state = "retracted"; root.stopRefresh() }
	function appear() { root.state = "visible"; root.startRefresh() }

	function startRefresh() { listTimer.start() }
	function stopRefresh() { listTimer.stop() }

	function activateDialog(message) { dialog.appear() }

	signal returnToMenu()
	signal refreshPlayers()
	signal sendChallenge(var player_id)

	signal acceptChallenge()
	signal declineChallenge()

	signal afterDisappear()

	Pane {
		anchors.fill: parent
		//color: Material.primary
	}

	ColumnLayout {
		anchors.fill: parent

		RowLayout {
			Layout.minimumHeight: 50

			Item {
				Layout.minimumWidth: parent.width/3
				Label {
					anchors.centerIn: parent
					text: "Welcome, " + root.username + "!"
				}
			}
			Item {
				Layout.minimumWidth: parent.width/3
				Label {
					anchors.centerIn: parent
					text: "Score: " + root.score
				}
			}
			Item {
				Layout.fillWidth: true
				Button {
					anchors.centerIn: parent
					text: "Logout"
					onClicked: root.returnToMenu()
				}
			}
		}

		TabBar {
			id: tabButtons
			Layout.fillWidth: true
			Layout.minimumHeight: 50
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

			Timer {
				id: listTimer
				interval: 1000
				repeat: true
				onTriggered: { root.refreshPlayers() }
			}

			Item {
					Frame {
						id: thing
						anchors.fill: parent
						background: Rectangle { color: "white" }
						ListView {
							anchors.fill: parent
							model: root.online_players
							delegate: OnlinePlayerRow {
								text: root.online_players[index].username
								onSendChallenge: {
									root.sendChallenge(root.online_players[row_index].id) }
							}
							add: Transition {
									NumberAnimation { properties: "x,y"; from: 100; duration: 1000 }
							}
							addDisplaced: Transition {
									NumberAnimation { properties: "x,y"; duration: 1000 }
							}
						}
					}
			}
			Item {
					id: secondPage
			}
		}
	}

//	Dialog {
//			id: dialog
//			anchors.centerIn: parent
//			title: "Challenge Request"
//			visible: false
//			modal: true
//			standardButtons: Dialog.Ok | Dialog.Cancel

//			property int timeLeft: 10

//			implicitWidth: parent.width/3
//			implicitHeight: parent.height/3

//			function appear(message) {
//				msg.text = message
//				dialog.timeLeft = 10;
//				//dialog.setModal(true)
//				dialog.open()
//				//downTimer.start()
//				dialog.visible = true
//			}

//			Component.onCompleted: {
//				//dialog.standardButton(Dialog.Ok).text = "Accept"
//				//dialog.standardButton(Dialog.Cancel).text = "Decline (" + dialog.timeLeft +")"
//			}

//			onAccepted: { root.acceptChallenge() }
//			onRejected: { root.declineChallenge() }

//			Timer {
//				id: downTimer
//				interval: 1000
//				repeat: true
//				onTriggered: {
//					if (dialog.timeLeft-- === 0) {
//						downTimer.stop(); dialog.reject()
//					} else {
//						dialog.standardButton(Dialog.Cancel).text = "Decline (" + dialog.timeLeft +")"
//					}
//				}
//			}

//			Label { id: msg }
//	}

	Rectangle {
		id: dialog

		width: parent/3
		height: parent/3
		anchors.centerIn: parent

		visible: false

		function appear() {
			dialog.visible = true
		}

		function disappear() {
			dialog.visible = false
		}

		Row {
			width: parent.width
			height: parent.height/5
			spacing: 2

			Button {
				text: "Accept"
				onClicked: root.acceptChallenge()
			}

			Button {
				text: "Decline"
				onClicked: root.declineChallenge()
			}
		}
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
			}
		}
	]
}
