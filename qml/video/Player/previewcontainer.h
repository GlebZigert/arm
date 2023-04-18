#ifndef PREVIEWCONTAINER_H
#define PREVIEWCONTAINER_H

#include<QSharedPointer>
#include "previewmaker.h"



class PreviewContainer
{
public:
    PreviewContainer();
    QSharedPointer<PreviewMaker> get_previewmaker(QString url);

private:
    QMap<QString,QSharedPointer<PreviewMaker>> map;
};



#endif // PREVIEWCONTAINER_H
