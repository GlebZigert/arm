#ifndef MYTHREAD_H
#define MYTHREAD_H

#include <QObject>
#include <QThread>
#include "runner.h"

class MyThread : public QObject
{
    Q_OBJECT

public:
    explicit MyThread(AVPicture** data,int *h, int *w,QString str,Runner::Mode mode, QObject *parent = nullptr);

    ~MyThread();


    QThread* thread;
    Runner* runner;

    void stop();

public slots:

   void quit();


private:
    QString URL;
signals:


};

#endif // MYTHREAD_H
