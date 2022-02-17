#include "mythread.h"
#include "QDebug"

MyThread::MyThread(QImage* img, QString str, QObject *parent) : QObject(parent)
{
this->str=str;
    qDebug()<<"создаю "<<str;

    runner.str=str;
//connect(thread, &QThread::started, runner, &Runner::run);
    connect(&thread,&QThread::started,&runner,&Runner::run);
    connect(&runner, &Runner::finished, &thread, &QThread::quit);


    runner.img=img;
    runner.URL=str;
    runner.moveToThread(&thread);
//    thread.start();


}

MyThread::~MyThread()
{

    qDebug()<<"удаляю "<<str;

}

void MyThread::stop()
{
    qDebug("stop");
    runner.setRunning(false);
}









