#ifndef MODEL_H
#define MODEL_H

#include <QQuickItem>

class Model : public QQuickItem
{
    Q_OBJECT
public:
    Model();

    Q_INVOKABLE QString get_info();

    Q_INVOKABLE int get_vid_count();

    Q_INVOKABLE void show();

     Q_INVOKABLE int get_pages_count(QString vid);

private:

static QMap<QString,QSharedPointer<QList<int>>> mdl;

signals:

};

#endif // MODEL_H
