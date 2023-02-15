#ifndef MYTHREAD_H
#define MYTHREAD_H

#include <QObject>
#include <QThread>
#include "runner.h"

class MyThread : public QObject
{
    Q_OBJECT

public:
    explicit MyThread(AVPicture** data,int *h, int *w,QString str,Runner::Mode mode, int index, QObject *parent = nullptr);

    ~MyThread();


    QThread* thread;
    Runner* runner;

    void stop();

    bool getIsOver() const;

    int index() const;

    int get_m_index() const;

public slots:

   void m_quit();


private:
    QString URL;
    bool isOver=false;
    int m_index;
signals:


};

#endif // MYTHREAD_H
