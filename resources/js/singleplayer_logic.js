function goGame() {
	pauseButton.enabled = true
	root.setFocus()
	var r = Math.floor(Math.random() * data.numShapes)
	root.shape_history = [r, r, r]
	root.color_history = [r, r, r]
	spawnPlayer()

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
		root.gameFailed()
		loseGame()
	}
}

function pauseGame() {
	playerTimer.stop()
	pauseMenu.appear()
}

function resumeGame() {
	pauseButton.enabled = false
	pauseMenu.disappear()
}

function resetGame() {
	playerTimer.stop()
	playerTimer.interval = root.timerInt
	root.shape_handle = 0
}

function restartGame() {
	resetGame()
	data.reset()
	pauseButton.enabled = false
	pauseMenu.disappear()
	gameOverMenu.disappear()
}

function winGame() {
	gameOverMenu.appear("You Win!")
	resetGame()
	resetTimer.start()
}

function loseGame() {
	gameOverMenu.appear("You Lose!")
	root.gameFailed()
	resetGame()
	resetTimer.start()
}

function doControl(control_id) {
	switch (control_id) {
	case 0 : data.rotateShape(root.shape_handle)
		break
	case 1 : servicePlayer()
		break
	case 2 : data.moveShapeLeft(root.shape_handle)
		break
	case 3 : data.moveShapeRight(root.shape_handle)
	}
}

function keyUp() {
	doControl(root.controls_order[0])
}

function keyDown() {
	if (root.mix_controls === false) {
		if (playerTimer.running === true)
			dropShape()
		else
			servicePlayer()
	} else {
		doControl(root.controls_order[1])
	}
}

function keyLeft() {
	doControl(root.controls_order[2])
}

function keyRight() {
	doControl(root.controls_order[3])
}

function dropShape() {
	if (root.drop_locked === false) {
		while (data.moveShapeDown(root.shape_handle))
			;
		if (playerTimer.running === true)
			playerTimer.restart()
	}
}

function spawnPlayer() {
	if (root.repeat_shape === false) {
		while (root.shape_history.includes(root.current_shape_type)) {
			root.current_shape_type = Math.floor(Math.random() * data.numShapes)
		}
		root.shape_history.shift()
		root.shape_history.push(root.current_shape_type)
	}

	var shape_color = root.color_history[0]
	while (root.color_history.includes(shape_color)) {
		shape_color = Math.floor(Math.random() * shape_colors.length)
	}
	root.color_history.shift()
	root.color_history.push(shape_color)

	root.shape_handle = data.spawnShape(root.current_shape_type, root.getColor(root.shape_colors[shape_color]))
	if (root.shape_handle === -1) {
		loseGame()
	}
}

function servicePlayer() {
	if (data.moveShapeDown(root.shape_handle) === false) {
		root.vanish_rows = data.checkRows()
		setVanishBar()
		spawnPlayer()
	}
}

function reduceTime() {
	//tickTimer.interval *= 1 - score/difficulty
}

function setVanishBar() {
	if (root.vanish_rows.length === 0)
		return;

	root.vanish_height = 1
	if (root.vanish_rows.length > 1) {
		for (var i = 1; i < root.vanish_rows.length; i++)
			if (root.vanish_rows[i] === (root.vanish_rows[i-1]+1)) {
				root.vanish_height++
			} else {
				break
			}
	}

	vanishBar.setY(root.vanish_rows[0]*root.block_size)
	vanishBar.setHeight(root.vanish_height*root.block_size)
	vanishBar.appear()
	vanishTimer.start()
}

function deleteRow() {
	for (var i = 0; i < root.vanish_height; i++) {
		data.deleteRow(root.vanish_rows[0])
		root.vanish_rows.shift()
	}
	vanishBar.disappear()

	switch (root.vanish_height) {
	case 1 : serviceState()
		break
	case 2 : root.sendSpecial(TetroGridQ.RepeatShape)
		break
	case 3 : root.sendSpecial(TetroGridQ.MixControls)
		break
	case 4 : root.sendSpecial(TetroGridQ.NoDrop)
	}

	reduceTime()
	setVanishBar()
}

function serviceSpecial(special_type) {
	var already_activated = false

	switch (special_type) {
	case TetroGridQ.RepeatShape : already_activated = activateRepeatShape()
		break
	case TetroGridQ.MixControls : already_activated = activateMixControls()
		break
	case TetroGridQ.NoDrop : already_activated = activateNoDrop()
	}

	if (already_activated === true) {
		root.returnSpecial(special_type)
	} else {
		effectScreen.activate(data.getTexture(special_type))
	}
}

function serviceReturnedSpecial(special_type) {
	switch (special_type) {
	case TetroGridQ.RepeatShape : awardPoints(2)
		break
	case TetroGridQ.MixControls : awardPoints(3)
		break
	case TetroGridQ.NoDrop : awardPoints(4)
	}
}

function serviceState() {
	if (root.effects_active === true) {
		effectScreen.cancelEffects()
		cancelEffects()
	} else {
		awardPoints(1)
	}
}

function cancelEffects() {
	root.repeat_shape = false
	root.controls_order = [0, 1, 2, 3]
	root.mix_controls = false
	root.drop_locked = false
	root.effects_active = false
}

function activateRepeatShape() {
	var check = root.repeat_shape
	root.repeat_shape = true
	root.effects_active = true
	return check
}

function activateMixControls() {
	var check = root.mix_controls
	root.controls_order = shuffle(root.controls_order)
	console.log(root.controls_order)
	root.mix_controls = true
	root.effects_active = true
	return check
}

function shuffle(array) {
	var i = array.length, tmp, r;

	while (currentIndex !== 0) {
		r = Math.floor(Math.random() * i);
		i--;

		tmp = array[i];
		array[i] = array[r];
		array[r] = tmp;
	}

	return array;
}

function activateNoDrop() {
	var check = root.drop_locked
	root.drop_locked = true
	root.effects_active = true
	return check
}
