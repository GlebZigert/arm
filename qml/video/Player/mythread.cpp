#include "mythread.h"
#include "QDebug"

MyThread::MyThread(AVPicture** data,int *h, int *w, QString URL,Runner::Mode mode, QObject *parent) : QObject(parent)
{
    isOver=false;
    runner = new Runner(data,h,w,URL,mode);
    thread = new QThread();


    this->URL=URL;
    if(mode!=Runner::Mode::TurnOff){
        runner->URL=URL;
        connect(thread,&QThread::started,runner,&Runner::run);
        connect(runner, &Runner::finished,  this, &MyThread::m_quit);


        runner->moveToThread(thread);
        qDebug()<<"  runner->moveToThread(thread);";
    }else{
         qDebug()<<"  FUCK SHIT =mode::turnOff";
    }

}

MyThread::~MyThread()
{
    qDebug()<<"DELETE "<<thread->isFinished()<<thread->isRunning()<<runner->URL;
    delete runner;
    delete thread;
        qDebug()<<"MyThread destroyed";
}

void MyThread::stop()
{
    runner->setRunning(Runner::Mode::TurnOff);
}

void MyThread::m_quit()
{
    qDebug()<<"MyThread::quit()";
    thread->quit();
    isOver=true;
}

bool MyThread::getIsOver() const
{
    return isOver;
}









