#include "Streamer.h"

Streamer::Streamer(int *h,int *w, QString URL, enum mode,QObject *parent) : QObject(parent)
{
    qDebug()<<"Streamer::Streamer "<<URL;
    this->URL=URL;
    data=NULL;

    this->h=h;
    this->w=w;

    //lost=QImage(":/qml/video/no_signal.jpeg");
  tmrStart = new QTimer(this);


  isValid=false;
}



void Streamer::start()
{
tmrStart->stop();
delay=10;
startRunner();

}

void Streamer::startRunner()
{
    if(isValid){
    //    qDebug()<<".";

        stop();
        tmrStart->singleShot(delay,this,SLOT(start()));
        return;
    }

    mm=new MyThread(&data,h,w,URL,mode);

    connect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
    connect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


    mm->thread->start();
    isValid=true;
}

void Streamer::stop()
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

AVPicture *Streamer::getData() const
{
    return data;
}



void Streamer::receiveFrame(QString URL)
{
    qDebug()<<"+";
    emit frame(URL);
}

void Streamer::lostConnection(QString URL)
{

    qDebug()<<"lostConnection";
    emit lost(URL);
    tmrStart->stop();
    delay=1000;
    startRunner();


}




