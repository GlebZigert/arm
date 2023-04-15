#include "StreamerContainer.h"
static std::mutex mutex;




void StreamerContainer::on_timer()
{
timer.stop();
func();

//timer.start(1000);
}
void StreamerContainer::func(){
    int free=0;
    int play=0;
    qDebug()<<" ";
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count()<<" -->";
     qDebug()<<" ";
bool flag=true;
        for(auto one : map){


            QString sstr="";

            if(one.data()->runner){
            if(one.data()->runner->get_m_running()!=Runner::Mode::Free){
                free++;
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

            }
            }


            if(one.data()->runner){
            qDebug()<<"runner: "<<one.data()->runner->get_m_index()
                   <<" mode: "<<one.data()->runner->get_state()
                     <<"Подписчики: "<<one.data()->getFollowers()
                    <<"Хранится: "<<one.data()->getSave()
                    <<sstr<<" "//<<one.data()->runner->URL
                       ;}else{
                qDebug()<<"no runner";

            }



        //    qDebug()<<one.data()->start_time.toString()<<" "<<one->start_time.secsTo(QDateTime::currentDateTime())<<" сек";
        //    qDebug()<<"подписчики: "<<one.data()->getFollowers();

            if(one.data()->getFollowers()==0){
         //       qDebug()<<"без подписчиков уже "<<one->no_followers.secsTo(QDateTime::currentDateTime())<<" сек";
            }else{
        //    qDebug()<<"Свежая подписка: "<<one->frash_follower_time.secsTo(QDateTime::currentDateTime())<<" сек";

            }

            qDebug()<<"Хранится: "<<one.data()->getSave()
            <<"runner завершен:" <<one.data()->runner->thread()->isFinished()
            <<"mode: " <<one.data()->runner->get_state()
            <<"Finished: " <<one.data()->thread->isFinished()
            <<"Running : " <<one.data()->thread->isRunning();


/*
            if(one.data()->runner->URL==""){
                one->stop();
            }
            */
            if(one.data())
                     if(one.data()->runner)
                         if(one.data()->runner->get_m_running()==Runner::Mode::Free){
                             free++;
                         }


    if(one.data())
             if(one.data()->runner)
        if(
            //    one.data()->runner->getVideoHeight()>480&&
            //      one.data()->runner->getVideoWidth()>640&&
        //        one->mode==2 &&
            one.data()->getFollowers()==0 &&
                one.data()->runner->get_m_running()==Runner::Mode::Play&&
                one.data()->runner->getVideoHeight()>600&&
                  one.data()->runner->getVideoWidth()>800
            ){

            auto now = QDateTime::currentDateTime();
                auto diff = one.data()->no_followers.secsTo(now);
         //   qDebug()<<"этот поток "<<one.data()->getURL()<<" хранится уже "<<diff<<" сек";
            if(diff>2){
             //   qDebug()<<"h w "<<one->runner->getVideoHeight()<<" "<<one->runner->getVideoWidth();
                qDebug()<<" потоку "<<one.data()->get_m_index()<<" сбрасываем save";
                one.data()->setSave(false);
                one.data()->stop();
            }
        }
      }



        QList<QSharedPointer<Streamer>>::iterator it = map.begin();
        while(it != map.end()){
            if(it->data()->runner){
            if(it->data()->runner->get_m_running() == Runner::Mode::Exit &&
                    it->data()->thread->isFinished()&&
                    !it->data()->thread->isRunning()
                    ){
                    it = map.erase(it);
        }else{
                ++it;
            }
            }
        }
// qDebug()<<"4";
        qDebug()<<" ";
        qDebug()<<QDateTime::currentDateTime()<<" <<--"<< "Потоки: "<<map.count()<<" свободных "<<free;
         qDebug()<<" ";


}

