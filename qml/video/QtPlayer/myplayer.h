#ifndef QTPLAYER_H
#define QTPLAYER_H

#include <QObject>

class QtPlayer : public QObject
{
    Q_OBJECT
public:
    explicit QtPlayer(QObject *parent = nullptr);

signals:

};

#endif // QTPLAYER_H
