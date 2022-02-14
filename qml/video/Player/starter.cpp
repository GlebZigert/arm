#include "starter.h"
#include "QDebug"

Starter::Starter(QObject *parent) : QObject(parent)
{
    m_player=new FFPlayer();

    connect(&m_thread, &QThread::started, m_player, &FFPlayer::run);
    connect(m_player, &FFPlayer::finished, &m_thread, &QThread::terminate);

    m_player->moveToThread(&m_thread);


    m_step=-1;



}

void Starter::run()
{
//    qDebug()<<"starter run";




    bool start=true;

    /*
    if (player==nullptr){
        qDebug()<<"need point to player";
        start=false;
    }

    */




    m_step=-1;
    prev=0;
    //bool res=false;
    int i=0;
    QString current_URL;
    while(1){
int val=step();
   //    qDebug()<<m_step<<" URL "<<m_URL;

        if((-1==val)||(3==val)||(103==val)||(200==val))
        if(prev!=val){
 //   qDebug()<<"step "<<m_step;

        prev=m_step;
        current_URL=m_URL;
        }

        if(i>1000000){
 //        qDebug()<<m_step;
         i=0;
         emit tick();

        }
           i++;

        switch (val) {

        case 0:
       //     if(m_URL!=""){
       //     qDebug()<<"m_thread.isRunnin? "<<m_thread.isRunning();
       //     qDebug()<<"Отдаем команду остановить поток";
            m_player->setRunning(mode::turnOff);
            m_step=1;
      //      }
        break;

        case 1:
          //  qDebug()<<"Ждем остановку потока";
         //   qDebug()<<player->thread.isRunning();
            if(m_thread.isRunning()==false){
                qDebug()<<"Поток остановлен";
                m_step=2;
            }else{
                m_thread.quit();
                m_thread.exit();
                m_thread.terminate();
              //  m_step=2;
            }


        break;

        case 2:
      //      qDebug()<<"Задаю новый URL: "<<current_URL;

     //       qDebug()<<"URL: "<<current_URL;

           m_player->URL=m_URL;
           m_player->setRunning(mode::Streaming);
        //   qDebug()<<"is running? "<<m_thread.isRunning();
         //  qDebug()<<"is finished? "<<m_thread.isFinished();
           m_thread.start();

            m_step=3;

        break;

        case 3:

            if(m_thread.isRunning()==false){
            //    qDebug()<<"-------- перезапускаю поток";
                m_step=0;
            }

        break;

//------------------------------------------------------------

        case 100:
            if(m_thread.isRunning()==true){
       //     if(m_URL!=""){
       //     qDebug()<<"m_thread.isRunnin? "<<m_thread.isRunning();
       //     qDebug()<<"Отдаем команду остановить поток";
            m_player->setRunning(mode::turnOff);
            m_step=101;
           }else{
                m_step=102;
            }

        break;

        case 101:
          //  qDebug()<<"Ждем остановку потока";
         //   qDebug()<<player->thread.isRunning();
            if(m_thread.isRunning()==false)
                m_step=102;
            else{
                m_thread.quit();
                m_thread.exit();
                m_thread.terminate();
              //  m_step=2;
            }


        break;
//test!!
        case 102:
     //       qDebug()<<"Задаю новый URL: "<<current_URL;

     //       qDebug()<<"URL: "<<current_URL;

           m_player->URL=current_URL;
           m_player->setRunning(mode::Snapshot);
           m_thread.start();

            m_step=103;

        break;

        case 103:

        break;
//------------------------------------------------------------

        case 201:
            if(m_thread.isRunning()==false)
                m_step=200;
            else
                m_player->setRunning(mode::turnOff);
        break;




        }



    }


//    qDebug("[starter finished]");
    emit finished();
}

int Starter::step() const
{
    return m_step;
}

void Starter::setStep(int value)
{
    m_step=value;
//    qDebug()<<"m_step: "<<m_step<<" prev "<<prev;

    emit stepChanged(value);

}

QString Starter::URL() const
{
    return m_URL;
}

void Starter::setURL(QString value)
{
    m_URL=value;
    emit URLChanged(value);

}

void Starter::new_frame()
{

}

void Starter::slot_timeout()
{
//    qDebug()<<"timeout";
}
