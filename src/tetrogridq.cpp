#include "../include/tetrogridq.h"
#include "../include/c_shapes.h"

TetroGridQ::TetroGridQ(QObject* parent):
		QAbstractTableModel(parent),
		matrix(2, std::vector<block_info>(4, block_info())),
		new_shape_id(1), debug_enabled(false) {
	#ifdef QT_DEBUG
		debug_enabled = true;
	#endif
	for (int i = 0; i < numShapes; ++i) {
		shapes.push_back(QGenericMatrix<4, 2, unsigned short>(c_shapes[i]));
	}
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
			case hasBorderLeft : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).borders & BorderLeft ? 1 : 0);
					break;
			case hasBorderRight : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).borders & BorderRight ? 1 : 0);
					break;
			case hasBorderTop : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).borders & BorderTop ? 1 : 0);
					break;
			case hasBorderBottom : result = QVariant::fromValue(matrix.at(index.row()).at(index.column()).borders & BorderBottom ? 1 : 0);
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
									std::vector<block_info>(getColumns(), block_info()));
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

std::vector<TetroGridQ::block_vertex> TetroGridQ::findShapeVertices(unsigned int shape_id) const {
	std::vector<block_vertex> vertices;
	for (int i = 0; i < int(getRows()); ++i) {
		for (int j = 0; j < int(getColumns()); ++j) {
			if (matrix[i][j].id == shape_id) {
				vertices.push_back({ i, j });
			}
		}
	}

	return vertices;
}

// Slots
int TetroGridQ::spawnShape(unsigned int shape_type, QColor color) {
	shape_type = qMin(getNumShapes()-1, shape_type);
	QGenericMatrix<4, 2, unsigned short> shape_borders = shapes[shape_type];

	bool blocks_present = false;
	for (int i = 0; i < 2; ++i) {
		for (const auto& block : matrix[i]) {
			blocks_present |= block.id;
		}
	}

	int x_start = floor(getColumns()/2) - 1;
	if (!blocks_present) {
		unsigned int shape_id = new_shape_id++;
		for (int i = 0; i < 2; ++i) {
			for (int j = 0; j < 4; ++j) {
				if (shape_borders(i, j)) {
					matrix[i][x_start + j] = { shape_id, color, shape_borders(i, j) };
				}
			}
		}

		emit dataChanged(createIndex(0, x_start), createIndex(1, x_start+4), {});
		return shape_id;
	}

	return -1;
}

bool TetroGridQ::moveShapeLeft(unsigned int shape_id) {
	if (shape_id == 0)
		return false;

	std::vector<block_vertex> vertices = findShapeVertices(shape_id);

	bool can_move = true;
	for (const auto& v : vertices) {
		can_move &= (v.x > 0 && (matrix[v.y][v.x-1].id == 0	|| matrix[v.y][v.x-1].id == shape_id) );
	}

	if (can_move) {
		for (const auto& v : vertices) {
			block_info b = matrix[v.y][v.x];
			matrix[v.y][v.x-1] = b;
			matrix[v.y][v.x] = { 0, QColor(0, 0, 0), BorderNone };
		}

		block_vertex a = { qMax(vertices[2].y-3, 0), qMax(vertices[2].x-3, 0) };
		block_vertex b = { qMin(vertices[2].y+3, int(getRows()-1)), qMin(vertices[2].x+3, int(getColumns()-1)) };
		emit dataChanged(createIndex(a.y, a.x), createIndex(b.y, b.x), {});
		return true;
	}

	return false;
}

bool TetroGridQ::moveShapeRight(unsigned int shape_id) {
	if (shape_id == 0)
		return false;

	std::vector<block_vertex> vertices = findShapeVertices(shape_id);

	bool can_move = true;
	for (const auto& v : vertices) {
		can_move &= (v.x < int(getColumns()-1) && (matrix[v.y][v.x+1].id == 0	|| matrix[v.y][v.x+1].id == shape_id) );
	}

	if (can_move) {
		std::reverse(vertices.begin(), vertices.end());
		for (const auto& v : vertices) {
			block_info b = matrix[v.y][v.x];
			matrix[v.y][v.x+1] = b;
			matrix[v.y][v.x] = { 0, QColor(0, 0, 0), BorderNone };
		}

		block_vertex a = { qMax(vertices[2].y-3, 0), qMax(vertices[2].x-3, 0) };
		block_vertex b = { qMin(vertices[2].y+3, int(getRows()-1)), qMin(vertices[2].x+3, int(getColumns()-1)) };
		emit dataChanged(createIndex(a.y, a.x), createIndex(b.y, b.x), {});
		return true;
	}

	return false;
}

