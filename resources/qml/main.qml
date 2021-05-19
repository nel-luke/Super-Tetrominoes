import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

import "qrc:/js/main_logic.js" as Logic
import "qrc:/qml/components"
import "qrc:/qml/types"

Window {
	id: windowRoot
	visible: true
	width: 1920
	height: 1000
	visibility: Qt.WindowMaximized
	title: qsTr("Super Tetrominoes")

	readonly property var shape_colors:
			[Material.Red, Material.Purple, Material.Blue, Material.Green,
			Material.Yellow, Material.Orange, Material.Brown]

	function returnToMenu() { mainMenu.appear() }

	Loader {
		id: loader
		anchors.fill: parent
		active: false

		function deactivate() { active = false }
		function loadSingleplayerEasy() { sourceComponent = singleplayer; active = true }
	}

	Component {
		id: singleplayer
		Singleplayer {
			shape_colors: windowRoot.shape_colors
			onReturnToMenu: { windowRoot.returnToMenu() }
		}
	}

	MainMenu {
			id: mainMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onQuitButtonPressed: { Logic.quitGame() }
			onSingleplayerEasyPressed: { mainMenu.disappear(); loader.loadSingleplayerEasy() }
			onMultiPressed: { sweller.activate() }

			onAfterDisappear: { loader.item.start() }
			onAfterAppear: { loader.deactivate() }
	}
}
