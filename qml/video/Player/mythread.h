#ifndef MYTHREAD_H
#define MYTHREAD_H

#include <QObject>
#include <QThread>
#include "runner.h"

class MyThread : public QObject
{
    Q_OBJECT

public:
    explicit MyThread(QImage* img,QString str, QObject *parent = nullptr);

    ~MyThread();

    QThread thread;
    Runner runner;

    void stop();

public slots:


private:
    QString str;
signals:


};

#endif // MYTHREAD_H
