import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

Item {
		id: root
		implicitWidth: 100
		implicitHeight: 50

		property alias username: label.text
		property color index_color: root.row_colors[index % 2]
		property color hover_color: Material.background

		property var row_colors: [
			Material.color(Material.Grey, Material.Shade500),
			Material.color(Material.Grey, Material.Shade600)
		]

		signal sendChallenge(var row_index)

		Rectangle {
			id: background
			anchors.fill: parent
			color: root.row_colors[index % 2]
		}
		MouseArea {
			id: area
			anchors.fill: parent
			hoverEnabled: true
			propagateComposedEvents: true
			onEntered: { background.color = root.hover_color }
			onExited: { background.color =  root.index_color }
		}
		Label {
			id: label
			width: parent.width * 0.25
			height: parent.height * 0.8
			anchors.left: parent.left
			anchors.leftMargin: root.width * 0.01
			anchors.verticalCenter: parent.verticalCenter
			font.bold: true
			fontSizeMode: Text.VerticalFit
			font.pointSize: 24
			color: "white"
		}
		Button {
			id: challengeButton
			anchors.right: parent.right
			anchors.rightMargin: root.width * 0.05
			anchors.verticalCenter: parent.verticalCenter
			text: "Challenge"
			onClicked: sendChallenge(index)
			onHoveredChanged: {
				background.color = challengeButton.hovered ? root.hover_color : root.index_color
			}
		}
}
