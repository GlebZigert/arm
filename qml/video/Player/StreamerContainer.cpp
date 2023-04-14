#include "StreamerContainer.h"
static std::mutex mutex;

QList<QSharedPointer<Streamer>> StreamerContainer::map;


void StreamerContainer::func(){
    int free=0;
    int play=0;
    qDebug()<<" ";
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count();
     qDebug()<<" ";
bool flag=true;
        for(auto one : map){
            if(flag){
                flag=false;
              qDebug()<<"стримеров создано: "<<one.data()->created<<" удалено: "
                     <<one.data()->deleted<<" живут: "
                    <<one.data()->created-one.data()->deleted;

              qDebug()<<"тредов     создано: "<<one.data()->mm->created<<" удалено: "
                     <<one.data()->mm->deleted<<" живут: "
                    <<one.data()->mm->created-one.data()->mm->deleted;

              qDebug()<<"раннеров  создано: "<<one.data()->mm->runner->created<<" удалено: "
                     <<one.data()->mm->runner->deleted<<" живут: "
                    <<one.data()->mm->runner->created-one.data()->mm->runner->deleted;

              qDebug()<<"кодеки: открыто "<<one.data()->mm->runner->av_codec_open<<" yне открылись: "
                     <<one.data()->mm->runner->av_codec_not_open<<" закрыто: "
                    <<one.data()->mm->runner->av_codec_close<<" не закрытых: "
<<one.data()->mm->runner->av_codec_open+one.data()->mm->runner->av_codec_not_open-one.data()->mm->runner->av_codec_close;
  qDebug()<<"";
            }
            QString sstr="";
            if(one.data()->mm->runner->m_running!=Runner::Mode::Free)
            if(one.data()->getFollowers()==0){
         sstr+=" без подписчиков уже ";
         qint64 sec =one->no_followers.secsTo(QDateTime::currentDateTime());
                    sstr+=QString::number(sec,10);
                    sstr+=" сек";
            }else{
                sstr+=" cвежая подписка: ";
                 qint64 sec=one->frash_follower_time.secsTo(QDateTime::currentDateTime());
                           sstr+=QString::number(sec,10);
                           sstr+=" сек";
        //    qDebug()<<"Свежая подписка: "<<one->frash_follower_time.secsTo(QDateTime::currentDateTime())<<" сек";

            }


            qDebug()<<"индекс: "<<one.data()->get_m_index()
                   <<" mode: "<<one.data()->mm->runner->get_state()
                     <<"Подписчики: "<<one.data()->getFollowers()
                    <<sstr
                       ;

        //    qDebug()<<one.data()->getURL();
        //    qDebug()<<one.data()->start_time.toString()<<" "<<one->start_time.secsTo(QDateTime::currentDateTime())<<" сек";
        //    qDebug()<<"подписчики: "<<one.data()->getFollowers();

            if(one.data()->getFollowers()==0){
         //       qDebug()<<"без подписчиков уже "<<one->no_followers.secsTo(QDateTime::currentDateTime())<<" сек";
            }else{
        //    qDebug()<<"Свежая подписка: "<<one->frash_follower_time.secsTo(QDateTime::currentDateTime())<<" сек";

            }
/*
            qDebug()<<"Хранится: "<<one.data()->getSave()
            <<"runner завершен:" <<one.data()->mm->runner->thread()->isFinished()
            <<"mode: " <<one.data()->mode
            <<"Finished: " <<one.data()->mm->thread->isFinished()
            <<"Running : " <<one.data()->mm->thread->isRunning();
*/


            if(one.data()->getURL()==""){
                one->stop();
            }

    if(one.data())
        if(one.data()->mm)
            if(one.data()->mm->runner)
        if(
            //    one.data()->mm->runner->getVideoHeight()>480&&
            //      one.data()->mm->runner->getVideoWidth()>640&&
        //        one->mode==2 &&
            one->getFollowers()==0 &&
                one.data()->mm->runner->m_running==Runner::Mode::Play
            ){

            auto now = QDateTime::currentDateTime();
                auto diff = one->no_followers.secsTo(now);
         //   qDebug()<<"этот поток "<<one.data()->getURL()<<" хранится уже "<<diff<<" сек";
            if(diff>2){
                qDebug()<<" потоку "<<one.data()->get_m_index()<<" сбрасываем save";
                one->setSave(false);
                one->followers_dec();
            }
        }
      }

        QList<QSharedPointer<Streamer>>::iterator it = map.begin();
        while(it != map.end()){
            if(it->data()->mm->runner->m_running == Runner::Mode::Exit &&
                    it->data()->mm->thread->isFinished()&&
                    !it->data()->mm->thread->isRunning()
                    ){
                    it = map.erase(it);
        }else{
                ++it;
            }
        }



        qDebug()<<" ";
        qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count();
        qDebug()<<" ";
}

