#include "../include/tetrogridq.h"
#include "../include/c_shapes.h"

TetroGridQ::TetroGridQ(QObject* parent) : QAbstractTableModel(parent), matrix(1), new_shape_id(1) {
	matrix[0].push_back({ 0, QColor(0, 0, 0), BorderNone });

	for (int i = 0; i < numShapes; ++i) {
		shapes.push_back(QGenericMatrix<4, 2, unsigned int>(c_shapes[i]));
	}

	srand(time(NULL));
}

void TetroGridQ::setRows(unsigned int count) {
		if (count > getRows()) {
				insertRows(0, count - getRows());
		} else if (count < getRows()) {
				removeRows(0, getRows() - count);
		}
		emit rowsChanged();
}

void TetroGridQ::setColumns(unsigned int count) {
		if (count > getColumns()) {
				insertColumns(0, count - getColumns());
		} else if (count < getColumns()) {
				removeColumns(0, getColumns() - count);
		}
		emit columnsChanged();
}

// Inherited Read Methods
int TetroGridQ::rowCount(const QModelIndex& /*parent*/) const {
		return matrix.size();
}

int TetroGridQ::columnCount(const QModelIndex& /*parent*/) const {
		return matrix.at(0).size();
}

auto TetroGridQ::data(const QModelIndex& index, int role) const
-> QVariant {
		QVariant result;
		switch (role) {
			case  blockColor: result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).color);
					break;
			case hasBorderLeft : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).properties & BorderLeft ? 1 : 0);
					break;
			case hasBorderRight : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).properties & BorderRight ? 1 : 0);
					break;
			case hasBorderTop : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).properties & BorderTop ? 1 : 0);
					break;
			case hasBorderBottom : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).properties & BorderBottom ? 1 : 0);
					break;
				default : result = QVariant();
		}
		return result;
}

auto TetroGridQ::headerData(int section, Qt::Orientation orientation, int role) const
-> QVariant {
		if (orientation == Qt::Horizontal)
				return QVariant();

		QVariant result;
		switch (role) {
				case Qt::DisplayRole : result = QVariant(section).toString();
						break;
				default : result = QVariant();
		}
		return result;
}

auto TetroGridQ::roleNames() const
-> QHash<int, QByteArray> {
		QHash<int, QByteArray> roles;
		roles[blockColor] = "blockColor";
		roles[hasBorderLeft] = "hasBorderLeft";
		roles[hasBorderRight] = "hasBorderRight";
		roles[hasBorderTop] = "hasBorderTop";
		roles[hasBorderBottom] = "hasBorderBottom";
		return roles;
}


// Inherited Write Methods
bool TetroGridQ::setData(const QModelIndex&, const QVariant&, int) {
		return false;
}

auto TetroGridQ::flags(const QModelIndex& /*index*/) const
-> Qt::ItemFlags {
		return Qt::ItemIsSelectable | Qt::ItemNeverHasChildren
						| Qt::ItemIsEnabled;
}


// Inherited Resize Methods
bool TetroGridQ::insertRows(int before_row, int count, const QModelIndex& parent) {
		beginInsertRows(parent, before_row + 1, before_row + count);
		matrix.insert(matrix.begin() + before_row, count,
									std::vector<block>(getColumns(), {0, QColor(0, 0, 0), BorderNone }));
		endInsertRows();
		return true;
}

bool TetroGridQ::removeRows(int from_row, int count, const QModelIndex &parent) {
		beginRemoveRows(parent, from_row, from_row + count - 1);
		matrix.erase(matrix.begin() + from_row, matrix.begin() + from_row + count);
		endRemoveRows();
		return true;
}

bool TetroGridQ::insertColumns(int before_column, int count, const QModelIndex& parent) {
		beginInsertColumns(parent, before_column + 1, before_column + count);
		for (auto& it : matrix) {
				it.insert(it.begin() + before_column, count, { 0, QColor(0, 0, 0), BorderNone });
		}
		endInsertColumns();
		return true;
}

bool TetroGridQ::removeColumns(int from_column, int count, const QModelIndex &parent) {
		beginRemoveColumns(parent, from_column, from_column + count - 1);
		for (auto& it : matrix) {
				it.erase(it.begin() + from_column, it.begin() + from_column + count);
		}
		endInsertColumns();
		return true;
}

