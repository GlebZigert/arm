#ifndef STREAMERCONTAINER_QML_ACCESSER_H
#define STREAMERCONTAINER_QML_ACCESSER_H

#include <QQuickItem>

class StreamerContainer_QML_accesser : public QQuickItem
{
    Q_OBJECT
public:
    StreamerContainer_QML_accesser();

    Q_INVOKABLE void start();
signals:

};

#endif // STREAMERCONTAINER_QML_ACCESSER_H
