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
	root.mix_controls = true
	root.effects_active = true
	return check
}

function shuffle(array) {
	var i = array.length, tmp, r;

	while (i !== 0) {
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
