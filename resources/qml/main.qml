import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.15

import QtGraphicalEffects 1.15

import "qrc:/qml/components"
import "qrc:/qml/types"

Window {
	id: windowRoot
	visible: true
	width: 960 //1920
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
		function loadOnlineMultiplayer() { sourceComponent = onlineMultiplayer; active = true }
	}

	Component {
		id: localMultiplayer
		LocalMultiplayer {
			onReturnToMenu: { windowRoot.returnToMenu() }
		}
	}

	Component {
		id: onlineMultiplayer
		OnlineMultiplayer {
			onReturnToMenu: { windowRoot.returnToMenu() }
		}
	}

	MainMenu {
			id: mainMenu
			width: parent.width
			height: parent.height
			backgroundColor: Material.primary
			onLocalMultiplayerPressed: { mainMenu.disappear(); loader.loadLocalMultiplayer() }
			onOnlineMultiplayerPressed: { mainMenu.disappear(); loader.loadOnlineMultiplayer() }
			onQuitButtonPressed: { Qt.callLater(Qt.quit) }

			onAfterDisappear: { loader.item.start() }
			onAfterAppear: { loader.deactivate() }
	}

}
