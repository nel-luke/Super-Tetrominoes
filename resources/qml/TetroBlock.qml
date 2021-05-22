import QtQuick 2.0
import QtQuick.Controls.Material 2.15

Item {
	readonly property int borderSize: 1
	property variant gridColors: [
		Material.color(Material.Grey, Material.Shade300),
		Material.color(Material.Grey, Material.Shade400)
	]

	Rectangle {
		color: "black"
		anchors.fill: parent
	}

	Rectangle {
		height: parent.height - borderSize * (hasBorderTop + hasBorderBottom)
		width: parent.width - borderSize * (hasBorderLeft + hasBorderRight)
		color: blockColor != "#000000" ? blockColor : gridColors[((row%2)+(column%2))%2]
		x: borderSize * hasBorderLeft
		y: borderSize * hasBorderTop
	}
}
