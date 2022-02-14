#include "videoplayer.h"
#include <QPainter>
VideoPlayer::VideoPlayer(QQuickItem *parent):QQuickPaintedItem(parent)
{



    //m_player=new Container();
    m_starter=new Starter();
//    connect(m_player,SIGNAL(sig_GetOneFrame(QImage)),this,SLOT(slotGetOneFrame(QImage)));

 //   connect(this->m_player,SIGNAL((sig_GetOneFrame(QImage))),this,SLOT(slotGetOneFrame(QImage)));
    connect(this->m_starter->m_player,SIGNAL(new_frame()),this,SLOT(new_frame()));
    connect(this->m_starter->m_player,SIGNAL(lost_connection()),this,SLOT(lost_connection()));
    connect(this->m_starter->m_player,SIGNAL(playing()), this, SLOT(slot_playing()));
    connect(this->m_starter,SIGNAL(tick()), this, SLOT(clear_timer()));


    connect(&thread_starter, &QThread::started, m_starter, &Starter::run);
    connect(m_starter, &Starter::finished, &thread_starter, &QThread::terminate);

 //
    m_starter->moveToThread(&thread_starter);
    thread_starter.start();

    timer = new QTimer(this);

    connect(timer, SIGNAL(timeout()), this, SLOT(restart()));


   timer->start(200);
  //  timer->singleShot(200, this, SLOT(timeout()));
 //   QTimer::singleShot(200, this, SLOT(timeout()));
 //   m_player->start();

}


void VideoPlayer::paint(QPainter *painter)
{

 //  painter->setBrush(Qt::black);
 //   painter->drawRect(0, 0, this->width(), this->height()); // Сначала рисуем черным
    painter->drawImage(QRect(0, 0, this->width(), this->height()), mImage);


}

QString VideoPlayer::source() const
{
    return m_source;
}

void VideoPlayer::setSource(const QString source)
{
 //   qDebug()<<"setSource: "<<source;
    m_source=source;
  //  m_player->setRunning(false);
 //   m_player->set_URL(m_source);
  //  m_player->URL=m_source;
 //   m_player->setRunning(true);
    //   thread.start();
}


void VideoPlayer::start()
{
 //   qDebug()<<"start";

  //  qDebug()<<"starter is running? "<<thread_starter.isRunning()<<"; is finished? "<<thread_starter.isFinished();



    m_starter->setURL(m_source);

    m_starter->setStep(0);



}

void VideoPlayer::stop()
{
 //   qDebug()<<"starter is running? "<<thread_starter.isRunning()<<"; is finished? "<<thread_starter.isFinished();

    m_starter->setStep(201);

}

void VideoPlayer::check()
{
 //   qDebug()<<" running: "<<m_starter->m_thread.isRunning()<<" ;finished: "<<m_starter->m_thread.isFinished();
}

void VideoPlayer::shot()
{
  //  qDebug()<<"starter is running? "<<thread_starter.isRunning()<<"; is finished? "<<thread_starter.isFinished();

    m_starter->setURL(m_source);



    m_starter->setStep(0);



}

void VideoPlayer::onWidthChanged(){
//qDebug()<<width();
update();
}

void VideoPlayer::onheightChanged(){
//qDebug()<<height();
update();
}

void VideoPlayer::timeout()
{
 //   qDebug()<<"---------------  timeout";
    timer->stop();
   // m_player->m_thread.quit();



}

void VideoPlayer::lost_connection()
{

mImage=QImage(":/qml/video/no_signal.jpeg");
//qDebug()<<mImage.size();
this->update();
timer->stop();
}

void VideoPlayer::slot_playing()
{

    emit playing();

}

void VideoPlayer::restart()
{
    timer->stop();

 //   thread_starter.quit();
 //   thread_starter.exit();
    thread_starter.terminate();
    while(!thread_starter.isFinished()){
   //     qDebug()<<thread_starter.isRunning()<<" "<<thread_starter.isFinished();
        thread_starter.quit();
        thread_starter.exit();
        thread_starter.terminate();


    }
   // qDebug()<<"thread_master is finished";


    thread_starter.start();
    timer->start();

}

void VideoPlayer::clear_timer()
{

    timer->start();
}

void VideoPlayer::new_frame()
{

    mImage = m_starter->m_player->img;

    this->update();
    timer->stop();
    timer->start(1000);

}
