#include "videoplayer.h"
#include <QPainter>
VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{
    list=new threadList(&img);
    connect(list,SIGNAL(frame()),this,SLOT(frame()));

    img=QImage();
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
    list->tmr->stop();
    list->step=0;
    list->cnt2=0;
    list->cnt3=0;
    list->URL=m_source;
    list->mode=mode::Streaming;
    list->process();
}

void VideoPlayer::stop()
{
    list->tmr->stop();
    foreach(QString str, list->list.keys()){
        list->remove(str);
    }

}



void VideoPlayer::shot()
{
    list->tmr->stop();
    list->cnt3=0;
    list->step=0;
    list->URL=m_source;
    list->mode=mode::Snapshot;
    list->process();
}

void VideoPlayer::onWidthChanged(){
    update();
}

void VideoPlayer::onheightChanged(){
    update();
}

void VideoPlayer::frame(){
    this->update();
}




