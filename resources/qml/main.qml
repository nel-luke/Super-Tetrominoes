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
	width: 720
	height: 770
	title: qsTr("Tetris")

	readonly property var shape_colors:
			[Material.Red, Material.Purple, Material.Blue, Material.Green,
			Material.Yellow, Material.Orange, Material.Brown]

	function returnToMenu() { mainMenu.appear() }

	Loader {
		id: loader
		anchors.fill: parent
		active: false
	//sourceComponent: singlePlayerClassic

		function deactivate() { active = false }
		function loadSingleplayerClassic() { sourceComponent = singlePlayerClassic; active = true }
	}

	Component {
		id: singlePlayerClassic
		SinglePlayerClassic {
			shape_colors: windowRoot.shape_colors
			onReturnToMenu: { windowRoot.returnToMenu() }
		}
	}

	MainMenu {
			id: mainMenu
		//state: "retracted"
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onQuitButtonPressed: { Logic.quitGame() }
			onSingleplayerClassicPressed: { mainMenu.disappear(); loader.loadSingleplayerClassic() }

			onAfterDisappear: { loader.item.start() }
			onAfterAppear: { loader.deactivate() }
	}
}
