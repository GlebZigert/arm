#include "model.h"

 QMap<QString,QSharedPointer<Wall>>  Model::mdl;

 int Page::uid = 0;
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

            qDebug()<<"масштаб: "<<one->current_scale();
             qDebug()<<"количество камер: "<<one->count();
             auto map = one->get_map();
             for(auto uid : map.keys()){
                 qDebug()<<uid;
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

    mdl.value(vid)->setCurrent_page(page);
    qDebug()<<"Переход на видеостене "<<vid<<" на страницу "<<page;
}

int Model::current_page()
{
    return mdl.value(vid)->getCurrent_page();
}

bool Model::add_camera()
{
 //   qDebug()<<""
   return mdl.value(vid)->add_camera();

    return false;

}

void Model::next_scale()
{
    mdl.value(vid)->next_scale();
}

int Model::current_scale()
{
    if(!mdl.value(vid))
       add_vid();
    return mdl.value(vid)->current_scale();


}

int Model::get_uid_at(int i)
{
   return mdl.value(vid)->get_uid_at(i);
}

int Model::get_cid_at(int i)
{
   return mdl.value(vid)->get_uid_at(i);
}

QString Model::get_url_at(int i)
{
   return mdl.value(vid)->get_url_at(i);
}

bool Model::get_alarm_at(int i)
{
    return mdl.value(vid)->get_uid_at(i);
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
current_page=-1;
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

bool Wall::add_camera()
{
    qDebug()<<"Добавляем камеру ";

if(current_page<0||current_page>=list.count())
    return false;

 auto page = list.at(current_page);

 if(!page){
      qDebug()<<"нет страницы с таким номером "<<page;
     return false;
 }

return page->add_camera();



//page->list.insert(uid++,QSharedPointer<Camera>::create());

}

void Wall::next_scale()
{
    if(current_page<0 || current_page>=list.count())
        return;

 auto page = list.at(current_page);
 page->next_scale();
}

int Wall::current_scale()
{




     if(current_page<0 || current_page>=list.count())
         return -1;

    if(!list.at(current_page))
        return -1;

    return list.at(current_page)->current_scale();

}

Wall::~Wall()
{
    qDebug()<<"Wall::~Wall()";
}

int Wall::getCurrent_page() const
{
    return current_page;
}

void Wall::setCurrent_page(int newCurrent_page)
{
    current_page = newCurrent_page;
}

int Wall::get_uid_at(int i)
{

    return -1;

}

int Wall::get_cid_at(int i)
{
    return -1;
}

QString Wall::get_url_at(int i)
{
    return "";
}

bool Wall::get_alarm_at(int i)
{
    return false;
}

Page::Page(QObject *parent)
{
    qDebug()<<"Страница создана ";
    scale=1;
}

bool Page::add_camera()
{
    map.insert(uid++,QSharedPointer<Camera>::create());
    return true;
}

void Page::next_scale()
{
    if(scale<6){
    scale++;
    }else{
        scale=1;
    }

    qDebug()<<"scale: "<<scale;

    for(int i = 0;i<scale*scale; i++){
        if(i>=map.count()){
           add_camera();
        }
    }

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
