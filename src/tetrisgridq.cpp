#include "../include/tetrisgridq.h"
#include "../include/c_shapes.h"

TetrisGridQ::TetrisGridQ(QObject* parent) : QAbstractTableModel(parent), matrix(1), score(0) {
	matrix[0].push_back({ 0, QColor(0, 0, 0), BorderNone });

	for (int i = 0; i < numShapes; ++i) {
		shapes.push_back(QGenericMatrix<4, 2, unsigned int>(c_shapes[i]));
	}
}

void TetrisGridQ::setRows(int count) {
		if (count > getRows()) {
				insertRows(0, count - getRows());
		} else if (count < getRows()) {
				removeRows(0, getRows() - count);
		}
		emit rowsChanged();
}

void TetrisGridQ::setColumns(int count) {
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
	QGenericMatrix<4, 2, unsigned int> current_shape = shapes[1];
	QColor shape_color(0, 255, 255);
	unsigned int id = 1;

	for (int i = 0; i < 2; ++i) {
		for (int j = 0; j < 4; ++j) {
			if (current_shape(i, j)) {
				matrix.at(i).at(j) = {id, shape_color, current_shape(i, j)};
			}
		}
	}
	emit dataChanged(createIndex(0, 0), createIndex(2, 4), {});
}

void TetrisGridQ::moveShapeLeft(unsigned int shapeID) {
	// Boundary given in x y coordinates
	// matrix is y x
	Boundary boundary = findBoundary(shapeID);

	if (boundary(0, 0) == 0)
		return;

	BoolMatrix shape = findShape(shapeID, boundary);

	Boundary leftTest = boundary;
	leftTest(0, 0) -= 1;
	leftTest(1, 0) -= 1;
	BoolMatrix leftShape = findShape(~shapeID, leftTest);

	if (dotMatrix(shape, leftShape) == 0) {
		for (unsigned int i = boundary(0, 1); i <= boundary(1, 1); ++i) {
			for (unsigned int j = boundary(0, 0); j <= boundary(1, 0); ++j) {
				matrix.at(i).at(j-1) = matrix.at(i).at(j);
				matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
			}
		}
	}

	emit dataChanged(createIndex(boundary(0, 1), boundary(0, 0)-1), createIndex(boundary(1, 1), boundary(1, 0)), {});
}

void TetrisGridQ::moveShapeRight(unsigned int shapeID) {
	// Boundary given in x y coordinates
	// matrix is y x
	Boundary boundary = findBoundary(shapeID);

	if (boundary(1, 0) == matrix[0].size()-1)
		return;

	BoolMatrix shape = findShape(shapeID, boundary);

	Boundary rightTest = boundary;
	rightTest(0, 0) += 1;
	rightTest(1, 0) += 1;
	BoolMatrix rightShape = findShape(~shapeID, rightTest);

	if (dotMatrix(shape, rightShape) == 0) {
		for (unsigned int i = boundary(1, 1); i >= boundary(0, 1); --i) {
			for (unsigned int j = boundary(1, 0); j >= boundary(0, 0); --j) {
				matrix.at(i).at(j+1) = matrix.at(i).at(j);
				matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};

				if (j == 0)
					break;
			}

			if (i == 0)
				break;
		}
	}

	emit dataChanged(createIndex(boundary(0, 1), boundary(0, 0)), createIndex(boundary(1, 1), boundary(1, 0)+1), {});
}

void TetrisGridQ::moveShapeDown(unsigned int shapeID) {
	// Boundary given in x y coordinates
	// matrix is y x
	Boundary boundary = findBoundary(shapeID);

	if (boundary(1, 1) == matrix.size()-1)
		return;

	BoolMatrix shape = findShape(shapeID, boundary);

	Boundary downTest = boundary;
	downTest(0, 1) += 1;
	downTest(0, 1) += 1;
	BoolMatrix downShape = findShape(~shapeID, downTest);

	if (dotMatrix(shape, downShape) == 0) {
		for (unsigned int i = boundary(1, 1); i >= boundary(0, 1); --i) {
			for (unsigned int j = boundary(1, 0); j >= boundary(0, 0); --j) {
				matrix.at(i+1).at(j) = matrix.at(i).at(j);
				matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};

				if (j == 0)
					break;
			}

			if (i == 0)
				break;
		}
	}

	emit dataChanged(createIndex(boundary(0, 1), boundary(0, 0)), createIndex(boundary(1, 1)+1, boundary(1, 0)), {});
}

void TetrisGridQ::moveShapeUp(unsigned int shapeID) {
	// Boundary given in x y coordinates
	// matrix is y x
	Boundary boundary = findBoundary(shapeID);

	if (boundary(0, 1) == 0)
		return;

	BoolMatrix shape = findShape(shapeID, boundary);

	Boundary upTest = boundary;
	upTest(0, 1) -= 1;
	upTest(1, 1) -= 1;
	BoolMatrix upShape = findShape(~shapeID, upTest);

	if (dotMatrix(shape, upShape) == 0) {
		for (unsigned int i = boundary(0, 1); i <= boundary(1, 1); ++i) {
			for (unsigned int j = boundary(0, 0); j <= boundary(1, 0); ++j) {
				matrix.at(i-1).at(j) = matrix.at(i).at(j);
				matrix.at(i).at(j) = {0, QColor(0, 0, 0), BorderNone};
			}
		}
	}

	emit dataChanged(createIndex(boundary(0, 1)-1, boundary(0, 0)), createIndex(boundary(1, 1), boundary(1, 0)), {});
}

Boundary TetrisGridQ::findBoundary(unsigned int shapeID) const {
	unsigned int t[] = {99, 99, 0, 0};
	Boundary result(t);
	for (unsigned int i = 0; i < matrix.size(); ++i) {
		for (unsigned int j = 0; j < matrix[0].size(); ++j) {
			if (matrix.at(i).at(j).id == shapeID) {
				result(0, 0) = qMin(result(0, 0), j);
				result(0, 1) = qMin(result(0, 1), i);

				result(1, 0) = qMax(result(1, 0), j);
				result(1, 1) = qMax(result(1, 1), i);
			}
		}
	}

	return result;
}

BoolMatrix TetrisGridQ::findShape(unsigned int shapeID, const Boundary& boundary) const {
	BoolMatrix shape(0);
	for (unsigned int i = boundary(0, 1); i <= boundary(1, 1); ++i) {
		shape.push_back({0});
		for (unsigned int j = boundary(0, 0); j <= boundary(1, 0); ++j) {
			if ( !(matrix.at(i).at(j).id ^ shapeID) ) {
			 shape.back().push_back(1);
			}
		}
	}

	return shape;
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
