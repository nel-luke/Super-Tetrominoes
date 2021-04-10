#ifndef TETRISGRIDQ_H
#define TETRISGRIDQ_H

#include <QAbstractTableModel>
#include <QColor>
#include <QGenericMatrix>

#include <qqml.h>

#include <vector>

typedef QGenericMatrix<2, 2, unsigned int> Boundary;
typedef std::vector<std::vector<bool>> BoolMatrix;

class TetrisGridQ : public QAbstractTableModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(int rows READ rowCount WRITE setRows NOTIFY rowsChanged)
	Q_PROPERTY(int columns READ columnCount WRITE setColumns NOTIFY columnsChanged)

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
		unsigned int properties;
	};

	std::vector<std::vector<block>> matrix;
	std::vector<QGenericMatrix<4, 2, unsigned int>> shapes;
	unsigned int score;

	Boundary findBoundary(unsigned int shapeID) const;
	BoolMatrix findShape(unsigned int shapeID, const Boundary& boundary) const;
	bool dotMatrix(const BoolMatrix& A, const BoolMatrix& B) const;

public:
	enum DataTypes {
		blockColor = Qt::UserRole,
		hasBorderLeft,
		hasBorderRight,
		hasBorderTop,
		hasBorderBottom
	};

	// Constructors
	explicit TetrisGridQ(QObject* parent = nullptr);

	// Getter Methods
	inline int getRows() const { return matrix.size(); }
	inline int getColumns() const { return matrix[0].size(); }

	// Setter Methods
	void setRows(int count);
	void setColumns(int count);

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

			~TetrisGridQ() {};

public slots:
		void spawn();
		void moveShapeLeft(unsigned int shapeID);
		void moveShapeRight(unsigned int shapeID);
		void moveShapeDown(unsigned int shapeID);
		void moveShapeUp(unsigned int shapeID);

signals:
		void rowsChanged();
		void columnsChanged();
};

#endif // TETRISGRIDQ_H
