#include "Streamer.h"

int Streamer::index = 0;

Streamer::Streamer(int *h,int *w, QString URL, enum Runner::Mode mode,QObject *parent) : QObject(parent)
{
    m_index=index++;
    qDebug()<<"Streamer::Streamer "<<m_index;



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

    qDebug()<<"-->Streamer::~Streamer() "<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning()<<" "<<m_index;

    qDebug()<<"<--Streamer::~Streamer() "<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning()<<" "<<m_index;
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

int Streamer::get_m_index() const
{
    return m_index;
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

    if(followers==0 && mode !=Runner::Mode::LiveStreaming){
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
//    qDebug()<<"Streamer::startRunner()";
    if(isValid){
  //      qDebug()<<"noValid";

        stop();
        tmrStart->singleShot(delay,this,SLOT(start()));
        return;
    }
     qDebug()<<"Valid";


     if(mm!=nullptr){
     disconnect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
     disconnect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


     mm.clear();
     }


    mm = QSharedPointer<MyThread>::create(&data,h,w,URL,mode,m_index);

    connect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
    connect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


    mm->thread->start();
    isValid=true;
}

void Streamer::stop()
{
 //   qDebug()<<"stop";
    if(!isValid){
        return;
    }

    mode = Runner::Mode::TurnOff;
  //  qDebug()<<"1";
    if(mm){
    mm->stop();
    }

/*
    qDebug()<<mm->thread->isFinished()<<" "<<mm->thread->isRunning();
    if(mm->thread->isFinished()){
   // qDebug()<<"2";

        isValid=false;

        isOver=true;

    }
    */




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

    if(mode == Runner::Mode::TurnOff)
        return;


    delay=1000;
    startRunner();


}




