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

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int cid READ getCid WRITE setCid NOTIFY cidChanged)
public:
    explicit  VideoPlayer(QQuickItem *parent = 0);
    ~VideoPlayer();
    void paint(QPainter *painter) override;


    QString source() const;
    void setSource(const QString source);


    QTimer cleaner;

    Q_INVOKABLE void start(Runner::Mode mode);
    Q_INVOKABLE void  stop();
    Q_INVOKABLE void  shot();

    Q_INVOKABLE void  saving_on();
    Q_INVOKABLE void  saving_off();

    Q_INVOKABLE void  clear();

    Q_INVOKABLE void  delete_free_streamers();


    AVPicture *data;
    int h;
    int w;

    int cid;

    bool connection;


    Q_INVOKABLE Runner::Mode getMode();

    Q_INVOKABLE int getCid() const;
    void setCid(int newCid);

private:

    QString     m_source;

    QImage img;

  //  static StreamerContainer container;

    QSharedPointer<Streamer> current = nullptr;


signals:
    void playing();
    void sourceChanged(const QString &source);
    void cidChanged(const int &cid);
public slots:

    void onWidthChanged();
    void onheightChanged();
    void frame(QString src);
    void lost(QString src);
    void f_clear();

};

#endif // VIDEOPLAYER_H
