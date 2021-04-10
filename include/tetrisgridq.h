#ifndef TETRISGRIDQ_H
#define TETRISGRIDQ_H

#include <QAbstractTableModel>
#include <qqml.h>

class TetrisGridQ : public QObject
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit TetrisGridQ(QObject *parent = nullptr);

signals:

};

#endif // TETRISGRIDQ_H
