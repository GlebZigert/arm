#include "mythread.h"
#include "QDebug"

MyThread::MyThread(QImage* img, QString str,int mode, QObject *parent) : QObject(parent)
{
    runner = new Runner();
    thread = new QThread();
    this->str=str;
    if(mode!=mode::turnOff){
        runner->str=str;
        connect(thread,&QThread::started,runner,&Runner::run);
        connect(runner, &Runner::finished, thread, &QThread::quit);
        runner->m_running=mode;
        runner->img=img;
        runner->URL=str;
        runner->moveToThread(thread);
    }

}

MyThread::~MyThread()
{
    qDebug()<<"DELETE "<<runner->URL;
    delete runner;
    delete thread;
}

void MyThread::stop()
{
    runner->setRunning(false);
}









