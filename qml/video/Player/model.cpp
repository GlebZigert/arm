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
        qDebug()<<"добавляю "<<vid;
        auto list =QSharedPointer<QList<int>>::create();
        mdl.insert(vid,list);
    }

    int count = mdl.value(vid).data()->count();
    qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
    qDebug()<<"<-- Model::get_pages_count(QString vid)";
    return count;
}

bool Model::to_page(QString vid, int page)
{
    qDebug()<<"на видеостене "<<vid<<" переходим на стариницу "<<page;

    if(!mdl.value(vid)){
        qDebug()<<"добавляю "<<vid;
        auto list =QSharedPointer<QList<int>>::create();
        mdl.insert(vid,list);
    }

    if(page<0 || page>=mdl.value(vid).data()->count()){
        qDebug()<<"у видеостены "<<vid<<" нет cтраницы c номером "<<page;
        int count = mdl.value(vid).data()->count();
        qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
        return false;

    }
    return true;
    qDebug()<<"Переход на видеостене "<<vid<<" на стариницу "<<page;
}

Wall::Wall(QObject *parent)
{

}

Wall::~Wall()
{
 qDebug()<<"Wall::~Wall()";
}
