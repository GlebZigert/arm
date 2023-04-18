#include "previewmaker.h"
#include <qdebug.h>

QImage PreviewMaker::get_image()
{
    return img;
}

PreviewMaker::PreviewMaker(QString url)
{
    img=QImage();
qDebug()<<"PreviewMaker::PreviewMaker(QString url) : "<<url;
    container = StreamerContainerAccesser::get();
    current=container->start(url,Runner::StreamType::Streaming);
    if(current){

        data = current.data()->getData();
        connect(current.data(),SIGNAL(frame(QString)),this,SLOT(frame(QString)));
    }


}

void PreviewMaker::start(int cid,QString url)
{
qDebug()<<"Preview::start "<<cid<<" "<<url;
}



QString PreviewMaker::url() const
{
    return url_;
}

void PreviewMaker::set_url(const QString url)
{
    url_=url;
}

int PreviewMaker::cid()
{
   return cid_;
}

void PreviewMaker::set_cid(int cid)
{
    cid_=cid;
}

void PreviewMaker::frame(QString URL)
{
    qDebug()<<"PreviewMaker::frame(QString URL) : "<<URL;
    if(flag){
        flag=false;
        if(current)
        if(current.data())
        {
    data = current.data()->getData();
        if(data!=NULL){
            int w = current.data()->getW();
            int h = current.data()->getH();
            img=QImage(data->data[0],
                       w,
                       h,
                       QImage::Format_RGB32);
            emit image();
        }
        }
    }
}