void StreamerContainer::show()
{
    int free=0;
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

            qDebug()<<"тредов     создано: "<<one.data()->created<<" удалено: "
                   <<one.data()->deleted<<" живут: "
                  <<one.data()->created-one.data()->deleted;

            if(one.data()->runner){
                qDebug()<<"раннеров  создано: "<<one.data()->runner->created<<" удалено: "
                       <<one.data()->runner->deleted<<" живут: "
                      <<one.data()->runner->created-one.data()->runner->deleted;

                qDebug()<<"кодеки: открыто "<<one.data()->runner->av_codec_open<<" yне открылись: "
                       <<one.data()->runner->av_codec_not_open<<" закрыто: "
                      <<one.data()->runner->av_codec_close<<" не закрытых: "
                     <<one.data()->runner->av_codec_open+one.data()->runner->av_codec_not_open-one.data()->runner->av_codec_close;
            }
        }

        QString sstr="";

        if(one.data()->runner){

            if(one.data()->runner->get_m_running()==Runner::Mode::Free){
                free++;
            }

            if(one.data()->runner->get_m_running()!=Runner::Mode::Free){
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

            }
        }

        if(one.data()->runner){
            qDebug()<<"runner: "<<one.data()->runner->get_m_index()
                   <<" mode: "<<one.data()->runner->get_state()
                  <<"Подписчики: "<<one.data()->getFollowers()
                 <<"Хранится: "<<one.data()->getSave()
                <<sstr<<" "<<one.data()->runner->URL
                  ;}else{
            qDebug()<<"no runner";
        }
    }
    qDebug()<<" ";
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count()<<" свободных: "<<free;
    qDebug()<<" ";
}


StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{
qDebug()<<"StreamerContainer::StreamerContainer";



/*
connect(timer.data(),
        &QTimer::timeout
        ,
        [=](){qDebug()<<".";});
*/
    connect(&timer,
            SIGNAL(timeout()),
            this,
            SLOT(on_timer()));



    timer.start(1000);
    qDebug()<<"timer: "<<timer.isActive()<<" "<<timer.isSingleShot();

}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::StreamType type)
{
    timer.stop();
func();
   qDebug()<<"--> StreamerContainer::start "<<url <<" "<<type;
 //   qDebug()<<"mode "<<mode;
    mutex.lock();


    QSharedPointer<Streamer> streamer=nullptr;

  //  if(mode==Runner::Mode::LiveStreaming){
    streamer = find(url,type);


  //  }


  //  }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(url,type);
    //    connect(streamer.data(),SIGNAL(signal_thread_is_over()),&StreamerContainer::thread_is_over));
        if(streamer){

            map.append(streamer);

        //    qDebug()<<"добавляем в контейер "<<url;

         //   streamer.data()->runner->URL=url;
         //   streamer.data()->runner->frash_stream=true;


        }
        else{
         //   qDebug()<<"ffFai;l";

        }

    }







       //      qDebug()<<" ";
              mutex.unlock();

// qDebug()<<"<-- StreamerContainer::start "<<url;
              timer.start(100);
    if(streamer){
        return streamer;
}

    return nullptr;



}

void StreamerContainer::delete_free_streamers()
{
  //  qDebug()<<"delete all free streamers";
    QList<QSharedPointer<Streamer>>::iterator it = map.begin();
    while(it != map.end()){
        if(it->data()->runner)
        if(it->data()->runner->get_m_running()==Runner::Mode::Free){

                it->data()->runner->set_m_running(Runner::Mode::Exit);

            }

           ++it;
        }


}

QSharedPointer<Streamer> StreamerContainer::find(QString url,Runner::StreamType type)
{
  //  qDebug()<<"--> StreamerContainer::find "<<url;

    for(auto one : map){
        if(one.data()->runner->URL==url
                &&
                (one.data()->runner->get_m_running()==Runner::Mode::Play||
                 one.data()->runner->get_m_running()==Runner::Mode::Hold
                 )
                ){
            one->setSave(false);


            mutex.unlock();
            qDebug()<<"<-- StreamerContainer::find [0] "<<one.data()->get_m_index();
            return one;
        }
    }

    for(auto one : map){

        if(one.data()->runner)
        if(one.data()->runner->get_m_running()==Runner::Mode::Free){
         //   one.data()->runner->m_running=Runner::Mode::Prepare;
         //   qDebug()<<"нашел свободный "<<one.data()->get_m_index();
         //   one->setSave(false);
            one.data()->runner->set_m_running(Runner::Mode::Prepare);
            one.data()->runner->URL=url;
            one.data()->runner->streamType=type;
            one.data()->runner->frash_stream=true;


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
          if(it->data()->runner)
          if(it->data()->mode == Runner::Mode::TurnOff &&
                  it->data()->thread->isFinished()&&
                  !it->data()->thread->isRunning()
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
               one.data()->thread->isFinished()&&
               !one.data()->thread->isRunning()
               )

               {
           qDebug()<<"map.removeOne "<<one.data()->thread->isFinished()<<" "<<one.data()->thread->isRunning()<<" "<<one->getURL()<<" "<<one->get_m_index();
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




