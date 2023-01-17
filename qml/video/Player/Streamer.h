#ifndef STREAMER_H
#define STREAMER_H

#include <QObject>
#include <QMap>
#include <QSharedPointer>
#include "mythread.h"

class Streamer : public QObject
{
    Q_OBJECT
public:
    explicit Streamer(int *h,int *w, QString URL,mode mode,QObject *parent = nullptr);
    ~Streamer();
    QSharedPointer<MyThread> mm;


    int followers=0;

    void followers_inc();
    void followers_dec();

    int *h;
    int *w;

    QImage* img;


    bool isValid;







    int mode;




    void stop();



    QTimer *tmrStart;



    int delay;

    AVPicture *getData() const;

    int getH() const;

    int getW() const;

    int getFollowers() const;

    const QString &getURL() const;

    bool getIsOver() const;

private:

    bool isOver=false;


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
