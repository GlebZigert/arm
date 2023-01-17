#include "mythread.h"
#include "QDebug"

MyThread::MyThread(AVPicture** data,int *h, int *w, QString URL,int mode, QObject *parent) : QObject(parent)
{
    runner = new Runner(data,h,w,URL,mode);
    thread = new QThread();


    this->URL=URL;
    if(mode!=mode::turnOff){
        runner->URL=URL;
        connect(thread,&QThread::started,runner,&Runner::run);
        connect(runner, &Runner::finished, thread, &QThread::quit);


        runner->moveToThread(thread);
        qDebug()<<"  runner->moveToThread(thread);";
    }else{
         qDebug()<<"  FUCK SHIT =mode::turnOff";
    }

}

MyThread::~MyThread()
{
    qDebug()<<"DELETE "<<runner->URL;
    delete runner;
    delete thread;
        qDebug()<<"MyThread destroyed";
}

void MyThread::stop()
{
    runner->setRunning(mode::turnOff);
}

void MyThread::quit()
{

}









