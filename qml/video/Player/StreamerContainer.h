#ifndef STREAMERCONTAINER_H
#define STREAMERCONTAINER_H

#include <QObject>
#include <QMap>
#include "Streamer.h"
#include <QSharedPointer>
#include <QTimer>

class StreamerContainer : public QObject
{
    Q_OBJECT

private:
    static void func();


public:

    QTimer timer;

    explicit StreamerContainer(QObject *parent = nullptr);

    static QList<QSharedPointer<Streamer>> map;

    static QSharedPointer<Streamer> start(QString url, Runner::Mode mode);


    static QSharedPointer<Streamer> find(QString url);

public slots:
    void thread_is_over();
    void on_timer();

signals:

};

#endif // STREAMERCONTAINER_H
