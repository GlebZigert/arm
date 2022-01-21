#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include "starter.h"
#include <QTimer>


class VideoPlayer : public QQuickPaintedItem

{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource )
public:
    explicit  VideoPlayer(QQuickItem *parent = 0);
    void paint(QPainter *painter) override;
    //Container *m_player;
    Starter *m_starter;

    QImage mImage;

    QString source() const;
    void setSource(const QString source);


    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void check();
    Q_INVOKABLE void shot();

    QThread thread_starter;
    QTimer *timer;
private:
    QString     m_source;
    bool it_s_a_shot;
signals:
    void playing();

public slots:
    void new_frame();
    void onWidthChanged();
    void onheightChanged();
    void timeout();
    void lost_connection();
    void slot_playing();
};

#endif // VIDEOPLAYER_H
