#ifndef STREAMERCONTAINER_H
#define STREAMERCONTAINER_H

#include <QObject>
#include <QMap>
#include "Streamer.h"
#include <QSharedPointer>

class StreamerContainer : public QObject
{
    Q_OBJECT
public:
    explicit StreamerContainer(QObject *parent = nullptr);

    static QList<QSharedPointer<Streamer>> map;

    static QSharedPointer<Streamer> start(QString url, Runner::Mode mode);


    static QSharedPointer<Streamer> find(QString url);

public slots:
    void thread_is_over();

signals:

};

#endif // STREAMERCONTAINER_H
