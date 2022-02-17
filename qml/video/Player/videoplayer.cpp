#include "videoplayer.h"
#include <QPainter>
VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{

    list=new threadList(&img);

    connect(list,SIGNAL(frame()),this,SLOT(frame()));

}


void VideoPlayer::paint(QPainter *painter)
{

painter->drawImage(QRect(0, 0, this->width(), this->height()), img);


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
qDebug()<<"[start]";

list->step=0;
list->URL=m_source;
list->mode=mode::Streaming;
list->process();
}

void VideoPlayer::stop()
{
qDebug()<<"[stop]";
foreach(QString str, list->list.keys()){


       list->remove(str);
   }




}

void VideoPlayer::check()
{
}

void VideoPlayer::shot()
{
qDebug()<<"[shot]";
list->step=0;
list->URL=m_source;
list->mode=mode::Snapshot;
list->process();
}

void VideoPlayer::onWidthChanged(){
//qDebug()<<width();
update();
}

void VideoPlayer::onheightChanged(){
//qDebug()<<height();
    update();
}

void VideoPlayer::frame()
{
    this->update();
}




