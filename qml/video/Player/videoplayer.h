#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include <QTimer>
#include "threadlist.h"


class VideoPlayer : public QQuickPaintedItem

{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource )
public:
    explicit  VideoPlayer(QQuickItem *parent = 0);
    void paint(QPainter *painter) override;


    QString source() const;
    void setSource(const QString source);


    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void check();
    Q_INVOKABLE void shot();




private:

    QString     m_source;

    QImage img;

    threadList* list;

signals:
    void playing();

public slots:

    void onWidthChanged();
    void onheightChanged();
    void frame();

};

#endif // VIDEOPLAYER_H
