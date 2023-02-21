#include "model.h"

 QMap<QString,QSharedPointer<Wall>>  Model::mdl;

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

        qDebug()<<"видеоэкран: "<< vid;

        auto wall = mdl.value(vid);

        qDebug()<<"количество страниц: "<<wall.data()->count();


        for(auto one : wall.data()->list){

            qDebug()<<"страница";
             qDebug()<<"количество камер: "<<one->list.count();
             for(auto camera : one->list){
                 qDebug()<<"камера";
             }

        }
        qDebug()<<"<--";
    }
}

int Model::get_pages_count()
{
    qDebug()<<"Model::get_pages_count(QString vid) -->";
    qDebug()<<"vid: "<<vid;

    if(!mdl.value(vid))
       add_vid();

    int count = mdl.value(vid).data()->count();
    qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
    qDebug()<<"<-- Model::get_pages_count(QString vid)";
    return count;
}

bool Model::add_page()
{
qDebug()<<"на видеостене "<<vid<<" добавляем страницу ";
    auto list = mdl.value(vid);

    list->add_page(QSharedPointer<Page>::create());

    return true;
}

bool Model::delete_page( int page)
{
    qDebug()<<"на видеостене "<<vid<<" удаляем страницу ";
    return mdl.value(vid)->delete_page(page);
}

bool Model::to_page( int page)
{
    qDebug()<<"на видеостене "<<vid<<" переходим на страницу "<<page;

     if(!mdl.value(vid))
        add_vid();

    if(page<0 || page>=mdl.value(vid).data()->count()){
        qDebug()<<"у видеостены "<<vid<<" нет cтраницы c номером "<<page;
        int count = mdl.value(vid).data()->count();
        qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
        return false;

    }
    return true;
    qDebug()<<"Переход на видеостене "<<vid<<" на страницу "<<page;
}

bool Model::add_camera( int page)
{
 //   qDebug()<<""
 //  return mdl.value(vid)->add_camera(page);

    return false;

}

void Model::setVid(const QString src)
{
    vid = src;
}

bool Model::add_vid()
{
    if(mdl.value(vid))
        return true;

        qDebug()<<"добавляю "<<vid;
        auto list =QSharedPointer<Wall>::create();
        mdl.insert(vid,list);

        return true;


}

Wall::Wall(QObject *parent)
{

}

bool Wall::add_page(QSharedPointer<Page> page)
{

 list.append(page);
 return true;
}

bool Wall::delete_page(int page)
{
      qDebug()<<"удаляем страницу "<<page;
 if(page<0 || page>=list.count()){
     qDebug()<<"нет старницы с таким номером "<<page;
          return false;
 }
 list.removeAt(page);
 return true;
}

bool Wall::add_camera( int page)
{

}

Wall::~Wall()
{
 qDebug()<<"Wall::~Wall()";
}

Page::Page(QObject *parent)
{
    qDebug()<<"Страница создана ";
}

Page::~Page()
{
    qDebug()<<"Страница удалена";
}

Camera::Camera(QObject *parent)
{
    qDebug()<<"Камера добавлена";
}

Camera::~Camera()
{
    qDebug()<<"Камера удалена";
}
