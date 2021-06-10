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


class TetroGridQ : public QAbstractTableModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(unsigned int rows READ rowCount WRITE setRows NOTIFY rowsChanged)
	Q_PROPERTY(unsigned int columns READ columnCount WRITE setColumns NOTIFY columnsChanged)
	Q_PROPERTY(unsigned int numShapes READ getNumShapes)
	Q_PROPERTY(bool debug_enabled READ getDebug)

private:
	enum BlockBorder {
		BorderNone = 0,
		BorderLeft = 1,
		BorderRight = 2,
		BorderTop = 4,
		BorderBottom = 8
	};

	struct block_info {
		unsigned int id;
		QColor color;
		unsigned short borders;
	};

	struct block_vertex {
		int y;
		int x;
	};

	std::vector<std::vector<block_info>> matrix;
	std::vector<QGenericMatrix<4, 2, unsigned short>> shapes;
	int new_shape_id;

	bool debug_enabled;

	// Private Methods
	std::vector<block_vertex> findShapeVertices(unsigned int shape_id) const;

public:
	enum DataTypes {
		blockColor = Qt::UserRole,
		hasBorderLeft,
		hasBorderRight,
		hasBorderTop,
		hasBorderBottom
	};

	enum SpecialType : short {
		RepeatShape = 1,
		MixControls = 2,
	};
	Q_ENUM(SpecialType)

	// Constructors
	explicit TetroGridQ(QObject* parent = nullptr);

	// Getter Methods
	inline unsigned int getRows() const { return matrix.size(); }
	inline unsigned int getColumns() const { return matrix[0].size(); }
	inline unsigned int getNumShapes() const { return shapes.size(); }
	inline bool getDebug() { return debug_enabled; }

	// Setter Methods
	void setRows(unsigned int count);
	void setColumns(unsigned int count);

	// Interface Methods
	Q_INVOKABLE int spawnShape(unsigned int shape_type, QColor color);
	Q_INVOKABLE bool moveShapeLeft(unsigned int shape_id);
	Q_INVOKABLE bool moveShapeRight(unsigned int shape_id);
	Q_INVOKABLE bool moveShapeDown(unsigned int shape_id);
	Q_INVOKABLE bool rotateShape(unsigned int shape_id);
	Q_INVOKABLE std::vector<int> checkRows();
	Q_INVOKABLE void deleteRow(unsigned int index);
	Q_INVOKABLE void reset();

	// -- Inherited Methods --
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
	// -- End (Inherited Methods) --

			~TetroGridQ() {};

signals:
		void rowsChanged();
		void columnsChanged();
};

#endif // TETROGRIDQ_H