// Slots
int TetroGridQ::spawn(unsigned int shape_type, QColor color, bool alt_spawn) {
	shape_type = qMin(getNumShapes()-1, shape_type);
	QGenericMatrix<4, 2, unsigned int> current_shape = shapes[shape_type];

	unsigned int point = 0;
	if (alt_spawn == false) {
		point = (unsigned int)floor(getColumns()/2);
	} else {
		unsigned int min_x = floor(getColumns()/2)-3;
		unsigned int max_x = floor(getColumns()/2)+3;

		do
			point = rand() % getColumns();
		while (point > min_x && point < max_x);
	}
	boundary spawn_point = { point-2, 0, point+1, 1 };

	BoolMatrix shape(2, std::vector<bool>(4, 0));
	for (int i = 0; i < 2; ++i) {
		for (int j = 0; j < 4; ++j) {
			shape.at(i).at(j) = bool(current_shape(i, j));
		}
	}

	BoolMatrix test = findShape(new_shape_id, spawn_point, true);

	if (dotMatrix(shape, test) == 0) {
		unsigned int shape_id = new_shape_id++;
		for (int i = 0; i < 2; ++i) {
			for (int j = 0; j < 4; ++j) {
				if (current_shape(i, j)) {
					matrix.at(spawn_point.ay + i).at(spawn_point.ax + j) = {shape_id, color, current_shape(i, j)};
				}
			}
		}

		emit dataChanged(createIndex(spawn_point.ay, spawn_point.ax),
										 createIndex(spawn_point.by, spawn_point.bx), {});
		return shape_id;
	} else {
		return -1;
	}
}

int TetroGridQ::moveShapeLeft(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.ax == 0)
		return -1;

	BoolMatrix shape = findShape(shape_id, shape_boundary);

	boundary test_boundary = shape_boundary;
	test_boundary.ax -= 1;
	test_boundary.bx -= 1;
	BoolMatrix test = findShape(shape_id, test_boundary, true);

	if (dotMatrix(shape, test) == 0) {
		for (unsigned int i = shape_boundary.ay; i <= shape_boundary.by; ++i) {
			for (unsigned int j = shape_boundary.ax; j <= shape_boundary.bx; ++j) {
				if (matrix.at(i).at(j).id == shape_id) {
					matrix.at(i).at(j-1) = matrix.at(i).at(j);
					matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
				}
			}
		}

		emit dataChanged(createIndex(test_boundary.ay, test_boundary.ax), createIndex(shape_boundary.by, shape_boundary.bx), {});
		return shape_boundary.ax;
	} else {
		return -1;
	}
}

int TetroGridQ::moveShapeRight(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.bx == getColumns()-1)
		return -1;

	BoolMatrix shape = findShape(shape_id, shape_boundary);

	boundary test_boundary = shape_boundary;
	test_boundary.ax += 1;
	test_boundary.bx += 1;
	BoolMatrix test = findShape(shape_id, test_boundary, true);

	if (dotMatrix(shape, test) == 0) {
		for (unsigned int i = shape_boundary.by; i >= shape_boundary.ay; --i) {
			for (unsigned int j = shape_boundary.bx; j >= shape_boundary.ax; --j) {
				if (matrix.at(i).at(j).id == shape_id) {
					matrix.at(i).at(j+1) = matrix.at(i).at(j);
					matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
				}

				if (j == 0)
					break;
			}

			if (i == 0)
				break;
		}

		emit dataChanged(createIndex(shape_boundary.ay, shape_boundary.ax), createIndex(test_boundary.by, test_boundary.bx), {});
		return shape_boundary.ax;
	} else {
		return -1;
	}
}

int TetroGridQ::moveShapeDown(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	if (shape_id == 0)
		return -1;

	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.by == getRows()-1)
		return -1;

	BoolMatrix shape = findShape(shape_id, shape_boundary);

	boundary test_boundary = shape_boundary;
	test_boundary.ay += 1;
	test_boundary.by += 1;
	BoolMatrix test = findShape(shape_id, test_boundary, true);

	if (dotMatrix(shape, test) == 0) {
		for (unsigned int i = shape_boundary.by; i >= shape_boundary.ay; --i) {
			for (unsigned int j = shape_boundary.bx; j >= shape_boundary.ax; --j) {
				if (matrix.at(i).at(j).id == shape_id) {
					matrix.at(i+1).at(j) = matrix.at(i).at(j);
					matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
				}

				if (j == 0)
					break;
			}

			if (i == 0)
				break;
		}

		emit dataChanged(createIndex(shape_boundary.ay, shape_boundary.ax), createIndex(test_boundary.by, test_boundary.bx), {});
		return shape_boundary.by;
	} else {
		return -1;
	}
}

