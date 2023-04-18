#ifndef PREVIEWMAKER_H
#define PREVIEWMAKER_H


#include "videoplayer.h"

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include <QTimer>
#include "Streamer.h"
#include "streamercontaineraccesser.h"
#include <QPainter>

class PreviewMaker : public QQuickItem
{
    Q_OBJECT



private:
    QString     url_="";
    int cid_=-1;
    bool flag=true;
public:
    QImage get_image();
    PreviewMaker(QString url);

    Q_INVOKABLE void start(int cid,QString url);


    QSharedPointer<Streamer> current = nullptr;


    AVPicture *data;


    QString url() const;
    void set_url(const QString source);

    int cid();
    void set_cid(int cid);

    QSharedPointer<StreamerContainer> container;

    QImage img;

public slots:
    void frame(QString URL);

signals:

    void image();

};
#endif // PREVIEWMAKER_H
