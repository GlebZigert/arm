#include "StreamerContainer.h"
static std::mutex mutex;




void StreamerContainer::on_timer()
{
timer.stop();
func();
timer.start(200);

//timer.start(1000);
}

void StreamerContainer::on_start_timer()
{
    mutex.lock();
    start_timer.stop();
   qDebug()<<QTime::currentTime()<<" on_start_timer "<<start_map.size()<<" "<<queue.size();
    if(queue.size()==0){
        mutex.unlock();
        return;
    }
    qDebug()<<"--> start_map";
    for(auto index : start_map.keys()){
        qDebug()<<"vm_ind: "<<index
               <<" "<<start_map.value(index)->runner->get_m_index()
               <<" "<<start_map.value(index)->runner->URL;
    }
        qDebug()<<"<-- start_map";
  auto streamer=queue.dequeue();
  if(streamer){
      int key=start_map.key(streamer);
      start_map.remove(key);
      qDebug()<<"treamerContainer::on_start_timer start runner"<<streamer->runner->get_m_index();
  streamer->start();
  }
  if(queue.size()>0){
      start_timer.start(10);
  }
  mutex.unlock();
}
void StreamerContainer::add_for_start(QSharedPointer<Streamer> streamer,int index)
{


    qDebug()<<QTime::currentTime()<<" StreamerContainer::add_for_start"
            <<index<<" "
            <<" runner "<<streamer->runner->get_m_index()<<" "
            <<" "<<streamer->runner->get_state();
            qDebug()<<"очередь: "<<queue.size()<<" карта: "<<start_map.size();
    streamer->runner->set_m_running(Runner::Mode::Wait_for_start);
    if(start_map.contains(index)){

        qDebug()<<" "<<index<<" уже содержит "
               <<start_map.value(index)->runner->get_m_index()
               <<" "<<start_map.value(index)->runner->get_state()
              <<" "<<start_map.value(index)->runner->URL;
    }
    start_map.insert(index,streamer);
queue.enqueue(streamer);
start_timer.start(10);

}