bool TetroGridQ::moveShapeDown(unsigned int shape_id) {
	if (shape_id == 0)
		return false;

	std::vector<block_vertex> vertices = findShapeVertices(shape_id);

	bool can_move = true;
	for (const auto& v : vertices) {
		can_move &= (v.y < int(getRows()-1) && (matrix[v.y+1][v.x].id == 0	|| matrix[v.y+1][v.x].id == shape_id) );
	}

	if (can_move) {
		std::reverse(vertices.begin(), vertices.end());
		for (const auto& v : vertices) {
			block_info b = matrix[v.y][v.x];
			matrix[v.y+1][v.x] = b;
			matrix[v.y][v.x] = { 0, QColor(0, 0, 0), BorderNone };
		}

		block_vertex a = { qMax(vertices[2].y-3, 0), qMax(vertices[2].x-3, 0) };
		block_vertex b = { qMin(vertices[2].y+3, int(getRows()-1)), qMin(vertices[2].x+3, int(getColumns()-1)) };
		emit dataChanged(createIndex(a.y, a.x), createIndex(b.y, b.x), {});
		return true;
	}

	return false;
}

bool TetroGridQ::rotateShape(unsigned int shape_id) {
	if (shape_id == 0)
		return false;

	std::vector<block_vertex> vertices = findShapeVertices(shape_id);

	block_vertex min = { int(getRows()), int(getColumns()) };
	block_vertex max = { 0, 0 };
	for (const auto& v : vertices) {
		min = { qMin(min.y, v.y), qMin(min.x, v.x) };
		max = { qMax(max.y, v.y), qMax(max.x, v.x) };
	}

	block_vertex mid = {
		int(floor((double(min.y) + max.y + 1)/2)),
		int(floor((double(min.x) + max.x)/2))
	};

	std::vector<block_vertex> rotated(vertices.size());
	std::transform(vertices.begin(), vertices.end(), rotated.begin(),
			[mid](block_vertex& a) { return block_vertex({ mid.y + (a.x - mid.x), mid.x - (a.y - mid.y) }); });

	bool can_move = true;
	for (const auto& v : rotated) {
		can_move &= (v.y > 0 && v.y < int(getRows()));
		can_move &= (v.x > 0 && v.x < int(getColumns()));
		if (can_move)
			can_move &= (matrix[v.y][v.x].id == 0 || matrix[v.y][v.x].id == shape_id);
		else
			break;
	}

	if (can_move) {
		QColor color = matrix[vertices[0].y][vertices[0].x].color;

		for (const auto& v : vertices) {
			matrix[v.y][v.x] = { 0, QColor(0, 0, 0), BorderNone };
		}
		for (const auto& r : rotated) {
			matrix[r.y][r.x] = { shape_id, color, BorderNone };
		}
		for (const auto& r : rotated) {
			matrix[r.y][r.x].borders = (unsigned short)(
				(((r.x > 0) && matrix[r.y][r.x-1].id != shape_id) ? 1 : 0)										<< 0 |
				(((r.x < int(getColumns()-1)) && matrix[r.y][r.x+1].id != shape_id) ? 1 : 0)			<< 1 |
				(((r.y > 0) && matrix[r.y-1][r.x].id != shape_id) ? 1 : 0)										<< 2 |
				(((r.y < int(getRows()-1)) && matrix[r.y+1][r.x].id != shape_id) ? 1 : 0)	<< 3
			);
		}

		block_vertex a = { qMax(vertices[2].y-3, 0), qMax(vertices[2].x-3, 0) };
		block_vertex b = { qMin(vertices[2].y+3, int(getRows()-1)), qMin(vertices[2].x+3, int(getColumns()-1)) };
		emit dataChanged(createIndex(a.y, a.x), createIndex(b.y, b.x), {});
		return true;
	}

	return false;
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
		bool no_empties = true;
		for (unsigned int j = 0; (j < getColumns()) && no_empties; ++j) {
			no_empties &= matrix.at(i).at(j).id != 0;
		}
		if (no_empties)
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
			matrix.at(index).at(i).borders |=
				(((index == getRows()-1) ||
				 (matrix.at(index+1).at(i).id != matrix.at(index).at(i).id)) ? 1 : 0) << 3;
		}
	}

	if (index != getRows()-1) {
		for (unsigned int i = 0; i < getColumns(); ++i) {
			if (matrix.at(index+1).at(i).id != 0) {
				matrix.at(index+1).at(i).borders |=
					((matrix.at(index+1).at(i).id != matrix.at(index).at(i).id) ? 1 : 0) << 2;
			}
		}
	}

	emit dataChanged(createIndex(index,0), createIndex(qMin(index+1, getRows()),getColumns()), {});
}
