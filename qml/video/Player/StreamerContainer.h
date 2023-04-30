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
    QMap<int,QSharedPointer<Streamer>> start_map;
    QQueue<QSharedPointer<Streamer>> queue;
    QTimer start_timer;

     int vm_index=0;

    void add_for_start(QSharedPointer<Streamer> streamer,int index);

public:
     void func();

     void show();

     int get_vm_index(){return vm_index++;};

    QTimer timer;

    QDateTime t1;


    explicit StreamerContainer(QObject *parent = nullptr);

     QList<QSharedPointer<Streamer>> map;

     QSharedPointer<Streamer> start(QString url, Runner::StreamType type,int index);

     void delete_free_streamers(int count);

     bool flag=false;

     QSharedPointer<Streamer> find(QString url,Runner::StreamType type,int index);

public slots:
     void thread_is_over();
    void on_timer();
    void on_start_timer();

signals:

};

#endif // STREAMERCONTAINER_H
