#ifndef TETROGRIDQ_H
#define TETROGRIDQ_H

#include <QAbstractTableModel>
#include <QColor>
#include <QString>
#include <QGenericMatrix>

#include <qqml.h>

#include <vector>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <ctime>

typedef std::vector<std::vector<bool>> BoolMatrix;


class TetroGridQ : public QAbstractTableModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(unsigned int rows READ rowCount WRITE setRows NOTIFY rowsChanged)
	Q_PROPERTY(unsigned int columns READ columnCount WRITE setColumns NOTIFY columnsChanged)
	Q_PROPERTY(unsigned int numShapes READ getNumShapes)
public:
	enum SpecialType : short;
private:
	enum BlockProps {
		BorderNone = 0,
		BorderLeft = 1,
		BorderRight = 2,
		BorderTop = 4,
		BorderBottom = 8
	};

	struct block {
		unsigned int id;
		QColor color;
		SpecialType type;
		unsigned int borders;
	};

	struct boundary {
		unsigned int ax;
		unsigned int ay;
		unsigned int bx;
		unsigned int by;
	};

	std::vector<std::vector<block>> matrix;
	std::vector<QGenericMatrix<4, 2, unsigned int>> shapes;
	static const std::unordered_map<SpecialType, QString> textures;
	static const std::unordered_map<SpecialType, QString> singles;
	int new_shape_id;

	boundary findBoundary(unsigned int shape_id) const;
	BoolMatrix findShape(unsigned int shape_id, const boundary& b, bool negate = false) const;
	BoolMatrix rotateMatrix(const BoolMatrix& A, bool counter = false) const;
	bool dotMatrix(const BoolMatrix& A, const BoolMatrix& B) const;
	bool rotateShapeHelper(unsigned int shape_id, bool counter);

public:
	enum DataTypes {
		blockColor = Qt::UserRole,
		blockTexture,
		hasBorderLeft,
		hasBorderRight,
		hasBorderTop,
		hasBorderBottom
	};

	enum SpecialType : short {
		NormalBlock = 0,
		CancelEffect,
		NoDrop
	};
	Q_ENUM(SpecialType)

	Q_INVOKABLE int spawn(unsigned int shape_type, QColor color, SpecialType special_type, bool alt_spawn = false);
	Q_INVOKABLE int moveShapeLeft(unsigned int shape_id);
	Q_INVOKABLE int moveShapeRight(unsigned int shape_id);
	Q_INVOKABLE int moveShapeDown(unsigned int shape_id);
	Q_INVOKABLE int moveShapeUp(unsigned int shape_id);
	Q_INVOKABLE bool rotateShape(unsigned int shape_id);
	Q_INVOKABLE bool c_rotateShape(unsigned int shape_id);
	Q_INVOKABLE std::vector<int> checkRows();
	Q_INVOKABLE void deleteRow(unsigned int index);
	Q_INVOKABLE void reset();

	Q_INVOKABLE QString getTexture(SpecialType val) const { return textures.at(val); }
	Q_INVOKABLE QString getSingle(SpecialType val) const { return singles.at(val); }

	// Constructors
	explicit TetroGridQ(QObject* parent = nullptr);

	// Getter Methods
	inline unsigned int getRows() const { return matrix.size(); }
	inline unsigned int getColumns() const { return matrix[0].size(); }
	inline unsigned int getNumShapes() const { return shapes.size(); }

	// Setter Methods
	void setRows(unsigned int count);
	void setColumns(unsigned int count);

	// Inherited Methods
			// Read Methods
			auto rowCount(const QModelIndex& parent = QModelIndex()) const
					-> int override;
			auto columnCount(const QModelIndex& parent = QModelIndex()) const
					-> int override;
			auto data(const QModelIndex& index, int role = Qt::DisplayRole) const
					-> QVariant override;
			auto headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const
					-> QVariant override;
			auto roleNames() const
					-> QHash<int, QByteArray> override;

			// Write Methods
			auto setData(const QModelIndex& index, const QVariant& value, int role = Qt::DisplayRole)
					-> bool override;
			auto flags(const QModelIndex& index) const
					-> Qt::ItemFlags override;

			// Resize Methods
			auto insertRows(int before_row, int count, const QModelIndex& parent = QModelIndex())
					-> bool override;
			auto removeRows(int from_row, int count, const QModelIndex& parent = QModelIndex())
					-> bool override;
			auto insertColumns(int before_column, int count, const QModelIndex& parent = QModelIndex())
					-> bool override;
			auto removeColumns(int from_column, int count, const QModelIndex& parent = QModelIndex())
					-> bool override;

			~TetroGridQ() {};

signals:
		void rowsChanged();
		void columnsChanged();
		void activateSpecial(unsigned int special_type);
};

#endif // TETROGRIDQ_H
