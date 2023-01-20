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

    QList<QSharedPointer<Streamer>> map;

    QSharedPointer<Streamer> start(int *h,int *w,QString url, Runner::Mode mode);


    QSharedPointer<Streamer> find(QString url);

signals:

};

#endif // STREAMERCONTAINER_H
