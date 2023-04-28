#ifndef STREAMERCONTAINER_H
#define STREAMERCONTAINER_H

#include <QObject>
#include <QMap>
#include "Streamer.h"
#include <QSharedPointer>
#include <QTimer>
#include <QQueue>

class StreamerContainer : public QObject
{
    Q_OBJECT

private:

    QDateTime start_dt;

    QQueue<QSharedPointer<Streamer>> queue;
    QTimer start_timer;

    void add_for_start(QSharedPointer<Streamer> streamer);

public:
     void func();

     void show();



    QTimer timer;

    explicit StreamerContainer(QObject *parent = nullptr);

     QList<QSharedPointer<Streamer>> map;

     QSharedPointer<Streamer> start(QString url, Runner::StreamType type);

     void delete_free_streamers();

     bool flag=false;

     QSharedPointer<Streamer> find(QString url,Runner::StreamType type);

public slots:
     void thread_is_over();
    void on_timer();
    void on_start_timer();

signals:

};

#endif // STREAMERCONTAINER_H
