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

    bool getIsOver() const;

public slots:

   void m_quit();


private:
    QString URL;
    bool isOver=false;
signals:


};

#endif // MYTHREAD_H
