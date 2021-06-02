import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
	id: root
	state: "visible"

	property alias go_back_text: exitButton.text
	property color background_color
	property alias go_back_visible: exitButton.visible

	function disappear() { root.state = "retracted" }
	function appear() { swipeView.currentIndex = 0; root.state = "visible" }

	signal goBack()
	signal afterDisappear()

	SwipeView {
		id: swipeView

		currentIndex: 0
		anchors.fill: parent

		Page {
			id: firstPage

			Rectangle {
				anchors.fill: parent
				color: root.background_color
			}

			Label {
				anchors.centerIn: parent
				text: "Page 1"
			}

			Button {
				id: exitButton
				anchors.left: parent.left
				anchors.leftMargin: parent.width * 0.05
				anchors.bottom: parent.bottom
				anchors.bottomMargin: parent.height * 0.05
				onClicked: { root.goBack() }
			}
		}
			Item {
				id: secondPage
				Rectangle {
					anchors.fill: parent
					color: root.background_color
				}

				Label {
					anchors.centerIn: parent
					text: "Page 2"
				}
			}
			Item {
				id: thirdPage

				Rectangle {
					anchors.fill: parent
					color: root.background_color
				}

				Label {
					anchors.centerIn: parent
					text: "Page 3"
				}
			}
	}

//	RoundButton {
//		id: backward
//		width: 50
//		height: width

//		anchors.left: parent.left
//		anchors.leftMargin: 10
//		anchors.verticalCenter: parent.verticalCenter

//		opacity: swipeView.currentIndex === 0 ? false : 1

//		Behavior on opacity {
//			NumberAnimation { duration: 300 }
//		}

//		Image {
//			width: parent.width * 0.8
//			height: width
//			anchors.centerIn: parent
//			source: "qrc:/textures/backward.svg"
//		 }

//		 onClicked: {
//			 if(swipeView.currentIndex > 0)
//					 swipeView.currentIndex--
//		 }
//	}

//	 RoundButton {
//		 id: forward
//		 width: 50
//		 height: width

//		 anchors.right: parent.right
//		 anchors.rightMargin: 10
//		 anchors.verticalCenter: parent.verticalCenter

//		 opacity: swipeView.currentIndex === swipeView.count-1 ? 0 : 1

//		 Behavior on opacity {
//			 NumberAnimation { duration: 300 }
//		 }

//			Image {
//				width: parent.width * 0.8
//				height: width
//				anchors.centerIn: parent
//				source: "qrc:/textures/forward.svg"
//			}

//			onClicked: {
//				if(swipeView.currentIndex < swipeView.count)
//						swipeView.currentIndex++
//			}
//	 }

//	 Button {
//		 anchors.horizontalCenter: parent.horizontalCenter
//		 y: parent.height * 0.75

//		 opacity: swipeView.currentIndex === swipeView.count-1 ? 1 : 0

//		 Behavior on opacity {
//			 NumberAnimation { duration: 300 }
//		 }

//		 text: "Start match!"
//	 }


	PageIndicator {
		id: indicator

		count: swipeView.count
		currentIndex: swipeView.currentIndex

		anchors.bottom: swipeView.bottom
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Keys.onPressed: {
		switch (event.key) {
		case Qt.Key_Left:
		case Qt.Key_A:
			if(swipeView.currentIndex > 0)
					swipeView.currentIndex--
			break;
		case Qt.Key_Right:
		case Qt.Key_D:
			if(swipeView.currentIndex < swipeView.count-1)
					swipeView.currentIndex++
			break;
		case Qt.Key_Up:
		case Qt.Key_W:
			if (swipeView.currentIndex === swipeView.count-1)
				root.disappear()
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
		}
//		Transition {
//			from: "retracted"; to: "visible"
//			SequentialAnimation {
//				PropertyAnimation { properties: "visible, focus" }
//				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
//			}
//		}
	]
}
