#ifndef STREAMER_H
#define STREAMER_H

#include <QObject>
#include <QMap>
#include "mythread.h"

class Streamer : public QObject
{
    Q_OBJECT
public:
    explicit Streamer(int *h,int *w, QString URL,mode mode,QObject *parent = nullptr);

    MyThread* mm;



    int *h;
    int *w;

    QImage* img;


    bool isValid;





    int mode;




    void stop();



    QTimer *tmrStart;



    int delay;

    AVPicture *getData() const;

private:
    AVPicture *data;

    QString URL;


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
