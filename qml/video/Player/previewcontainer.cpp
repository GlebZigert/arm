#include "previewcontainer.h"
#include <QDebug>
PreviewContainer::PreviewContainer()
{

}

QSharedPointer<PreviewMaker> PreviewContainer::get_previewmaker(QString url)
{
   // qDebug()<<"PreviewContainer::get_previewmaker(QString url) "<<url;
    if(map.contains(url)){
    //    qDebug()<<"PreviewContainer::get_previewmaker [0]";
        return map.value(url);
    }

    QSharedPointer<PreviewMaker> maker = QSharedPointer<PreviewMaker>::create(url);
    map.insert(url,maker);
  //  qDebug()<<"PreviewContainer::get_previewmaker [1]";
    return maker;

}
