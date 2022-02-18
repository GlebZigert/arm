#ifndef THREADLIST_H
#define THREADLIST_H

#include <QObject>
#include <QMap>
#include "mythread.h"

class threadList : public QObject
{
    Q_OBJECT
public:
    explicit threadList(QImage* img, QObject *parent = nullptr);

    QMap<QString, MyThread* > list;

    bool append(QString,int);

    void remove(QString str);

    QImage* img;

    QTimer* tmr;


    QString URL;
    int mode;
    int step;
    int cnt1,cnt2,cnt3;
    int firstFrame;


public slots:
    void receiveFrame(QString);
    void lost_connection(QString URL);
    void process();

signals:
    void frame();

};

#endif // THREADLIST_H
