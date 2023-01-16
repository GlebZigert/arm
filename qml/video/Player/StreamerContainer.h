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

    QMap<QString, QSharedPointer<Streamer>> map;

    QSharedPointer<Streamer> start(int *h,int *w,QString url, mode mode);




signals:

};

#endif // STREAMERCONTAINER_H
