#ifndef C_SHAPES_H
#define C_SHAPES_H

// 1 = left
// 2 = right
// 4 = top
// 8 = bottom

#define numShapes 7
unsigned short c_shapes[numShapes][8] {
	{00, 00, 00, 00,
	 13, 12, 12, 14},

	{00, 07, 00, 00,
	 00,  9, 12, 14},

	{00, 00, 00, 07,
	 00, 13, 12, 10},

	{00, 05, 06, 00,
	 00,  9, 10, 00},

	{00, 00, 05, 14,
	 00, 13, 10, 00},

	{00, 13, 06, 00,
	 00, 00,  9, 14},

	{00, 00, 07, 00,
	 00, 13,  8, 14}
};

#endif // C_SHAPES_H
