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
		shape_type = Math.floor(Math.random() * numShapes)
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

function checkDown() {
	if (data.moveShapeDown(player1) === false) {
		var rows = data.checkRows()
		for (var i = 0; i < rows.length; i++) {
			vanishBar.setY(headerHeight + rows[i]*(table.height/data.rows))
			vanishBar.appear()
			row_id = rows[i]
			delayTimer.start()
			score++
			reduceTime()
		}

		tick()
	}
}

function dropShape(shape_id) {
	while (data.moveShapeDown(shape_id))
		;
}