int TetroGridQ::moveShapeUp(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.ay == 0)
		return -1;

	BoolMatrix shape = findShape(shape_id, shape_boundary);

	boundary test_boundary = shape_boundary;
	test_boundary.ay -= 1;
	test_boundary.by -= 1;
	BoolMatrix test = findShape(shape_id, test_boundary, true);

	if (dotMatrix(shape, test) == 0) {
		for (unsigned int i = shape_boundary.ay; i <= shape_boundary.by; ++i) {
			for (unsigned int j = shape_boundary.ax; j <= shape_boundary.bx; ++j) {
				if (matrix.at(i).at(j).id == shape_id) {
					matrix.at(i-1).at(j) = matrix.at(i).at(j);
					matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
				}
			}
		}

		emit dataChanged(createIndex(test_boundary.ay, test_boundary.ax), createIndex(shape_boundary.by, shape_boundary.bx), {});
		return shape_boundary.by;
	} else {
		return -1;
	}
}

bool TetroGridQ::rotateShape(unsigned int shape_id) {
	return rotateShapeHelper(shape_id, false);
}

bool TetroGridQ::c_rotateShape(unsigned int shape_id) {
	return rotateShapeHelper(shape_id, true);
}

void TetroGridQ::reset() {
	for (auto& row : matrix) {
			for (auto& col : row) {
					col = { 0, QColor(0, 0, 0), BorderNone };
			}
	}
	new_shape_id = 1;
	emit dataChanged(createIndex(0, 0), createIndex(getRows(), getColumns()), {});
}

// Private Methods
std::vector<int> TetroGridQ::checkRows() {
	std::vector<int> rows;
	for (unsigned int i = 0 ; i < getRows(); ++i) {
		bool check = true;
		for (unsigned int j = 0; j < getColumns(); ++j) {
			check &= matrix.at(i).at(j).id != 0 ? 1 : 0;
		}
		if (check)
			rows.push_back(i);
	}
	return rows;
}

void TetroGridQ::deleteRow(unsigned int index) {
	std::vector<unsigned int> modified_shapes;

	for (unsigned int i = 0; i < getColumns(); ++i) {
		modified_shapes.push_back(matrix[index][i].id);
	}
	auto u = std::unique(modified_shapes.begin(), modified_shapes.end());
	modified_shapes.resize(std::distance(modified_shapes.begin(), u));

	removeRows(index, 1);
	insertRows(0, 1);

	for (unsigned int i = 0; i < getColumns(); ++i) {
		if (matrix.at(index).at(i).id != 0) {
			matrix.at(index).at(i).properties |=
				(((index == getRows()-1) ||
				 (matrix.at(index+1).at(i).id != matrix.at(index).at(i).id)) ? 1 : 0) << 3;
		}
	}

	if (index != getRows()-1) {
		for (unsigned int i = 0; i < getColumns(); ++i) {
			if (matrix.at(index+1).at(i).id != 0) {
				matrix.at(index+1).at(i).properties |=
					((matrix.at(index+1).at(i).id != matrix.at(index).at(i).id) ? 1 : 0) << 2;
			}
		}
	}

	emit dataChanged(createIndex(index,0), createIndex(qMin(index+1, getRows()),getColumns()), {});
}

TetroGridQ::boundary TetroGridQ::findBoundary(unsigned int shape_id) const {
	boundary t = {99, 99, 0, 0};
	for (unsigned int i = 0; i < getRows(); ++i) {
		for (unsigned int j = 0; j < getColumns(); ++j) {
			if (matrix.at(i).at(j).id == shape_id) {
				t.ax = qMin(t.ax, j);
				t.ay = qMin(t.ay, i);

				t.bx = qMax(t.bx, j);
				t.by = qMax(t.by, i);
			}
		}
	}

	return t;
}

