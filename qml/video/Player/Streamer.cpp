#include "Streamer.h"

Streamer::Streamer(int *h,int *w, QString URL, enum mode mode,QObject *parent) : QObject(parent)
{
    qDebug()<<"Streamer::Streamer "<<URL;
    this->URL=URL;
    this->data=NULL;
    this->mode=mode;
    this->h=h;
    this->w=w;

    followers=0;

    //lost=QImage(":/qml/video/no_signal.jpeg");
  tmrStart = new QTimer(this);


  isValid=false;
}

Streamer::~Streamer()
{

    qDebug()<<"Streamer::~Streamer() "<<URL;
}

int Streamer::getFollowers() const
{
    return followers;
}

const QString &Streamer::getURL() const
{
    return URL;
}

bool Streamer::getIsOver() const
{
    return isOver;
}

void Streamer::followers_inc()
{
    followers++;
    qDebug()<<"followers "<<followers<<" "<<URL;
}

void Streamer::followers_dec()
{
    if(followers>0){
        followers--;
    }
    qDebug()<<"followers "<<followers<<" "<<URL;

    if(followers==0){
       URL.clear();
        stop();
    }
}

int Streamer::getW() const
{
    return *w;
}

int Streamer::getH() const
{
    return *h;
}



void Streamer::start()
{
tmrStart->stop();
delay=10;
startRunner();

}

void Streamer::startRunner()
{
    qDebug()<<"Streamer::startRunner()";
    if(isValid){
        qDebug()<<"noValid";

        stop();
        tmrStart->singleShot(delay,this,SLOT(start()));
        return;
    }
     qDebug()<<"Valid";
    mm= QSharedPointer<MyThread>::create(&data,h,w,URL,mode);

    connect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
    connect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


    mm->thread->start();
    isValid=true;
}

void Streamer::stop()
{
    qDebug()<<"stop";
    if(!isValid)
        return;
  //  qDebug()<<"1";
    if(mm)
    mm->stop();
    qDebug()<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning();
    if(mm->runner->thread()->isFinished()){
   // qDebug()<<"2";

        isValid=false;

        isOver=true;

    }




}

AVPicture *Streamer::getData() const
{
    return data;
}



void Streamer::receiveFrame(QString URL)
{
 //   qDebug()<<"+";
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




