#include "StreamerContainer.h"

StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{

}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::Mode mode)
{
    qDebug()<<"StreamerContainer::start "<<url;
    qDebug()<<"mode "<<mode;



    QSharedPointer<Streamer> streamer=nullptr;

  //  if(mode==Runner::Mode::LiveStreaming){
    streamer = find(url);

    if(streamer){
        qDebug()<<"берем из контейера "<<url;
    }
  //  }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(url,mode);
        connect(streamer.data(),SIGNAL(signal_thread_is_over()),this,SLOT(thread_is_over()));
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

        for(auto one : map){
            qDebug()<<one.data()->getURL();
            qDebug()<<one.data()->start_time.toString();
            qDebug()<<"индекс потока    : "<<one.data()->get_m_index();


            qDebug()<<"Подписчики       : "<<one.data()->getFollowers();
            qDebug()<<"Хранится         : "<<one.data()->getSave();
            qDebug()<<"runner завершен  :" <<one.data()->mm->runner->thread()->isFinished();
            qDebug()<<"mode             :" <<one.data()->mode;
            qDebug()<<"thread isFinished:" <<one.data()->mm->thread->isFinished();
            qDebug()<<"thread isRunning :" <<one.data()->mm->thread->isRunning();
            qDebug()<<" ";
        }








    if(streamer)
        return streamer;

    return nullptr;



}

QSharedPointer<Streamer> StreamerContainer::find(QString url)
{
    for(auto one : map){
        if(one.data()->getURL()==url){
            one->setSave(false);
            return one;
        }
    }
    return nullptr;
}

void StreamerContainer::thread_is_over()
{
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

        for(auto one : map){
            qDebug()<<one.data()->getURL();
            qDebug()<<one.data()->start_time.toString();
            qDebug()<<"индекс потока    : "<<one.data()->get_m_index();


            qDebug()<<"Подписчики       : "<<one.data()->getFollowers();
            qDebug()<<"Хранится         : "<<one.data()->getSave();
            qDebug()<<"runner завершен  :" <<one.data()->mm->runner->thread()->isFinished();
            qDebug()<<"mode             :" <<one.data()->mode;
            qDebug()<<"thread isFinished:" <<one.data()->mm->thread->isFinished();
            qDebug()<<"thread isRunning :" <<one.data()->mm->thread->isRunning();
            qDebug()<<" ";
        }
}


