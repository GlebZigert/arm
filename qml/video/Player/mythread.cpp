#include "mythread.h"
#include "QDebug"

MyThread::MyThread(AVPicture** data,int *h, int *w, QString URL,Runner::Mode mode, int index, QObject *parent) : QObject(parent)
{
    m_index=index;

    isOver=false;
    runner = new Runner(m_index,data,h,w,URL,mode);
    thread = new QThread();


    this->URL=URL;
    if(mode!=Runner::Mode::TurnOff){
        runner->URL=URL;
        connect(thread,&QThread::started,runner,&Runner::run);
        connect(runner, &Runner::finished,  this, &MyThread::m_quit);


        runner->moveToThread(thread);
        //qDebug()<<"  runner->moveToThread(thread);";
    }else{
         //qDebug()<<"  FUCK SHIT =mode::turnOff";
    }

}

MyThread::~MyThread()
{
     //qDebug()<<"-->MyThread::~MyThread() "<<m_index;
    //qDebug()<<"DELETE "<<thread->isFinished()<<thread->isRunning()<<m_index;
    delete runner;
    delete thread;
     //qDebug()<<"<--MyThread::~MyThread() "<<m_index;
}

void MyThread::stop()
{
    runner->setRunning(Runner::Mode::TurnOff);
}

void MyThread::m_quit()
{
    //qDebug()<<"MyThread::quit()";
    thread->quit();
    isOver=true;
}

int MyThread::get_m_index() const
{
    return m_index;
}

bool MyThread::getIsOver() const
{
    return isOver;
}









