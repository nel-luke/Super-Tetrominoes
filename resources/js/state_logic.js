function prepareGame() {
	root.disablePauseButton()
	var r = Math.floor(Math.random() * data.numShapes)
	root.shape_history = [r, r, r]
	root.color_history = [r, r, r]
}

function goGame() {
	root.enablePauseButton()
	root.setFocus()
	if (root.game_started === false) {
		if (root.dummy === false)
			Service.spawnPlayer()
		root.game_started = true
	}

	if ((root.debug || root.dummy) === false)
		playerTimer.start()
}

function pauseGame() {
	playerTimer.stop()
}

function resumeGame() {
	root.disablePauseButton()
	countDown.activate()
}

function resetGame() {
	playerTimer.stop()
	playerTimer.interval = root.timerInt
	root.shape_handle = 0
	Effects.cancelEffects()
	root.game_started = false
}

function winGame() {
	resetGame()
	resetTimer.start()
}

function loseGame() {
	root.gameFailed()
	resetGame()
	resetTimer.start()
}

function adjustTime() {
	//tickTimer.interval *= 1 - score/difficulty
}
