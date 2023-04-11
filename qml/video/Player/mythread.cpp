#include "mythread.h"
#include "QDebug"
int MyThread::created=0;
int MyThread::deleted=0;
MyThread::MyThread(AVPicture** data,int *h, int *w, QString URL,Runner::Mode mode, int index, QObject *parent) : QObject(parent)
{
    created++;
    m_index=index;

    isOver=false;
    runner = QSharedPointer<Runner>::create(m_index,data,h,w,URL,mode);
    thread = QSharedPointer<QThread>::create();


    this->URL=URL;
    if(mode!=Runner::Mode::TurnOff){
        runner->URL=URL;
        connect(thread.data(),&QThread::started,runner.data(),&Runner::run);
        connect(runner.data(), &Runner::finished,  this, &MyThread::m_quit);


        runner->moveToThread(thread.data());
        //qDebug()<<"  runner->moveToThread(thread);";
    }else{
         //qDebug()<<"  FUCK SHIT =mode::turnOff";
    }

}

MyThread::~MyThread()
{
     //qDebug()<<"-->MyThread::~MyThread() "<<m_index;
    //qDebug()<<"DELETE "<<thread->isFinished()<<thread->isRunning()<<m_index;
    deleted++;
  //  delete runner;

     //qDebug()<<"<--MyThread::~MyThread() "<<m_index;
}

void MyThread::stop()
{
    runner->setRunning(Runner::Mode::TurnOff);
}

void MyThread::m_quit()
{
 //   qDebug()<<"MyThread::quit()";
    thread->quit();
    isOver=true;
    emit signal_isOver();
}

int MyThread::get_m_index() const
{
    return m_index;
}

bool MyThread::getIsOver() const
{
    return isOver;
}









