#include "videoplayer.h"
#include <QPainter>
VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{
    data=NULL;
    list1=new threadList(&data,&h,&w);
    list1->URL="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpnt.1/SourceEndpoint.video:0:0";

    connect(list1,SIGNAL(frame(QString)),this,SLOT(frame(QString)));
    connect(list1,SIGNAL(lost(QString)),this,SLOT(lost(QString)));

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
    }

}

QString VideoPlayer::source() const
{
    return m_source;
}

void VideoPlayer::setSource(const QString source)
{
    m_source=source;
}





void VideoPlayer::start()
{
    if(m_source==""){
        img=QImage(":/qml/video/no_in_storage.jpeg");
   this->update();
    }else{
    list1->URL=m_source;
    list1->mode=mode::Streaming;
   list1->start();
    }
}

void VideoPlayer::stop()
{
  list1->stop();
}

void VideoPlayer::shot()
{
    if(m_source==""){
        img=QImage(":/qml/video/no_in_storage.jpeg");
   this->update();
    }else{
    list1->URL=m_source;
    list1->mode=mode::Snapshot;
   list1->start();
    }
}



void VideoPlayer::onWidthChanged(){
    update();
}

void VideoPlayer::onheightChanged(){
    update();
}

void VideoPlayer::frame(QString source){

    if(source==this->m_source){
         img=QImage(data->data[0],
                    w,
                    h,
                    QImage::Format_RGB32);
    this->update();
    }
}

void VideoPlayer::lost(QString source)
{
    if(source==this->m_source){
         img=QImage(":/qml/video/no_signal.jpeg");
    this->update();
    }
}




