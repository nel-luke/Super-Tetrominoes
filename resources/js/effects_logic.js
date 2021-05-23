function cancelEffects() {
	root.repeat_shape_count = 0
	root.change_repeat = false
	effectScreen.repeat_shape_count = 0

	root.mix_controls_count = 0
	root.controls_order = [0, 1, 2, 3]
	effectScreen.mix_controls_count = 0
}

function incrementRepeatShape() {
	root.repeat_shape_count++
	root.change_repeat = true
}

function decrementRepeatShape() {
	root.repeat_shape_count--
	root.change_repeat = true
}

function incrementMixControls() {
	root.mix_controls_count++
	root.controls_order = shuffle(root.controls_order)
}

function decrementMixControls() {
	root.mix_controls_count--

	if (root.mix_controls_count !== 0) {
		root.controls_order = shuffle(root.controls_order)
	} else {
		root.controls_order = [0, 1, 2, 3]
	}
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

