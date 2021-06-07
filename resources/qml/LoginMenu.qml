import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import QtQuick.Layouts 1.15

Item {
	id: root
	state: "visible"

	property alias backgroundColor: background.color
	property alias no_response: errorLabel.visible

	property color red_color: Material.color(Material.Red, Material.Shade600)
	property color default_color: "#4B352D"

	property string username_text: "Enter username"

	function disappear() { if (!root.no_response) { waitTimer.stop(); root.state = "retracted"; loginButton.enabled = true } }
	function appear() { root.state = "visible" }

	function resetTextFields() {
		usernameField.placeholderText = root.username_text
		usernameField.placeholderTextColor = root.default_color
		realNameField.placeholderTextColor = root.default_color
	}

	function usernameExists() {
		if (!root.no_response) {
			waitTimer.stop()
			loginButton.enabled = true
			usernameField.text = ''
			usernameField.placeholderTextColor = root.red_color
			usernameField.placeholderText = "Username exists"
		}
	}

	function checkText(username, real_name) {
		var check = true
		if (username.length === 0) {
			usernameField.placeholderTextColor = root.red_color
			check = false
		}

		if (real_name.length === 0) {
			realNameField.placeholderTextColor = root.red_color
			check = false
		}

		if (check)
			root.deactivateLoginButton(username, real_name)
	}

	function deactivateLoginButton(username, real_name) {
		loginButton.enabled = false
		root.no_response = false
		waitTimer.restart()
		root.loginPressed(username, real_name)
	}

	signal loginPressed(var username, var real_name)
	signal backToMenuPressed()
	signal quitButtonPressed()

	signal afterDisappear()

	Timer {
		id: waitTimer
		interval: 5000
		repeat: false
		onTriggered: { loginButton.enabled = true; root.no_response = true  }
	}

	Rectangle {
		id: background
		anchors.fill: parent
	}

	Label {
		id: errorLabel
		visible: false
		width: parent.width / 3
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: columns.top
		horizontalAlignment: Text.AlignHCenter
		fontSizeMode: Text.HorizontalFit
		font.pointSize: 24
		font.bold: true
		color: root.red_color
		text: "Could not connect to server. Please try again."
	}

	ColumnLayout {
		id: columns
		spacing: 4
		y: parent.height/2 - height/2
		width: parent.width/3
		anchors.horizontalCenter: parent.horizontalCenter

		RowLayout {
			spacing: 2
			Layout.fillHeight: true
			Layout.fillWidth: true
			Label {
				text: "Username: "
				Layout.preferredWidth: parent.width/2
				Layout.fillHeight: true
				horizontalAlignment: Text.AlignRight
				fontSizeMode: Text.Fit
				color: "white"
				font.pointSize: 24
				font.bold: true
			}
			TextField {
				id: usernameField
				Layout.fillWidth: true
				Layout.fillHeight: true
				placeholderText: root.username_text
				validator: RegularExpressionValidator { regularExpression: /[\w]{1,10}/ }
				onFocusChanged: { root.resetTextFields() }
			}
		}

		RowLayout {
			spacing: 2
			Layout.fillHeight: true
			Layout.fillWidth: true
			Label {
				text: "Real Name: "
				Layout.preferredWidth: parent.width/2
				Layout.fillHeight: true
				horizontalAlignment: Text.AlignRight
				fontSizeMode: Text.Fit
				color: "white"
				font.pointSize: 24
				font.bold: true
			}
			TextField {
				id: realNameField
				placeholderText: "Enter real name"
				Layout.fillWidth: true
				Layout.fillHeight: true
				validator: RegularExpressionValidator { regularExpression: /[\w]{1,10}/ }
				onFocusChanged: { root.resetTextFields() }
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
			id: loginButton
				text: "Login"
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: { root.checkText(usernameField.text, realNameField.text) }
			}
		}
	}

	states: [
		State {
			name: "retracted"
			PropertyChanges { target: root; y: -height; visible: false; /*focus: false*/ }
		},
		State {
			name: "visible"
			PropertyChanges { target: root; y: 0; visible: true; /*focus: true*/ }
		}
	]

	transitions: [
		Transition {
				from: "visible"; to: "retracted"
				SequentialAnimation {
					ScriptAction { script: { root.afterDisappear() } }
					NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
					PropertyAnimation { properties: "visible" }
				}
		},
		Transition {
			from: "retracted"; to: "visible"
			SequentialAnimation {
				PropertyAnimation { properties: "visible" }
				NumberAnimation { properties: "y"; easing.type: Easing.InOutQuad; duration: 500 }
				ScriptAction { script: { usernameField.forceActiveFocus() } }
			}
		}
	]
}
