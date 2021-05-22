import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

import "qrc:/qml/components"
import "qrc:/qml/types"

Window {
	id: windowRoot
	visible: true
	width: 1920
	height: 1000
	visibility: Qt.WindowMaximized
	title: qsTr("Super Tetrominoes")

	function returnToMenu() { mainMenu.appear() }

	Loader {
		id: loader
		anchors.fill: parent
		active: false

		function deactivate() { active = false }
		function loadLocalMultiplayer() { sourceComponent = localMultiplayer; active = true }
	}

	Component {
		id: localMultiplayer
		LocalMultiplayer {
			onReturnToMenu: { windowRoot.returnToMenu() }
		}
	}

	MainMenu {
			id: mainMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onLocalMultiplayerPressed: { mainMenu.disappear(); loader.loadLocalMultiplayer() }
			onOnlineMultiplayerPressed: { sweller.activate() }
			onQuitButtonPressed: { Qt.callLater(Qt.quit) }

			onAfterDisappear: { loader.item.start() }
			onAfterAppear: { loader.deactivate() }
	}
}
