import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
	id: root

	property alias background_color: background.color
	property var online_players: []

	signal sendChallenge(var player_id, var username)

	Rectangle {
		id: background
		anchors.fill: parent
	}

	ListView {
		anchors.fill: parent
		model: root.online_players.length

		delegate: OnlinePlayerRow {
			width: parent.width
			username: root.online_players[index].username
			onSendChallenge: {
				root.sendChallenge(root.online_players[index].id, root.online_players[index].username) }

		}
	}
}
