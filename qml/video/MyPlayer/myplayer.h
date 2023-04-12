#ifndef MYPLAYER_H
#define MYPLAYER_H
#include <QPainter>
#include <QtQuick/QQuickPaintedItem>

#include <QMediaPlayer>
#include <QVideoProbe>



class MyPlayer : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource )
public:
    explicit MyPlayer(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;

    QString source() const;
    void setSource(const QString source);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void check();
    Q_INVOKABLE void shot();




    QMediaPlayer *player;
    QVideoProbe *probe;

    QImage img;

private:
    QString     m_source;




signals:
    void playing();

public slots:
    void processFrame(const QVideoFrame &frame) ;


};



#endif // MYPLAYER_H
