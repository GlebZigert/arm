#ifndef PREVIEW_H
#define PREVIEW_H

#include <QtQuick/QQuickPaintedItem>
#include <QImage>
#include <QThread>
#include <QTimer>
#include "Streamer.h"


class Preview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(int cid READ cid WRITE set_cid)

private:
    int cid_=-1;
public:
    Preview();

    int cid();
    void set_cid(int cid);

    void paint(QPainter *painter) override;


signals:

};

#endif // PREVIEW_H
