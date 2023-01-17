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

    for(auto one :map.values()){
       if(one.data()->mm->runner->thread()->isFinished()){
           map.remove(one->getURL());
       }

    }
    qDebug()<<" ";
    qDebug()<<"Потоки: "<<map.count();
     qDebug()<<" ";
    for(auto one :map.keys()){

        qDebug()<<one;
         qDebug()<<"пордписчики: "<<map.value(one)->getFollowers()<<"; завершен - "<<map.value(one).data()->mm->runner->thread()->isFinished();
 qDebug()<<" ";

    }




    if(streamer)
        return streamer;

    return nullptr;



}


