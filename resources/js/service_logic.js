function spawnPlayer() {
	if (root.repeat_shape_count === 0 || root.change_repeat === true) {
		while (root.shape_history.includes(root.current_shape_type)) {
			root.current_shape_type = Math.floor(Math.random() * data.numShapes)
		}
		root.change_repeat = false
		root.shape_history.shift()
		root.shape_history.push(root.current_shape_type)
	}

	var shape_color = root.color_history[0]
	while (root.color_history.includes(shape_color)) {
		shape_color = Math.floor(Math.random() * root.shape_colors.length)
	}
	root.color_history.shift()
	root.color_history.push(shape_color)

	root.shapeSpawned(root.current_shape_type, root.getColor(root.shape_colors[shape_color]))
	root.shape_handle = data.spawnShape(root.current_shape_type, root.getColor(root.shape_colors[shape_color]))
	if (root.shape_handle === -1) {
		State.loseGame()
	}
}

function servicePlayer() {
	root.playerService()
	if (data.moveShapeDown(root.shape_handle) === false) {
		root.vanish_rows = data.checkRows()
		setVanishBar()

		if (root.dummy === false)
			spawnPlayer()
	}
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

	serviceState(root.vanish_height)
	setVanishBar()
}

function serviceSpecial(special_type) {
	if ((special_type & TetroGridQ.RepeatShape) !== 0) {
		Effects.incrementRepeatShape()
		effectScreen.incrementRepeatShape()
	}

	if ((special_type & TetroGridQ.MixControls) !== 0) {
		Effects.incrementMixControls()
		effectScreen.incrementMixControls()
	}

	effectScreen.activate()
}

function serviceState(num_points) {
	var original = num_points

	while (num_points !== 0) {
		if (root.repeat_shape_count !== 0) {
			Effects.decrementRepeatShape()
			effectScreen.decrementRepeatShape()
			num_points--
		} else {
			break
		}
	}

	while (num_points !== 0) {
		if (root.mix_controls_count !== 0) {
			Effects.decrementMixControls()
			effectScreen.decrementMixControls()
			num_points--
		} else {
			break
		}
	}

	if (num_points !== 0) {
		root.points_to_add = num_points

		switch (num_points) {
		case 2 : root.sendSpecial(TetroGridQ.RepeatShape)
			break
		case 3 : root.sendSpecial(TetroGridQ.MixControls)
			break
		case 4 : root.sendSpecial(TetroGridQ.RepeatShape | TetroGridQ.MixControls)
		}
	}

	if (num_points !== original) {
		effectScreen.activate()
	} else {
		servicePoints()
	}
}

function servicePoints() {
	if (root.points_to_add !== 0) {
		root.points_to_add--
		root.points++
		scoreText.activate()
		root.getPoints(1)
		State.adjustTime()
	}
}

function removePoints(num_points) {
	root.points -= num_points
	scoreText.activate()
	if (root.points <= 0) {
		loseGame()
	}
	State.adjustTime()
}
