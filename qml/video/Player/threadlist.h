#ifndef THREADLIST_H
#define THREADLIST_H

#include <QObject>
#include <QMap>
#include "mythread.h"

class threadList : public QObject
{
    Q_OBJECT
public:
    explicit threadList(AVPicture **data,int *h,int *w, QObject *parent = nullptr);

    MyThread* mm;


    AVPicture **data;
    int *h;
    int *w;

    QImage* img;

    QImage* lost;

    bool isValid;




    QString URL;
    int mode;




    void stop();



    QTimer *tmrStart;





public slots:
    void receiveFrame(QString);
    void lostConnection(QString);

    void start();


signals:
    void frame(QString URL);

};

#endif // THREADLIST_H
