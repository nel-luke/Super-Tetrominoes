function prepareGame() {
	root.disablePauseButton()
	root.setFocus()
	var r = Math.floor(Math.random() * data.numShapes)
	root.shape_history = [r, r, r]
	root.color_history = [r, r, r]
}

function goGame() {
	root.enablePauseButton()
	if (root.game_started === false) {
		Service.spawnPlayer()
		root.game_started = true
	}

	if (root.debug !== true)
		playerTimer.start()
}

function awardPoints(num_points) {
	root.points += num_points
	scoreText.activate()
	root.getPoints(num_points)
}

function removePoints(num_points) {
	root.points -= num_points
	scoreText.activate()
	if (root.points <= 0) {
		loseGame()
	}
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

function restartGame() {
	resetGame()
	data.reset()
	gameOverMenu.disappear()
	prepareGame()
}

function winGame() {
	gameOverMenu.appear("You Win!")
	resetGame()
	resetTimer.start()
}

function loseGame() {
	root.gameFailed()
	gameOverMenu.appear("You Lose!")
	resetGame()
	resetTimer.start()
}

function reduceTime() {
	//tickTimer.interval *= 1 - score/difficulty
}
