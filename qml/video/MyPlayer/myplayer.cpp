#include "myplayer.h"
#include <QDebug>




MyPlayer::MyPlayer(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    qDebug()<<"[MyPlayer]";
    player = new QMediaPlayer();
    probe = new QVideoProbe;

    connect(probe, SIGNAL(videoFrameProbed(QVideoFrame)), this, SLOT(processFrame(QVideoFrame)));

    probe->setSource(player); // Returns true, hopefully.

   player->setMedia(QUrl("rtsp://root:root@192.168.0.187:50554/hosts/ASTRA17/DeviceIpint.1/SourceEndpoint.video:0:0"));
   player->play();



}

void MyPlayer::processFrame(const QVideoFrame &frame) {

    if (frame.isValid()) {

        QVideoFrame replica = frame;
           replica.map(QAbstractVideoBuffer::ReadOnly);

           qDebug() << std::boolalpha << frame.isMapped()   << "\n";
           qDebug() << std::boolalpha << replica.isMapped() << "\n";
           qDebug()<<"                                         replica.pixelFormat() "<<replica.pixelFormat();
           qDebug()<<"QVideoFrame::imageFormatFromPixelFormat(replica.pixelFormat()) "<<QVideoFrame::imageFormatFromPixelFormat(replica.pixelFormat());


          QImage image( replica.bits(), replica.width(),
                         replica.height(), replica.bytesPerLine(),
                         QVideoFrame::imageFormatFromPixelFormat(replica.pixelFormat()) );

           qDebug() << replica.width() << " " << replica.height() << "\n";
           qDebug() << frame.width()   << " " << frame.height()   << "\n";
           qDebug() << image.width()   << " " << image.height()   << "\n";

           qDebug() << frame.pixelFormat() << "\n";
           qDebug() << QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat()) << "\n";

    qDebug()<<image.size();

    img = image;

    this->update();


    }else{
         qDebug()<<"is NOT valid";
        }
}

void MyPlayer::paint(QPainter *painter)
{
  //  qDebug()<<"paint";
     // painter->setBrush(Qt::black);
    // painter->drawRect(0, 0, this->width(), this->height()); // Сначала рисуем черным
      painter->drawImage(QRect(0, 0, this->width(), this->height()), img);

}

QString MyPlayer::source() const
{
    return m_source;
}

void MyPlayer::setSource(const QString source)
{
    qDebug()<<"setSource "<<source;
    m_source=source;
}

void MyPlayer::start()
{
   qDebug()<<"vm start";
}

void MyPlayer::stop()
{
   qDebug()<<"vm stop";
}

void MyPlayer::check()
{
   qDebug()<<"vm check";
}

void MyPlayer::shot()
{
   qDebug()<<"vm shot";
}


