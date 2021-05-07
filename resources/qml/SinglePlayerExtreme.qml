import QtQuick 2.0

Item {
	property int player1_y: 0

	property int lazy1: 0
	property int lazy1_y: 0
	property var lazy1_shape_history: [0, 1, 2]
	property var lazy1_color_history: [0, 1, 2]

	Timer {
		id: lazy1Timer
		interval: 5000
		repeat: true
		onTriggered: { Logic.serviceLazy1() }
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: Material.background
		Keys.onPressed: {
			if (event.key === Qt.Key_Up || event.key === Qt.Key_W)
				data.rotateShape(lazy1_y > player1_y ? lazy1 : player1)
			else if (event.key === Qt.Key_Down || event.key === Qt.Key_S)
				Logic.dropShape(lazy1_y > player1_y ? lazy1 : player1)
			else if (event.key === Qt.Key_Left || event.key === Qt.Key_A)
				data.moveShapeLeft(lazy1_y > player1_y ? lazy1 : player1)
			else if (event.key === Qt.Key_Right || event.key === Qt.Key_D)
				data.moveShapeRight(lazy1_y > player1_y ? lazy1 : player1)
		}
	}
}
