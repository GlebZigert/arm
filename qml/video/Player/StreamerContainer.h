#ifndef STREAMERCONTAINER_H
#define STREAMERCONTAINER_H

#include <QObject>

class StreamerContainer : public QObject
{
    Q_OBJECT
public:
    explicit StreamerContainer(QObject *parent = nullptr);

signals:

};

#endif // STREAMERCONTAINER_H
