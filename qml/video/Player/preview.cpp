#include "preview.h"
#include <qdebug.h>
#include <qpainter.h>

Preview::Preview()
{
    qDebug()<<"Preview::Preview()";
    container=PreviewContainerAccesser::get();


}

QString Preview::url()
{
   return url_;
}

void Preview::set_url(QString url)
{
    url_=url;
    maker.clear();
    maker=container->get_previewmaker(url);
    if(maker){
        connect(maker.data(),SIGNAL(image()),this,SLOT(get_image()));
    }
    update();
}

void Preview::paint(QPainter *painter)
{
    if(maker)
        if(maker.data())

    {
    painter->drawImage(QRect(0, 0, this->width(), this->height()), maker->get_image());
    }
}

void Preview::get_image()
{
    qDebug()<<"Preview::get_image() "<<url_;
}

