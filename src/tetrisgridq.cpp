#include "../include/tetrisgridq.h"
#include "../include/c_shapes.h"

TetrisGridQ::TetrisGridQ(QObject* parent) : QAbstractTableModel(parent), matrix(1), shape1(0), score(0) {
	matrix[0].push_back({ 0, QColor(0, 0, 0), BorderNone });

	for (int i = 0; i < numShapes; ++i) {
		shapes.push_back(QGenericMatrix<4, 2, unsigned int>(c_shapes[i]));
	}
}

void TetrisGridQ::setRows(unsigned int count) {
		if (count > getRows()) {
				insertRows(0, count - getRows());
		} else if (count < getRows()) {
				removeRows(0, getRows() - count);
		}
		emit rowsChanged();
}

void TetrisGridQ::setColumns(unsigned int count) {
		if (count > getColumns()) {
				insertColumns(0, count - getColumns());
		} else if (count < getColumns()) {
				removeColumns(0, getColumns() - count);
		}
		emit columnsChanged();
}

// Inherited Read Methods
int TetrisGridQ::rowCount(const QModelIndex& /*parent*/) const {
		return matrix.size();
}

int TetrisGridQ::columnCount(const QModelIndex& /*parent*/) const {
		return matrix.at(0).size();
}

auto TetrisGridQ::data(const QModelIndex& index, int role) const
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

auto TetrisGridQ::headerData(int section, Qt::Orientation orientation, int role) const
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

auto TetrisGridQ::roleNames() const
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
bool TetrisGridQ::setData(const QModelIndex& index, const QVariant& value, int role) {
		bool result = false;

		return result;
}

auto TetrisGridQ::flags(const QModelIndex& /*index*/) const
-> Qt::ItemFlags {
		return Qt::ItemIsSelectable | Qt::ItemNeverHasChildren
						| Qt::ItemIsEnabled;
}

// Inherited Resize Methods
bool TetrisGridQ::insertRows(int before_row, int count, const QModelIndex& parent) {
		beginInsertRows(parent, before_row + 1, before_row + count);
		matrix.insert(matrix.begin() + before_row, count,
									std::vector<block>(getColumns(), {0, QColor(0, 0, 0), BorderNone }));
		endInsertRows();
		return true;
}

bool TetrisGridQ::removeRows(int from_row, int count, const QModelIndex &parent) {
		beginRemoveRows(parent, from_row, from_row + count - 1);
		matrix.erase(matrix.begin() + from_row, matrix.begin() + from_row + count);
		endRemoveRows();
		return true;
}

bool TetrisGridQ::insertColumns(int before_column, int count, const QModelIndex& parent) {
		beginInsertColumns(parent, before_column + 1, before_column + count);
		for (auto& it : matrix) {
				it.insert(it.begin() + before_column, count, { 0, QColor(0, 0, 0), BorderNone });
		}
		endInsertColumns();
		return true;
}

bool TetrisGridQ::removeColumns(int from_column, int count, const QModelIndex &parent) {
		beginRemoveColumns(parent, from_column, from_column + count - 1);
		for (auto& it : matrix) {
				it.erase(it.begin() + from_column, it.begin() + from_column + count);
		}
		endInsertColumns();
		return true;
}

void TetrisGridQ::spawn() {
	QGenericMatrix<4, 2, unsigned int> current_shape = shapes[2];
	QColor shape_color(0, 255, 255);
	shape1++;

	for (int i = 0; i < 2; ++i) {
		for (int j = 0; j < 4; ++j) {
			if (current_shape(i, j)) {
				matrix.at(i).at(j) = {shape1, shape_color, current_shape(i, j)};
			}
		}
	}
	emit dataChanged(createIndex(0, 0), createIndex(2, 4), {});
}

void TetrisGridQ::moveShapeLeft(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.ax == 0)
		return;

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
	}
}

void TetrisGridQ::moveShapeRight(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.bx == matrix[0].size()-1)
		return;

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
	}
}

void TetrisGridQ::moveShapeDown(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.by == matrix.size()-1)
		return;

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
	}
}

void TetrisGridQ::moveShapeUp(unsigned int shape_id) {
	// Boundary given in x y coordinates
	// matrix is y x
	boundary shape_boundary = findBoundary(shape_id);

	if (shape_boundary.ay == 0)
		return;

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
	}
}

void TetrisGridQ::rotateShape(unsigned int shape_id) {
	rotateShapeHelper(shape_id, false);
}

void TetrisGridQ::c_rotateShape(unsigned int shape_id) {
	rotateShapeHelper(shape_id, true);
}

TetrisGridQ::boundary TetrisGridQ::findBoundary(unsigned int shape_id) const {
	boundary t = {99, 99, 0, 0};
	for (unsigned int i = 0; i < matrix.size(); ++i) {
		for (unsigned int j = 0; j < matrix[0].size(); ++j) {
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

BoolMatrix TetrisGridQ::findShape(unsigned int shape_id, const boundary& b, bool negate) const {
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

BoolMatrix TetrisGridQ::rotateMatrix(const BoolMatrix& A, bool counter) const {
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

bool TetrisGridQ::dotMatrix(const BoolMatrix& A, const BoolMatrix& B) const {
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

void TetrisGridQ::rotateShapeHelper(unsigned int shape_id, bool counter) {
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
		unsigned int del_x = test_boundary.bx - test_boundary.ax;
		unsigned int del_y = test_boundary.by - test_boundary.ay;
		for (unsigned int i = test_boundary.ay; i <= test_boundary.by; ++i) {
			unsigned int x = 0;
			for (unsigned int j = test_boundary.ax; j <= test_boundary.bx; ++j) {
				if (r_shape.at(y).at(x)) {
					matrix.at(i).at(j) = tmp;
					matrix.at(i).at(j).properties =
							((x == 0) || !(r_shape.at(y).at(x-1)) ? 1 : 0) << 0 |
							((x == del_x) || !(r_shape.at(y).at(x+1)) ? 1 : 0) << 1 |
							((y == 0) || !(r_shape.at(y-1).at(x)) ? 1 : 0) << 2 |
							((y == del_y) || !(r_shape.at(y+1).at(x)) ? 1 : 0) << 3;
				}
				x++;
			}
			y++;
		}

		emit dataChanged(createIndex(qMin(shape_boundary.ay, test_boundary.ay), qMin(shape_boundary.ax, test_boundary.ax)),
										 createIndex(qMax(shape_boundary.by, test_boundary.by), qMax(shape_boundary.bx, test_boundary.bx)), {});
	}
}


