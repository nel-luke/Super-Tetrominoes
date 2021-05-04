function startGame(rows, columns) {
		data.rows = rows
		data.columns = columns
		tick()
		background.focus = true
		tickTimer.start()
}

function pauseGame() {
	tickTimer.stop()
	pauseMenu.appear()
}

function resumeGame() {
	pauseMenu.disappear()
	background.focus = true
	tickTimer.start()
}

function quitGame() {
	Qt.callLater(Qt.quit)
}

function resetGame() {
	tickTimer.stop()
	tickTimer.interval = timerInt
	score = 0
	player1 = 0
}

function tick() {
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

	var didSpawn = data.spawn(++player1, shape_type, getColor(shape_colors[shape_color]))
	if (didSpawn === false) {
		mainMenu.appear()
		resetGame()
		resetTimer.start()
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

function checkDown() {
	if (data.moveShapeDown(player1) === false) {
		vanish_rows = vanish_rows.concat(data.checkRows())
		setVanishBar()
		tick()
	}
}

function deleteRow() {
	data.deleteRow(vanish_rows[0])
	vanish_rows.shift()
	vanishBar.disappear()
	score++
	reduceTime()
	setVanishBar()
}

function dropShape(shape_id) {
	while (data.moveShapeDown(shape_id))
		;
	checkDown()
}
