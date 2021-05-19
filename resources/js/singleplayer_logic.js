function goGame() {
	pauseButton.enabled = true
	background.focus = true
	player1Timer.start()
}

function pauseGame() {
	player1Timer.stop()
	pauseMenu.appear()
}

function resumeGame() {
	pauseButton.enabled = false
	pauseMenu.disappear()
}

function resetGame() {
	player1Timer.stop()
	player1Timer.interval = root.timerInt
	root.score = 0
	root.player1 = 0
}

function restartGame() {
	resetGame()
	data.reset()
	pauseButton.enabled = false
	pauseMenu.disappear()
	gameOverMenu.disappear()
}

function spawnPlayer1() {
	var shape_type = player1_shape_history[0]
	while (player1_shape_history.includes(shape_type)) {
		shape_type = Math.floor(Math.random() * data.numShapes)
	}
	player1_shape_history.shift()
	player1_shape_history.push(shape_type)

	var shape_color = player1_color_history[0]
	while (player1_color_history.includes(shape_color)) {
		shape_color = Math.floor(Math.random() * shape_colors.length)
	}
	player1_color_history.shift()
	player1_color_history.push(shape_color)

	var special_type = 0
	if (root.player1_spawn_special.length !== 0) {
		special_type = root.player1_spawn_special[0]
		root.player1_spawn_special.shift()
	}

	player1 = data.spawn(shape_type, getColor(shape_colors[shape_color]), special_type)
	if (player1 === -1) {
		gameOverMenu.appear()
		resetGame()
		resetTimer.start()
	}
}

function servicePlayer1() {
	var player1_y = data.moveShapeDown(player1)
	if (player1_y === -1) {
		root.vanish_rows = root.vanish_rows.concat(data.checkRows())
		setVanishBar()
		spawnPlayer1()
	}
}

function reduceTime() {
	//tickTimer.interval *= 1 - score/difficulty
}

function setVanishBar() {
	if (vanish_rows.length === 0)
		return;

	vanishBar.setY(headerHeight + vanish_rows[0]*(table.height/data.rows))
	vanishBar.appear()
	vanishTimer.start()
}

function deleteRow() {
	data.deleteRow(vanish_rows[0])
	vanish_rows.shift()
	vanishBar.disappear()
	score++
	scoreText.activate()

	reduceTime()
	setVanishBar()
}

function dropShape(shape_id) {
	while (data.moveShapeDown(shape_id) !== -1)
		;
}

function serviceSpecial(special_type) {
	root.player1_activate_special.push(special_type)
	if (root.player1_activate_special.length === 1)
		specialTimer.start()
}

function activateSpecial() {
	var special = root.player1_activate_special[0]
	effectScreen.activate(data.getSingle(special))

	switch (special) {
	case TetroGridQ.CancelEffect : activateCancelEffects()
		break;
	case TetroGridQ.NoDrop : activateNoDrop()
		break;
	}

	root.player1_activate_special.shift()
	if (root.player1_activate_special.length !== 0)
		specialTimer.start()
}

function buyEffect() {
	if (root.score === 0)
		return

	root.player1_spawn_special.push(TetroGridQ.NoDrop)
	score--
	scoreText.activate()
}

function activateCancelEffects() {
	root.player1_drop_locked = false
}

function activateNoDrop() {
	root.player1_drop_locked = true
	root.player1_spawn_special.unshift(TetroGridQ.CancelEffect)
}
