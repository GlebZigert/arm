#include "StreamerContainer.h"

StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{

}

QSharedPointer<Streamer> StreamerContainer::start(int *h,int *w,QString url, mode mode)
{
    qDebug()<<"StreamerContainer::start "<<url;
    qDebug()<<"mode "<<(mode==mode::turnOff?"turnOff":(mode==mode::Streaming)?"Streaming":"Snapshot");

    QSharedPointer<Streamer> streamer = find(url);

    if(streamer){
        qDebug()<<"берем из контейера "<<url;
    }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(h,w,url,mode);
        if(streamer){
            map.append(streamer);
            qDebug()<<"добавляем в контейер "<<url;

        streamer->start();


        }
        else{
            qDebug()<<"ffFai;l";

        }

    }

    for(auto one : map){
       if(one.data()->mm->runner->thread()->isFinished()){
           map.removeOne(one);
       }

    }
    qDebug()<<" ";
    qDebug()<<"Потоки: "<<map.count();
     qDebug()<<" ";
    for(auto one :map){

        qDebug()<<one.data()->getURL();
         qDebug()<<"пордписчики: "<<one.data()->getFollowers()<<"; завершен - " <<one.data()->mm->runner->thread()->isFinished();
 qDebug()<<" ";

    }




    if(streamer)
        return streamer;

    return nullptr;



}

QSharedPointer<Streamer> StreamerContainer::find(QString url)
{
    for(auto one : map){
        if(one.data()->getURL()==url)
            return one;
    }
    return nullptr;
}


