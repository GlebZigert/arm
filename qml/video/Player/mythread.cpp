#include "mythread.h"
#include "QDebug"

MyThread::MyThread(QImage* img, QString str,int mode, QObject *parent) : QObject(parent)
{
    this->str=str;
    if(mode!=mode::turnOff){
        runner.str=str;
        connect(&thread,&QThread::started,&runner,&Runner::run);
        connect(&runner, &Runner::finished, &thread, &QThread::quit);
        runner.m_running=mode;
        runner.img=img;
        runner.URL=str;
        runner.moveToThread(&thread);
    }

}

MyThread::~MyThread()
{

}

void MyThread::stop()
{
    runner.setRunning(false);
}









