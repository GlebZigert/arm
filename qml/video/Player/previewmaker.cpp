#include "previewmaker.h"
#include <qdebug.h>

PreviewMaker::PreviewMaker()
{
qDebug()<<"Preview::Preview()";
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
