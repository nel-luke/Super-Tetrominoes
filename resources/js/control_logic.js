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
			Service.servicePlayer()
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