void StreamerContainer::func(){
    int free=0;
    int play=0;
    //  qDebug()<<" ";
    //  qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count()<<" -->";
    //   qDebug()<<" ";
    bool fl=true;
    for(auto one : map){


        QString sstr="";

        if(one.data()->runner){
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
        /*
    if(flag==true){
            if(one.data()->runner){
            qDebug()<<"runner: "<<one.data()->runner->get_m_index()
                   <<" mode: "<<one.data()->runner->get_state()
                     <<"Подписчики: "<<one.data()->getFollowers()
                    <<" time: "<<one.data()->runner->time.secsTo(QDateTime::currentDateTime())
                    <<"Хранится: "<<one.data()->getSave()
                    <<sstr<<" "<<one.data()->runner->URL
                       ;}else{
                qDebug()<<"no runner";

            }
          }
*/


        //    qDebug()<<one.data()->start_time.toString()<<" "<<one->start_time.secsTo(QDateTime::currentDateTime())<<" сек";
        //    qDebug()<<"подписчики: "<<one.data()->getFollowers();

        if(one.data()->getFollowers()==0){
            //       qDebug()<<"без подписчиков уже "<<one->no_followers.secsTo(QDateTime::currentDateTime())<<" сек";
        }else{
            //    qDebug()<<"Свежая подписка: "<<one->frash_follower_time.secsTo(QDateTime::currentDateTime())<<" сек";

        }
        /*
            qDebug()<<"Хранится: "<<one.data()->getSave()
            <<"runner завершен:" <<one.data()->runner->thread()->isFinished()
            <<"mode: " <<one.data()->runner->get_state()
            <<"Finished: " <<one.data()->thread->isFinished()
            <<"Running : " <<one.data()->thread->isRunning();
*/

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
                        one.data()->getFollowers()==0 &&
                    (
                        one.data()->runner->get_m_running()==Runner::Mode::Play ||
                        one.data()->runner->get_m_running()==Runner::Mode::Hold ||
                        one.data()->runner->get_m_running()==Runner::Mode::Waiting
                        )
                        )
                {


                    if(one.data()->runner->getVideoHeight()>600&&
                       one.data()->runner->getVideoWidth()>800
                       ){

                        auto now = QDateTime::currentDateTime();
                        auto diff = one.data()->no_followers.secsTo(now);
                        //   qDebug()<<"этот поток "<<one.data()->getURL()<<" хранится уже "<<diff<<" сек";
                        if(diff>0){
                           // qDebug()<<"этот поток runner"<<one.data()->runner->get_m_index()<<" "<<one.data()->getURL()<<" хранится без подписчиков уже "<<diff<<" сек";
                         //   show();
                          //  qDebug()<<" потоку "<<one.data()->get_m_index()<<" сбрасываем save";
                            one.data()->setSave(false);
                            one.data()->stop();
                        }
                    }else{

                        auto now = QDateTime::currentDateTime();
                        auto diff = one.data()->no_followers.secsTo(now);
                    if(diff>5){
                        one->runner->go_to_low_mode=true;
                            }
                    }
                }

        if(one.data()->getFollowers()==0 &&
                one.data()->runner->get_m_running()==Runner::Mode::Lost
                ){
            auto now = QDateTime::currentDateTime();
            auto diff = one.data()->no_followers.secsTo(now);
            //   qDebug()<<"этот поток "<<one.data()->getURL()<<" хранится уже "<<diff<<" сек";
            if(diff>0){
                   //    qDebug()<<"этот поток "<<one.data()->getURL()<<" без подписчиков с обрывом связи "<<diff<<" сек";
                  //      show();
               // qDebug()<<" потоку "<<one.data()->get_m_index()<<" сбрасываем save";
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
    //     qDebug()<<" ";
    if(flag==true){



        flag=false;
        qDebug()<<" ";
        qDebug()<<QDateTime::currentDateTime()<<" <<--"<< "Потоки: "<<map.count()<<" свободных "<<free;
        qDebug()<<" ";
    }
    //      qDebug()<<" ";


}

void StreamerContainer::show()
{
    long max_frame_delay;
    long min_frame_delay;
    int free=0;
    qDebug()<<" ";
    qDebug()<<"время старта приложения: "<<start_dt;
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count();
    qDebug()<<" ";
    bool fl=true;
    for(auto one : map){
        if(fl){
            fl=false;
            qDebug()<<"стримеров создано: "<<one.data()->created<<" удалено: "
                   <<one.data()->deleted<<" живут: "
                  <<one.data()->created-one.data()->deleted;

            qDebug()<<"тредов     создано: "<<one.data()->created<<" удалено: "
                   <<one.data()->deleted<<" живут: "
                  <<one.data()->created-one.data()->deleted;

            if(one.data()->runner){

                max_frame_delay=one.data()->runner->getFrame_delay();
                min_frame_delay=one.data()->runner->getFrame_delay();

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

            long frame_delay=one.data()->runner->getFrame_delay();
            if(frame_delay>max_frame_delay){
                max_frame_delay=frame_delay;
            }
            if(frame_delay<min_frame_delay){
                min_frame_delay=frame_delay;
            }

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
          //     <<"settings: "<<one.data()->runner->get_count_settings()
         //     <<"frame_delay: "<<one.data()->runner->getFrame_delay();
                  ;}else{
            qDebug()<<"no runner";
        }
    }
    qDebug()<<" ";
    qDebug()<<QDateTime::currentDateTime()<< "Потоки: "<<map.count()<<" свободных: "<<free;
    qDebug()<<QDateTime::currentDateTime()<< "frame_delay: min: "<<min_frame_delay<<" max: "<<max_frame_delay;
    qDebug()<<" ";
}




StreamerContainer::StreamerContainer(QObject *parent) : QObject(parent)
{
qDebug()<<"StreamerContainer::StreamerContainer";

start_dt=QDateTime::currentDateTime();

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

    connect(&start_timer,
            SIGNAL(timeout()),
            this,
            SLOT(on_start_timer()));

    timer.start(1000);
    qDebug()<<"timer: "<<timer.isActive()<<" "<<timer.isSingleShot();

}

QSharedPointer<Streamer> StreamerContainer::start(QString url, Runner::StreamType type, int index)
{
  //  timer.stop();
  //  start_timer.stop();
//func();
  // qDebug()<<QTime::currentTime()<<" --> StreamerContainer::start "<<url <<" "<<type;
 //   qDebug()<<"mode "<<mode;
    mutex.lock();


    QSharedPointer<Streamer> streamer=nullptr;

  //  if(mode==Runner::Mode::LiveStreaming){
    streamer = find(url,type,index);


  //  }


  //  }

    if(!streamer){

        streamer=QSharedPointer<Streamer>::create(url,type);
    //    connect(streamer.data(),SIGNAL(signal_thread_is_over()),&StreamerContainer::thread_is_over));
        if(streamer){

            map.append(streamer);
            add_for_start(streamer,index);
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
              flag=true;
              timer.start(100);
    if(streamer){

            // qDebug()<<QTime::currentTime()<<" <-- StreamerContainer::start "<<"[1]  runner "<<streamer->runner->get_m_index();


        return streamer;
        }

//qDebug()<<QTime::currentTime()<<" <-- StreamerContainer::start "<<"[2]";
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

QSharedPointer<Streamer> StreamerContainer::find(QString url,Runner::StreamType type, int index)
{
 //   qDebug()<<"--> StreamerContainer::find "<<url;
    QSharedPointer<Streamer> wanted;
    QSharedPointer<Streamer> ready;
    QSharedPointer<Streamer> free;




    for(auto one : map){
        if(one.data()->runner->URL==url)
                {

             if(one.data()->runner->get_m_running()==Runner::Mode::Lost){


             }else{

                             ready = one;

                             if(ready->runner->get_m_running()==Runner::Mode::Free){
                              //    qDebug()<<"<..";
                              //   ready.data()->runner->set_m_running(Runner::Mode::Prepare);
                              //    qDebug()<<"<..";
                                 ready.data()->runner->streamType=type;
                               //   qDebug()<<"<..";
                                 ready.data()->runner->frash_stream=true;
                               //   qDebug()<<"<..";

                             }

                             if(ready->runner->get_m_running()==Runner::Mode::Low){

                                 ready->runner->return_from_low_mode=true;
                             }
                  //qDebug()<<"<..";

                             break;

             }


        }
        if(one.data()->runner->get_m_running()==Runner::Mode::Free){
         //   one.data()->runner->m_running=Runner::Mode::Prepare;
         //   qDebug()<<"нашел свободный "<<one.data()->get_m_index();
         //   one->setSave(false);
/*
            one.data()->runner->set_m_running(Runner::Mode::Prepare);
            one.data()->runner->URL=url;
            one.data()->runner->streamType=type;
            one.data()->runner->frash_stream=true;
*/



            free = one;
            break;
        }
    }

    if(ready){
        wanted=ready;
        qDebug()<<"<-- StreamerContainer::find [0] runner "<<wanted.data()->get_m_index();
    }else{

        if(start_map.contains(index)){

            auto streamer = start_map.value(index);
            qDebug()<<" "<<index<<" уже содержит "
                   <<streamer->runner->get_m_index()
                  <<" "<<streamer->runner->URL;
            qDebug()<<"очередь: "<<queue.size()<<" карта: "<<start_map.size();

            streamer->runner->URL=url;
            streamer->runner->streamType=type;
            qDebug()<<"<-- StreamerContainer::find [3] runner "<<streamer->get_m_index();



           wanted=streamer;
        }

        if(!wanted){

            if(free){
               wanted=free;
    qDebug()<<"<-- StreamerContainer::find [1] runner "<<wanted.data()->get_m_index();
               free.data()->runner->URL=url;
               free.data()->runner->streamType=type;

                add_for_start(free, index);
            //   free.data()->runner->frash_stream=true;

           }
        }

    }

    /*
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
      //      qDebug()<<"<-- StreamerContainer::find [1] "<<one.data()->get_m_index();
            return one;
        }
    }
    */
     mutex.unlock();
    if(wanted){
        return wanted;
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




