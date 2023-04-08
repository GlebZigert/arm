#include "Streamer.h"

int Streamer::index = 0;
int Streamer::created=0;
int Streamer::deleted=0;
Streamer::Streamer(QString URL, enum Runner::Mode mode,QObject *parent) : QObject(parent)
{
    created++;
    m_index=index++;
    start_time=QDateTime::currentDateTime();
    qDebug()<<"Streamer::Streamer "<<m_index<<" "<<URL;
    qDebug()<<"создано: "<<created<<" удалено: "<<deleted<<" живут: "<<created-deleted;
    count = 0;

    this->URL=URL;
    this->data=NULL;
    this->mode=mode;
  //  this->h=h;
  //  this->w=w;

    followers=0;

    //lost=QImage(":/qml/video/no_signal.jpeg");
  tmrStart = new QTimer(this);




  isValid=false;
}

Streamer::~Streamer()
{

    qDebug()<<"-->Streamer::~Streamer() "<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning()<<" "<<m_index;

    qDebug()<<"<--Streamer::~Streamer() "<<mm->runner->thread()->isFinished()<<" "<<mm->runner->thread()->isRunning()<<" "<<m_index;

    deleted++;
    qDebug()<<"создано: "<<created<<" удалено: "<<deleted<<" живут: "<<created-deleted;
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
    //qDebug()<<"followers "<<followers<<" "<<URL;
    frash_follower_time = QDateTime::currentDateTime();
}

void Streamer::followers_dec()
{
    if(followers>0){
        followers--;
    }

    if(mm->runner->getVideoHeight()<=480&&
      mm->runner->getVideoWidth()<=640){
        qDebug()<<"save low quality: "<<URL;
        return;
    }



    qDebug()<<"fStreamer::followers_dec. followers "<<followers<<" "<<URL<<" mode "<<mode<<" save "<<save;

    if(followers==0){

        no_followers=QDateTime::currentDateTime();
    }

    if(followers==0 && /*mode !=Runner::Mode::LiveStreaming && */save==false ){
       URL.clear();
        stop();
    }
}

bool Streamer::getSave() const
{
    return save;
}

void Streamer::setSave(bool newSave)
{
   // qDebug()<<"treamer::setSave "<<newSave<<" "<<URL;
    save = newSave;
}

int Streamer::getW() const
{
    return w;
}

int Streamer::getH() const
{
    return h;
}



void Streamer::start()
{
 //   qDebug()<<QTime::currentTime()<<" start "<<URL;
tmrStart->stop();
count++;

delay=10;
if(count>5){
    qDebug()<<"too long "<<URL;
    delay=1000;
}
if(count>25){
    qDebug()<<"too long "<<URL;
    delay=30000;
}
if(!isValid){

startRunner();
 tmrStart->singleShot(delay,this,SLOT(start()));
}
}

void Streamer::startRunner()
{
    qDebug()<<QTime::currentTime()<< "Streamer::startRunner() "<<URL<<" "<<delay<<" "<<count;


     if(mm!=nullptr){
     disconnect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
     disconnect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));


     if(mm->thread->isFinished()){
     mm.clear();
     }else{
         //qDebug()<<"thread not finished !!";
          mm->stop();
         return;

     }
     }


    mm = QSharedPointer<MyThread>::create(&data,&h,&w,URL,mode,m_index);

    connect(mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
    connect(mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lostConnection(QString)));
    connect(mm.data(),SIGNAL(signal_isOver()),this,SLOT(thread_is_over()));

    mm->thread->start();
    isValid=true;
}

void Streamer::thread_is_over()
{
    qDebug()<<"thread_is_over for "<<m_index<<" "<<URL;
    emit signal_thread_is_over();

}

void Streamer::stop()
{
 //   //qDebug()<<"stop";
    if(!isValid){
        return;
    }

    mode = Runner::Mode::TurnOff;
  //  //qDebug()<<"1";
    if(mm){
    mm->stop();
    }

/*
    //qDebug()<<mm->thread->isFinished()<<" "<<mm->thread->isRunning();
    if(mm->thread->isFinished()){
   // //qDebug()<<"2";

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
 //   //qDebug()<<"+";
    got_frame=true;
    count = 0;
    emit frame(URL);
}

void Streamer::lostConnection(QString URL)
{

    qDebug()<<"lostConnection";
    emit lost(URL);
    tmrStart->stop();
    isValid=false;
    if(mode == Runner::Mode::TurnOff){
        return;
    }




        if(mm){
        mm->stop();
        }

        if(URL!=""){

        tmrStart->singleShot(delay,this,SLOT(start()));
        }
        return;






}




