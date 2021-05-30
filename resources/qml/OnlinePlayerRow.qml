import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Item {
		id: root
		implicitWidth: thing.width
		implicitHeight: 50

		property alias text : label.text

		signal sendChallenge(var row_index)

		Rectangle {
			id: background
			anchors.fill: parent
			color: "red"
		}

		MouseArea {
			id: area
			anchors.fill: parent
			hoverEnabled: true
			onEntered: { background.color = "green" }
			onExited: { background.color = "red" }
		}
		Row {
		Label {
			id: label
		}
		Button {
			text: "Callenge"
			onClicked: sendChallenge(index)
		}
		}

}
