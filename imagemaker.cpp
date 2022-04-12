#include "imagemaker.h"

imageMaker::imageMaker(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
    manager = new QNetworkAccessManager();
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    manager->get(QNetworkRequest(QUrl(m_URL)));

    int width =290;
     int height = 180;
     int offset = 25;
     int w = 400;
     int h = 200;

     QImage image(QSize(width,height),QImage::Format_RGB32);



     QPainter painter(&image);



     painter.setBrush(QBrush(Qt::green));

     painter.fillRect(QRectF(0,0,width,height),Qt::green);

     painter.fillRect(QRectF(0,0,290,180),Qt::blue);

     painter.fillRect(QRectF(10,10,270,160),Qt::white);

     this->m_image=image;

     update();

}

void imageMaker::test()
{
 qDebug()<<"test";
}

QImage imageMaker::createImage(QString text, QString path, QString imageName, QColor aColor)
{
    int width = 1024;
     int height = 768;
     int offset = 25;
     int w = 400;
     int h = 200;

     QImage image(QSize(width,height),QImage::Format_RGB32);

     QPainter painter(&image);

     painter.setBrush(QBrush(aColor));

     painter.fillRect(QRectF(0,0,width,height),Qt::white);


     drawText(&painter,150,50,150,40,"test12345");
   //  QRect aRect = QRect( (width-w)/2, (height-h)/2, w, h );
   //  QRect aRectOffset = QRect( (width-w+offset)/2, (height-h+offset)/2, w-(offset/2), h-(offset/2) );

   //  painter.fillRect(QRect(aRect),Qt::white);

   //  painter.setPen(QPen(Qt::green));

   //  painter.setFont(QFont( "Courier", 20) );

   //  painter.drawText(QRect(aRectOffset),text);

     QDir aDir = QDir(path);
     qDebug()<<"dir: "<<aDir.path();

     if ( aDir.mkpath(path) ){
         qDebug()<<"[1]";
          image.save(path + "/" + imageName);

     }
     else{
         qDebug()<<"[2]";
          image.save(imageName);
     }
     return image;


}

QImage imageMaker::createImage_1(QString name, QString suname)
{
    int width = 1024;
     int height = 768;
     int offset = 25;
     int w = 400;
     int h = 200;

     QImage image(QSize(width,height),QImage::Format_RGB32);

     QPainter painter(&image);

     painter.setBrush(QBrush(Qt::blue));

     painter.fillRect(QRectF(0,0,width,height),Qt::white);


     drawText(&painter,150,50,150,40,name);

     drawText(&painter,150,100,150,40,suname);

     return image;
}

QImage imageMaker::createImage_2(QImage photo, QString name, QString suname)
{
    int width =290;
     int height = 180;
     int offset = 25;
     int w = 400;
     int h = 200;

     QImage image(QSize(width,height),QImage::Format_RGB32);



     QPainter painter(&image);



     painter.setBrush(QBrush(Qt::green));

     painter.fillRect(QRectF(0,0,width,height),Qt::green);

     painter.fillRect(QRectF(0,0,290,180),Qt::blue);

     painter.fillRect(QRectF(10,10,270,160),Qt::white);
 //   painter.drawRoundedRect(QRectF(0,0,width,height), 20.0, 15.0);


     drawText(&painter,155,40,115,40,name);

     drawText(&painter,155,80,115,40,suname);

     painter.drawImage(QRectF(10,10,145,160),photo);

     this->m_image=image;

     QString path="C:/workspace/QPainter/untitled2/";
     QString imageName="user.jpeg";

     QDir aDir = QDir(path);
     qDebug()<<"dir: "<<aDir.path();

     if ( aDir.mkpath(path) ){
         qDebug()<<"[1]";
         QString dest=path + imageName;

          bool res=image.save(path + imageName);
          qDebug()<<dest<<" "<<res;

     }
     else{
         qDebug()<<"[2]";
           bool res=image.save(imageName);
           qDebug()<<res;

     }

     return image;
}

QImage imageMaker::createImage_3(QString path_photo, QString name, QString suname)
{
    qDebug()<<"createImage_3";
    int width =290;
     int height = 180;
     int offset = 25;
     int w = 400;
     int h = 200;

     QImage image(QSize(width,height),QImage::Format_RGB32);



     QPainter painter(&image);



     painter.setBrush(QBrush(Qt::green));

     painter.fillRect(QRectF(0,0,width,height),Qt::green);

     painter.fillRect(QRectF(0,0,290,180),Qt::blue);

     painter.fillRect(QRectF(10,10,270,160),Qt::white);
 //   painter.drawRoundedRect(QRectF(0,0,width,height), 20.0, 15.0);


     drawText(&painter,155,40,115,40,name);

     drawText(&painter,155,80,115,40,suname);

     qDebug()<<"path photo: "<<path_photo;
     QString url = path_photo;
     QPixmap img(url);
     QImage photo=img.toImage();

     painter.drawImage(QRectF(10,10,145,160),photo);

     this->m_image=image;

     QString path="C:/workspace/QPainter/untitled2/";
     QString imageName="user.jpeg";

     QDir aDir = QDir(path);
     qDebug()<<"dir: "<<aDir.path();

     if ( aDir.mkpath(path) ){
         qDebug()<<"[1]";
         QString dest=path + imageName;

          bool res=image.save(path + imageName);
          qDebug()<<dest<<" "<<res;

     }
     else{
         qDebug()<<"[2]";
           bool res=image.save(imageName);
           qDebug()<<res;

     }

     update();

     return image;
}

void imageMaker::take_photo_from_url_and_set_name_and_surename(QString URL,QString name,QString surename)
{
    m_URL=URL;
    this->name=name;
    this->surename=surename;
     manager->get(QNetworkRequest(QUrl(m_URL)));
}

void imageMaker::printImage()
{
    qDebug()<<"printImage()";
    QPrinter printer;
    printer.setPrinterName("The printer");
    QPrintDialog dialog(&printer,nullptr);
    if(dialog.exec()==QDialog::Rejected) {
 qDebug()<<"FAIL";
        return;
}
    QPainter painter;
         painter.begin(&printer);

         painter.drawImage(QRectF(0,0,850,540),m_image);

         painter.end();

}

void imageMaker::paint(QPainter *painter)
{
    qDebug()<<"paint";
     painter->drawImage(QRect(0, 0, 290, 180), m_image);
}



void imageMaker::drawText(QPainter* painter,int x, int y, int w, int h, QString text)
{
    QRect aRect = QRect( x, y, w, h );
    QRect aRectOffset = QRect( x+5, y+5, w-10, h-10);

    painter->fillRect(QRect(aRect),Qt::white);

    painter->setPen(QPen(Qt::blue));

    painter->setFont(QFont( "Courier", 20) );

    painter->drawText(QRect(aRectOffset),text);
}

void imageMaker::replyFinished(QNetworkReply *reply)
{
    this->current.loadFromData(reply->readAll());
    if((this->current.isNull())){
        manager->get(QNetworkRequest(QUrl(m_URL)));
    }else{
        createImage_2(current,name,surename);
       update();
    }
}
