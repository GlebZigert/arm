#include "StreamerContainer.h"
static std::mutex mutex;
StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{

}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::Mode mode)
{

    qDebug()<<"--> StreamerContainer::start "<<url;
    qDebug()<<"mode "<<mode;
mutex.lock();


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



      int i=0;
      int map_count=map.count();
    for(int i=0;i<map_count;i++){
    auto one = map.at(i);
       qDebug()<<".";
       if(
                one&&
               one.data()->mode == Runner::Mode::TurnOff &&
               one.data()->mm->thread->isFinished()&&
               !one.data()->mm->thread->isRunning()
               )

               {

           qDebug()<<"map.removeOne "<<one.data()->mm->thread->isFinished()<<" "<<one.data()->mm->thread->isRunning()<<" "<<one->getURL()<<" "<<one->get_m_index();
           map.removeOne(one);
            map_count=map.count();
qDebug()<<"<--map.removeOne ";
       }else{
           qDebug()<<"?";
       }

    }


    qDebug()<<" ";
    qDebug()<<"Потоки: "<<map.count();
     qDebug()<<" ";

        for(auto one : map){
            qDebug()<<one.data()->getURL();
            qDebug()<<one.data()->start_time.toString();
            qDebug()<<"индекс: "<<one.data()->get_m_index()
            <<"Подписчики: "<<one.data()->getFollowers()
            <<"Хранится: "<<one.data()->getSave()
            <<"runner завершен:" <<one.data()->mm->runner->thread()->isFinished()
            <<"mode: " <<one.data()->mode
            <<"Finished: " <<one.data()->mm->thread->isFinished()
            <<"Running : " <<one.data()->mm->thread->isRunning();

            qDebug()<<" ";
            if(one.data()->getURL()==""){
                one->stop();
            }
        }


             qDebug()<<" ";
              mutex.unlock();

 qDebug()<<"<-- StreamerContainer::start "<<url;
    if(streamer)
        return streamer;


    return nullptr;



}

QSharedPointer<Streamer> StreamerContainer::find(QString url)
{
    qDebug()<<"--> StreamerContainer::find "<<url;

    for(auto one : map){
        if(one.data()->getURL()==url){
            one->setSave(false);


            mutex.unlock();
            qDebug()<<"<-- StreamerContainer::find [0] "<<url;
            return one;
        }
    }


    qDebug()<<"<-- StreamerContainer::find [1]"<<url;
    return nullptr;
}

void StreamerContainer::thread_is_over()
{
        qDebug()<<"--> StreamerContainer::thread_is_over ";
      mutex.lock();


      int i=0;
      int map_count=map.count();
    for(int i=0;i<map_count;i++){
    auto one = map.at(i);
       qDebug()<<".";
       if(
                one&&
               one.data()->mode == Runner::Mode::TurnOff &&
               one.data()->mm->thread->isFinished()&&
               !one.data()->mm->thread->isRunning()
               )

               {

           qDebug()<<"map.removeOne "<<one.data()->mm->thread->isFinished()<<" "<<one.data()->mm->thread->isRunning()<<" "<<one->getURL()<<" "<<one->get_m_index();
           map.removeOne(one);
            map_count=map.count();
qDebug()<<"<--map.removeOne ";
       }else{
           qDebug()<<"?";
       }

    }

    qDebug()<<" ";
    qDebug()<<"Потоки: "<<map.count();
     qDebug()<<" ";

        for(auto one : map){
            qDebug()<<one.data()->getURL();
            qDebug()<<one.data()->start_time.toString();
            qDebug()<<"индекс: "<<one.data()->get_m_index()
            <<"Подписчики: "<<one.data()->getFollowers()
            <<"Хранится: "<<one.data()->getSave()
            <<"runner завершен:" <<one.data()->mm->runner->thread()->isFinished()
            <<"mode: " <<one.data()->mode
            <<"Finished: " <<one.data()->mm->thread->isFinished()
            <<"Running : " <<one.data()->mm->thread->isRunning();
    qDebug()<<" ";
            if(one.data()->getURL()==""){
                one->stop();
            }
        }
            qDebug()<<" ";

   mutex.unlock();
        qDebug()<<"<-- StreamerContainer::thread_is_over ";
}


