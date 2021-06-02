import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Item {
	id: root

	property alias background_color: background.color
	property var leaderboard: []
	property string username: ""

	Rectangle {
		id: background
		anchors.fill: parent
	}

	ListView {
		id: view
		anchors.fill: parent
		model: root.leaderboard.length
		clip: true

		delegate: LeaderboardRow {
			width: parent.width
			username: root.leaderboard[index].username
			highlighted: username === root.username ? true : false
			score: root.leaderboard[index].score
		}
	}
}
