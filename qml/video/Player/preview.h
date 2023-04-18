#ifndef PREVIEW_H
#define PREVIEW_H

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include <QTimer>
#include "Streamer.h"
#include "previewcontaineraccesser.h"
#include <QSharedPointer>


class Preview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QString url READ url WRITE set_url)

private:
    QString url_= "";
public:
    Preview();

    QString url();
    void set_url(QString url);

    void paint(QPainter *painter) override;

    QSharedPointer<PreviewContainer> container;
    QSharedPointer<PreviewMaker> maker;

public slots:
    void get_image();

signals:

};

#endif // PREVIEW_H
