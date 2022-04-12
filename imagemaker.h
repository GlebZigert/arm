#ifndef IMAGEMAKER_H
#define IMAGEMAKER_H

#include <QObject>

class imageMaker : public QObject
{
    Q_OBJECT
public:
    explicit imageMaker(QObject *parent = nullptr);

signals:

};

#endif // IMAGEMAKER_H
