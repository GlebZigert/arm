#include "StreamerContainer.h"

StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{

}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::Mode mode)
{
    qDebug()<<"StreamerContainer::start "<<url;
    qDebug()<<"mode "<<mode;



    QSharedPointer<Streamer> streamer=nullptr;

    if(mode==Runner::Mode::LiveStreaming){
    streamer = find(url);

    if(streamer){
        qDebug()<<"берем из контейера "<<url;
    }
    }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(url,mode);
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

       if(

               one.data()->mode == Runner::Mode::TurnOff &&
               one.data()->mm->thread->isFinished()&&
               !one.data()->mm->thread->isRunning()

               )


               {
           qDebug()<<"map.removeOne "<<one.data()->mm->thread->isFinished()<<" "<<one.data()->mm->thread->isRunning()<<" "<<one->getURL();
           map.removeOne(one);
       }

    }
    qDebug()<<" ";
    qDebug()<<"Потоки: "<<map.count();
     qDebug()<<" ";
    for(auto one :map){

        qDebug()<<one.data()->getURL();
         qDebug()<<"подписчики: "<<one.data()->getFollowers()<<"; завершен - " <<one.data()->mm->runner->thread()->isFinished();
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


