#include "StreamerContainer.h"

StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{

}

QSharedPointer<Streamer> StreamerContainer::start(int *h,int *w,QString url, mode mode)
{
    qDebug()<<"StreamerContainer::start "<<url;
    qDebug()<<"mode "<<(mode==mode::turnOff?"turnOff":(mode==mode::Streaming)?"Streaming":"Snapshot");

    QSharedPointer<Streamer> streamer = map.value(url);

    if(streamer){
        qDebug()<<"берем из контейера "<<url;
    }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(h,w,url,mode);
        if(streamer){
            map.insert(url,streamer);
            qDebug()<<"добавляем в контейер "<<url;

        streamer->start();


        }
        else{
            qDebug()<<"ffFai;l";

        }

    }

    if(streamer)
        return streamer;

    return nullptr;



}

