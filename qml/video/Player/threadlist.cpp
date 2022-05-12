#include "threadlist.h"

threadList::threadList(AVPicture **data,int *h,int *w, QObject *parent) : QObject(parent)
{
    this->data=data;
    this->h=h;
    this->w=w;

    //lost=QImage(":/qml/video/no_signal.jpeg");
  tmrStart = new QTimer(this);


  isValid=false;
}



void threadList::start()
{
tmrStart->stop();
delay=10;
startRunner();

}

void threadList::startRunner()
{
    if(isValid){
    //    qDebug()<<".";

        stop();
        tmrStart->singleShot(delay,this,SLOT(start()));
        return;
    }

    mm=new MyThread(data,h,w,URL,mode);

    connect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
    connect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


    mm->thread->start();
    isValid=true;
}

void threadList::stop()
{
  //  qDebug()<<"stop";
    if(!isValid)
        return;
  //  qDebug()<<"1";
    if(mm)
    mm->stop();
  //  qDebug()<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning();
    if(mm->runner->thread()->isFinished()){
   // qDebug()<<"2";
        if(mm)
        delete mm;
        isValid=false;

    }
}



void threadList::receiveFrame(QString URL)
{

    emit frame(URL);
}

void threadList::lostConnection(QString URL)
{

  //  qDebug()<<"lostConnection";
    emit lost(URL);
    tmrStart->stop();
    delay=1000;
    startRunner();


}




