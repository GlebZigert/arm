#include "model.h"

 QMap<QString,QSharedPointer<QList<int>>> Model::mdl;

Model::Model()
{

}

QString Model::get_info()
{
    return "model for videowalls";
}

int Model::get_vid_count()
{
    return mdl.count();
}



void Model::show()
{
qDebug()<<"-->";
qDebug()<<"количество видеоэкранов: "<<mdl.count();

for(auto vid : mdl.keys()){

qDebug()<<"vid: "<< vid<<" "<<mdl.value(vid);

}
qDebug()<<"<--";

}

int Model::get_pages_count(QString vid)
{
    qDebug()<<"Model::get_pages_count(QString vid) -->";
    qDebug()<<"vid: "<<vid;

    if(!mdl.value(vid)){
        auto list =QSharedPointer<QList<int>>::create();
        mdl.insert(vid,list);
    }

    int count = mdl.value(vid).data()->count();
    qDebug()<<"count: "<<count;
    qDebug()<<"<-- Model::get_pages_count(QString vid)";
    return count;
}

Wall::~Wall()
{
 qDebug()<<"Wall::~Wall()";
}