void StreamerContainer::show()
{
    qDebug()<<" ";
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count();
     qDebug()<<" ";
bool flag=true;
    for(auto one : map){
        if(flag){
            flag=false;
          qDebug()<<"стримеров создано: "<<one.data()->created<<" удалено: "
                 <<one.data()->deleted<<" живут: "
                <<one.data()->created-one.data()->deleted;

          qDebug()<<"тредов     создано: "<<one.data()->mm->created<<" удалено: "
                 <<one.data()->mm->deleted<<" живут: "
                <<one.data()->mm->created-one.data()->mm->deleted;

          qDebug()<<"раннеров  создано: "<<one.data()->mm->runner->created<<" удалено: "
                 <<one.data()->mm->runner->deleted<<" живут: "
                <<one.data()->mm->runner->created-one.data()->mm->runner->deleted;

          qDebug()<<"кодеки: открыто "<<one.data()->mm->runner->av_codec_open<<" yне открылись: "
                 <<one.data()->mm->runner->av_codec_not_open<<" закрыто: "
                <<one.data()->mm->runner->av_codec_close<<" не закрытых: "
<<one.data()->mm->runner->av_codec_open+one.data()->mm->runner->av_codec_not_open-one.data()->mm->runner->av_codec_close;

        }
        qDebug()<<"индекс: "<<one.data()->get_m_index()<<" mode: "<<one.data()->mm->runner->get_state();

        qDebug()<<one.data()->getURL();
        qDebug()<<one.data()->start_time.toString()<<" "<<one->start_time.secsTo(QDateTime::currentDateTime())<<" сек";
        qDebug()<<"Подписчики: "<<one.data()->getFollowers();

        if(one.data()->getFollowers()==0){
            qDebug()<<"без подписчиков уже "<< one->no_followers.secsTo(QDateTime::currentDateTime())<<" сек";
        }else{
        qDebug()<<"Свежая подписка: "<<one->frash_follower_time.secsTo(QDateTime::currentDateTime())<<" сек";

        }

        qDebug()<<"Хранится: "<<one.data()->getSave()
        <<"runner завершен:" <<one.data()->mm->runner->thread()->isFinished()
        <<"mode: " <<one.data()->mode
        <<"Finished: " <<one.data()->mm->thread->isFinished()
        <<"Running : " <<one.data()->mm->thread->isRunning();

        qDebug()<<" ";



  }
}


StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{
qDebug()<<"StreamerContainer::StreamerContainer";
timer=QSharedPointer<QTimer>::create();


connect(timer.data(),
        &QTimer::timeout
        ,
        [=](){qDebug()<<".";});
/*
    connect(timer.data(),
            SIGNAL(timeout()),
            this,
            SLOT(on_timer()));

    */

    timer->start(1000);
    qDebug()<<"timer: "<<timer->isActive()<<" "<<timer->isSingleShot();
}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::Mode mode)
{
func();
 //   qDebug()<<"--> StreamerContainer::start "<<url;
 //   qDebug()<<"mode "<<mode;
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
    //    connect(streamer.data(),SIGNAL(signal_thread_is_over()),&StreamerContainer::thread_is_over));
        if(streamer){

            map.append(streamer);

            qDebug()<<"добавляем в контейер "<<url;

        streamer->start();


        }
        else{
         //   qDebug()<<"ffFai;l";

        }

    }







             qDebug()<<" ";
              mutex.unlock();

// qDebug()<<"<-- StreamerContainer::start "<<url;
    if(streamer)
        return streamer;


    return nullptr;

show();

}

void StreamerContainer::delete_free_streamers()
{
    qDebug()<<"delete all free streamers";
    QList<QSharedPointer<Streamer>>::iterator it = map.begin();
    while(it != map.end()){
        if(it->data()->mm->runner->m_running == Runner::Mode::Free ){

                it->data()->mm->runner->m_running=Runner::Mode::Exit;

            }

           ++it;
        }


}

QSharedPointer<Streamer> StreamerContainer::find(QString url)
{
  //  qDebug()<<"--> StreamerContainer::find "<<url;

    for(auto one : map){
        if(one.data()->getURL()==url){
            one->setSave(false);


            mutex.unlock();
            qDebug()<<"<-- StreamerContainer::find [0] "<<one.data()->get_m_index();
            return one;
        }
    }

    for(auto one : map){
        if(one.data()->mm->runner->m_running==Runner::Mode::Free){
            qDebug()<<"нашел свободный "<<one.data()->get_m_index();
            one->setSave(false);

            one.data()->mm->runner->URL=url;
            one.data()->mm->runner->frash_stream=true;

            mutex.unlock();
            qDebug()<<"<-- StreamerContainer::find [1] "<<one.data()->get_m_index();
            return one;
        }
    }


   qDebug()<<"<-- StreamerContainer::find [2]";
    return nullptr;
}

void StreamerContainer::thread_is_over()
{
    //    qDebug()<<"--> StreamerContainer::thread_is_over ";
      mutex.lock();




  //------------------------------
      QList<QSharedPointer<Streamer>>::iterator it = map.begin();
      while(it != map.end()){
          if(it->data()->mode == Runner::Mode::TurnOff &&
                  it->data()->mm->thread->isFinished()&&
                  !it->data()->mm->thread->isRunning()
                  ){
                  it = map.erase(it);
      }else{
              ++it;
          }
      }



      /*
    for(int i=0;i<map_count;i++){
    auto one = map.at(i);
    //   qDebug()<<".";
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
       //    qDebug()<<"?";
       }
    }
    */

    //---------------------------

func();
            qDebug()<<" ";

   mutex.unlock();
//   qDebug()<<"<-- StreamerContainer::thread_is_over ";
}

void StreamerContainer::on_timer()
{
    qDebug()<<"on_timer";
    for(auto one : map){


        if(one.data())
            if(one.data()->mm)
                if(one.data()->mm->runner)
                    if(
                            //    one.data()->mm->runner->getVideoHeight()>480&&
                            //      one.data()->mm->runner->getVideoWidth()>640&&
                            //        one->mode==2 &&
                            one->getFollowers()==0 &&
                            one.data()->mm->runner->m_running==Runner::Mode::Play
                            ){

                        auto now = QDateTime::currentDateTime();
                        auto diff = one->no_followers.secsTo(now);
                        //   qDebug()<<"этот поток "<<one.data()->getURL()<<" хранится уже "<<diff<<" сек";
                        if(diff>2){
                            qDebug()<<" потоку "<<one.data()->get_m_index()<<" сбрасываем save";
                            one->setSave(false);
                            one->followers_dec();
                        }
                    }
    }
}


