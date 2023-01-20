#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include <QTimer>
#include "Streamer.h"
#include "StreamerContainer.h"

class VideoPlayer : public QQuickPaintedItem

{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource )
public:
    explicit  VideoPlayer(QQuickItem *parent = 0);
    void paint(QPainter *painter) override;


    QString source() const;
    void setSource(const QString source);


    Q_INVOKABLE void start(Runner::Mode mode);
    Q_INVOKABLE void  stop();
    Q_INVOKABLE void  shot();




    AVPicture *data;
    int h;
    int w;


private:

    QString     m_source;

    QImage img;

    static StreamerContainer container;

    QSharedPointer<Streamer> current = nullptr;


signals:
    void playing();

public slots:

    void onWidthChanged();
    void onheightChanged();
    void frame(QString src);
    void lost(QString src);

};

#endif // VIDEOPLAYER_H
