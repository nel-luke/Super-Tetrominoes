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
	root.controls_order = shuffle(root.controls_order, root.shape_handle)
}

function decrementMixControls() {
	root.mix_controls_count--

	if (root.mix_controls_count !== 0) {
		root.controls_order = shuffle(root.controls_order, root.shape_handle)
	} else {
		root.controls_order = [0, 1, 2, 3]
	}
}

function shuffle(array, seed) {
	var i = array.length
	var tmp, r;

	while (i-- !== 0) {
		r = random(seed, 0, array.length)

		tmp = array[i]
		array[i] = array[r]
		array[r] = tmp
	}

	console.log(array)
	return array
}



function random(seed, i, f) {
	if (typeof random.state === 'undefined')
		random.state = seed

	var m = 0x80000000
	var a = 1103515245
	var c = 12435

	var range = f - i
	random.state = ((a * random.state + c) % m)
	return i + Math.floor((random.state/m) * range)
}

