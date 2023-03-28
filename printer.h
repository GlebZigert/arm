#ifndef PRINTER_H
#define PRINTER_H

#include <QObject>
#include <QVariant>

class Printer : public QObject
{
    Q_OBJECT

public:
    Printer();

public:

Q_INVOKABLE static void print(QVariant data, qreal resolution);


};

#endif // PRINTER_H
