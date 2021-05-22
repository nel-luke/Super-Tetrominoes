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
		shape_color = Math.floor(Math.random() * root.shape_colors.length)
	}
	root.color_history.shift()
	root.color_history.push(shape_color)

	root.shape_handle = data.spawnShape(root.current_shape_type, root.getColor(root.shape_colors[shape_color]))
	if (root.shape_handle === -1) {
		State.loseGame()
	}
}

function servicePlayer() {
	if (data.moveShapeDown(root.shape_handle) === false) {
		root.vanish_rows = data.checkRows()
		setVanishBar()
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

	switch (root.vanish_height) {
	case 1 : serviceState()
		break
	case 2 : root.sendSpecial(TetroGridQ.RepeatShape)
		break
	case 3 : root.sendSpecial(TetroGridQ.MixControls)
		break
	case 4 : root.sendSpecial(TetroGridQ.NoDrop)
	}

	State.reduceTime()
	setVanishBar()
}

function serviceSpecial(special_type) {
	var already_activated = false

	switch (special_type) {
	case TetroGridQ.RepeatShape : already_activated = Effects.activateRepeatShape()
		break
	case TetroGridQ.MixControls : already_activated = Effects.activateMixControls()
		break
	case TetroGridQ.NoDrop : already_activated = Effects.activateNoDrop()
	}

	if (already_activated === true) {
		root.returnSpecial(special_type)
	} else {
		effectScreen.activate(data.getTexture(special_type))
	}
}

function serviceReturnedSpecial(special_type) {
	switch (special_type) {
	case TetroGridQ.RepeatShape : State.awardPoints(2)
		break
	case TetroGridQ.MixControls : State.awardPoints(3)
		break
	case TetroGridQ.NoDrop : State.awardPoints(4)
	}
}

function serviceState() {
	if (root.effects_active === true) {
		effectScreen.activateCancelEffects()
		Effects.cancelEffects()
	} else {
		State.awardPoints(1)
	}
}
