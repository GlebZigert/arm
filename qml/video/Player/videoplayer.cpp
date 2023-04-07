#include "videoplayer.h"
#include <QPainter>

StreamerContainer VideoPlayer::container;

VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{
    //qDebug()<<"VideoPlayer::VideoPlayer";


    connection = false;

    data=NULL;

    connect(&cleaner, SIGNAL(timeout()), this, SLOT(f_clear()));



  //  list1=new Streamer(&data,&h,&w);
  //  list1->URL="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpnt.1/SourceEndpoint.video:0:0";

  //  connect(list1,SIGNAL(frame(QString)),this,SLOT(frame(QString)));
  //  connect(list1,SIGNAL(lost(QString)),this,SLOT(lost(QString)));

}

VideoPlayer::~VideoPlayer()
{
 qDebug()<<"--> ~VideoPlayer::VideoPlayer";

    if(current){
        //если мы уже принимаем поток - нужно от него отписаться
        disconnect(current.data(),SIGNAL(frame(QString)),this,SLOT(frame(QString)));
        disconnect(current.data(),SIGNAL(lost(QString)),this,SLOT(lost(QString)));
        current->followers_dec();
        //qDebug()<<"clear "<<current.data()->getURL();
        current.clear();
        data=NULL;

    }
qDebug()<<"<-- ~VideoPlayer::VideoPlayer";
}


void VideoPlayer::paint(QPainter *painter)
{

    if(data!=NULL){
 /*   QImage img=QImage(data->data[0],
            w,
            h,
            QImage::Format_RGB32);
*/

    painter->drawImage(QRect(0, 0, this->width(), this->height()), img);
 //   //qDebug()<<"+ "<<this->width()<<" "<<this->height()<<" "<<img.size();
    }

}

QString VideoPlayer::source() const
{
    return m_source;
}

void VideoPlayer::setSource(const QString source)
{

    m_source=source;
    emit sourceChanged(m_source);
}





void VideoPlayer::start(Runner::Mode mode)
{
    qDebug()<<"VideoPlayer::start "<<m_source<<" "<<mode;

    if(current){

        if(current.data()->getURL()==m_source && mode != Runner::Mode::Snapshot){

            qDebug()<<"это он и  есть";
            return;
        }

        //если мы уже принимаем поток - нужно от него отписаться
        disconnect(current.data(),SIGNAL(frame(QString)),this,SLOT(frame(QString)));
        disconnect(current.data(),SIGNAL(lost(QString)),this,SLOT(lost(QString)));
        current->followers_dec();
        //qDebug()<<"clear "<<current.data()->getURL();
        current.clear();

    }


    if(m_source==""){
    //    img=QImage(":/qml/video/.jpeg");
  // this->update();
        return;
    }




  current = container.start(m_source,mode);

  if(current){
        current->followers_inc();
        data = current.data()->getData();

        connect(current.data(),SIGNAL(frame(QString)),this,SLOT(frame(QString)));
        connect(current.data(),SIGNAL(lost(QString)),this,SLOT(lost(QString)));
  }


  if(mode==Runner::Mode::Snapshot && current.data()->got_frame){

      data = current.data()->getData();
      w = current.data()->getW();
      h = current.data()->getH();


          img=QImage(data->data[0],
                  w,
                  h,
                  QImage::Format_RGB32);

          connection = true;
          this->update();



}
}

void VideoPlayer::stop()
{
    //qDebug()<<"VideoPlayer::stop()";
    if(current){
    disconnect(current.data(),SIGNAL(frame(QString)),this,SLOT(frame(QString)));
    disconnect(current.data(),SIGNAL(lost(QString)),this,SLOT(lost(QString)));
    current->followers_dec();
    //qDebug()<<"clear "<<current.data()->getURL();
    current.data()->save=false;
    current.clear();
    data=NULL;
    }
 // list1->stop();
}

void VideoPlayer::shot()
{

    if(m_source==""){
        img=QImage(":/qml/video/no_in_storage.jpeg");
   this->update();
    }

}

void VideoPlayer::saving_on()
{
    if(current!=0){
        current.data()->setSave(true);
    }
}

void VideoPlayer::saving_off()
{
    if(current!=0){
        current.data()->setSave(false);
    }

}

void VideoPlayer::clear()
{
cleaner.start(1000);
}

Runner::Mode VideoPlayer::getMode()
{
    if(!connection)
        return Runner::NoSignal;

    if(current){
        auto mode = current.data()->mode;
        return mode;
    }
    return Runner::NoSignal;
}

int VideoPlayer::getCid() const
{
 //   qDebug()<<"VideoPlayer::getCid()";
    return cid;
}

void VideoPlayer::setCid(int newCid)
{
   //qDebug()<<"VideoPlayer::setCid(): "<< newCid;
    cid = newCid;
        emit cidChanged(cid);
}



void VideoPlayer::onWidthChanged(){
    update();
}

void VideoPlayer::onheightChanged(){
   update();
}

void VideoPlayer::frame(QString source){

//    qDebug()<<"VideoPlayer::frame "<<source;
    data = current.data()->getData();
    w = current.data()->getW();
    h = current.data()->getH();


    if(source==this->m_source&&data!=NULL){

        cleaner.stop();
         img=QImage(data->data[0],
                    w,
                    h,
                    QImage::Format_RGB32);

    connection = true;
    this->update();
    }

}

void VideoPlayer::lost(QString source)
{
        connection = false;
        //qDebug()<<"lost";
    if(source==this->m_source){
     //    img=QImage(":/qml/video/no_signal.jpeg");
  //  this->update();
    }

}

void VideoPlayer::f_clear()
{
    img=QImage();
    this->update();
}




