#include "preview.h"
#include <qdebug.h>
#include <qpainter.h>

Preview::Preview()
{
    qDebug()<<"Preview::Preview()";
}

int Preview::cid()
{
   return cid_;
}

void Preview::set_cid(int cid)
{
    cid_=cid;
}

void Preview::paint(QPainter *painter)
{

}

