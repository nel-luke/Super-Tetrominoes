import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import QtQuick.Layouts 1.15

Item {
	id: root
	state: "visible"

	property alias backgroundColor: background.color

	function disappear() { root.state = "retracted" }
	function appear() { root.state = "visible" }

	function usernameExists() {
		usernameField.text = ''
		usernameField.placeholderTextColor = Material.color(Material.Red)
		usernameField.placeholderText = "Username already exists"
	}

	signal loginPressed(var username, var real_name)
	signal backToMenuPressed()
	signal quitButtonPressed()

	signal afterDisappear()

	Rectangle {
		id: background
		anchors.fill: parent
	}

	ColumnLayout {
		spacing: 2
		y: parent.height/2 - height/2
		width: parent.width/3
		anchors.horizontalCenter: parent.horizontalCenter

		RowLayout {
			spacing: 2
			Layout.fillHeight: true
			Layout.fillWidth: true
			Label {
				text: "Username:"
				Layout.minimumWidth: parent.width/2
				Layout.fillHeight: true
			}
			TextField {
				id: usernameField
				Layout.fillWidth: true
				Layout.fillHeight: true
				placeholderText: "Enter username"
				validator: RegularExpressionValidator { regularExpression: /[\w]{1,10}/ }
			}
		}

		RowLayout {
			spacing: 2
			Layout.fillHeight: true
			Layout.fillWidth: true
			Label {
				text: "Real Name:"
				Layout.minimumWidth: parent.width/2
				Layout.fillHeight: true
			}
			TextField {
				id: realNameField
				placeholderText: "Enter real name"
				Layout.fillWidth: true
				Layout.fillHeight: true
				validator: RegularExpressionValidator { regularExpression: /[\w]{1,10}/ }
			}
		}

		RowLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Button {
				text: "Back to Main Menu"
				Layout.minimumWidth: parent.width/2
				Layout.fillHeight: true
				onClicked: { root.backToMenuPressed() }
			}
			Button {
				text: "Login"
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: { root.loginPressed(usernameField.text, realNameField.text) }
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
