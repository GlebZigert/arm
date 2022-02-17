#include "videoplayer.h"
#include <QPainter>
VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{

    list=new threadList(&img);

    connect(list,SIGNAL(frame()),this,SLOT(paint()));

}


void VideoPlayer::paint(QPainter *painter)
{




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
list->process();
}

void VideoPlayer::stop()
{
qDebug()<<"[stop]";
}

void VideoPlayer::check()
{
}

void VideoPlayer::shot()
{
qDebug()<<"[shot]";
}

void VideoPlayer::onWidthChanged(){
//qDebug()<<width();
update();
}

void VideoPlayer::onheightChanged(){
//qDebug()<<height();
    update();
}