BoolMatrix TetroGridQ::findShape(unsigned int shape_id, const boundary& b, bool negate) const {
	unsigned int rows = b.by - b.ay + 1;
	unsigned int columns = b.bx - b.ax + 1;
	BoolMatrix shape(rows, std::vector<bool>(columns, 0));

	for (unsigned int i = b.ay; i <= b.by; ++i) {
		for (unsigned int j = b.ax; j <= b.bx; ++j) {
			if ( (matrix.at(i).at(j).id == shape_id) != negate && matrix.at(i).at(j).id != 0) {
			 shape.at(i - b.ay).at(j - b.ax) = 1;
			}
		}
	}

	return shape;
}

BoolMatrix TetroGridQ::rotateMatrix(const BoolMatrix& A, bool counter) const {
	BoolMatrix result(A[0].size(), std::vector<bool>(A.size(), 0));

	if (!counter) {
		unsigned int o = A.size() - 1;
		for (unsigned int i = 0; i < A.size(); ++i) {
			for (unsigned int j = 0; j < A[0].size(); ++j) {
				result.at(j).at(o-i) = A.at(i).at(j);
			}
		}
	} else {
		unsigned int o = A[0].size() - 1;
		for (unsigned int i = 0; i < A.size(); ++i) {
			for (unsigned int j = 0; j < A[0].size(); ++j) {
				result.at(o-j).at(i) = A.at(i).at(j);
			}
		}
	}

	return result;
}

bool TetroGridQ::dotMatrix(const BoolMatrix& A, const BoolMatrix& B) const {
	if (A.size() != B.size() || A[0].size() != B[0].size())
		return false;

	bool result = false;
	for (unsigned int i = 0; i < A.size(); ++i) {
		for (unsigned int j = 0; j < A[0].size(); ++j) {
			result |= A.at(i).at(j) & B.at(i).at(j);
		}
	}

	return result;
}

bool TetroGridQ::rotateShapeHelper(unsigned int shape_id, bool counter) {
	boundary shape_boundary = findBoundary(shape_id);

	BoolMatrix shape = findShape(shape_id, shape_boundary);
	BoolMatrix r_shape = rotateMatrix(shape, counter);

	double del_x = (double(shape_boundary.bx) - shape_boundary.ax)/2;
	double del_y = (double(shape_boundary.by) - shape_boundary.ay)/2;
	unsigned int mid_x = floor((shape_boundary.ax + shape_boundary.bx + 1)/2);
	unsigned int mid_y = floor((shape_boundary.ay + shape_boundary.by + 1)/2);

	boundary test_boundary = {mid_x - int(ceil(del_y)), mid_y - int(ceil(del_x)), mid_x + int(floor(del_y)), mid_y + int(floor(del_x))};

	BoolMatrix test = findShape(shape_id, test_boundary, true);

	if (dotMatrix(r_shape, test) == 0) {
		block tmp;
		for (unsigned int i = shape_boundary.ay; i <= shape_boundary.by; ++i) {
			for (unsigned int j = shape_boundary.ax; j <= shape_boundary.bx; ++j) {
				if (matrix.at(i).at(j).id == shape_id) {
					tmp = matrix.at(i).at(j);
					matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
				}
			}
		}

		unsigned int y = 0;
		for (unsigned int i = test_boundary.ay; i <= test_boundary.by; ++i) {
			unsigned int x = 0;
			for (unsigned int j = test_boundary.ax; j <= test_boundary.bx; ++j) {
				if (r_shape.at(y).at(x)) {
					matrix.at(i).at(j) = tmp;
					matrix.at(i).at(j).properties =
							((j == test_boundary.ax) || !(r_shape.at(y).at(x-1)) ? 1 : 0) << 0 |
							((j == test_boundary.bx) || !(r_shape.at(y).at(x+1)) ? 1 : 0) << 1 |
							((i == test_boundary.ay) || !(r_shape.at(y-1).at(x)) ? 1 : 0) << 2 |
							((i == test_boundary.by) || !(r_shape.at(y+1).at(x)) ? 1 : 0) << 3;
				}
				x++;
			}
			y++;
		}

		emit dataChanged(createIndex(qMin(shape_boundary.ay, test_boundary.ay), qMin(shape_boundary.ax, test_boundary.ax)),
										 createIndex(qMax(shape_boundary.by, test_boundary.by), qMax(shape_boundary.bx, test_boundary.bx)), {});
		return true;
	} else {
		return false;
	}
}
