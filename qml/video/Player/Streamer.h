#ifndef STREAMER_H
#define STREAMER_H

#include <QObject>
#include <QMap>
#include "mythread.h"

class Streamer : public QObject
{
    Q_OBJECT
public:
    explicit Streamer(AVPicture **data,int *h,int *w, QObject *parent = nullptr);

    MyThread* mm;


    AVPicture **data;
    int *h;
    int *w;

    QImage* img;


    bool isValid;




    QString URL;
    int mode;




    void stop();



    QTimer *tmrStart;



    int delay;

public slots:
    void receiveFrame(QString);
    void lostConnection(QString);

    void start();

    void startRunner();

signals:
    void frame(QString URL);
    void lost(QString URL);

};

#endif // STREAMER_H
