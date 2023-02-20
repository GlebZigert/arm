#ifndef MODEL_H
#define MODEL_H

#include <QQuickItem>

class Model : public QQuickItem
{
    Q_OBJECT
public:
    Model();

    Q_INVOKABLE QString get_info();

signals:

};

#endif // MODEL_H
