#include "model.h"

 QMap<QString,QSharedPointer<Wall>>  Model::mdl;
 bool  Model::fl=false;
 int Page::uid = 0;

Model::Model()
{
    if(!fl){
        fl=true;
    load_from_settings();
    }
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
/*
    //   qDebug()<<"-->";
    //   qDebug()<<"количество видеоэкранов: "<<mdl.count();

    for(auto vid : mdl.keys()){

        //   qDebug()<<"видеоэкран: "<< vid;

        auto wall = mdl.value(vid);

        //   qDebug()<<"количество страниц: "<<wall->count();
        //   qDebug()<<"Активная страница: "<<wall->current_page;

        for(auto one : wall.data()->list){

            //   qDebug()<<"страница: "<<one->name;

            //   qDebug()<<"масштаб: "<<one->current_scale();
             //   qDebug()<<"количество камер: "<<one->count();
             auto map = one->get_map();
             for(auto uid : map.keys()){
                 //   qDebug()<<uid<< map.value(uid)->cid<<" "<<map.value(uid)->url<<" "<<map.value(uid)->alarm;
             }

        }
        //   qDebug()<<"<--";
    }
    */

   // save_to_settings();
     //   load_from_settings();
}

int Model::get_pages_count()
{
    //   qDebug()<<"Model::get_pages_count(QString vid) -->";
    //   qDebug()<<"vid: "<<vid;

    if(!mdl.value(vid))
       add_vid();

    int count = mdl.value(vid).data()->count();
    //   qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
    //   qDebug()<<"<-- Model::get_pages_count(QString vid)";
    show();
    return count;
}

bool Model::add_page(QString pageName)
{
//   qDebug()<<"на видеостене "<<vid<<" добавляем страницу :"<<pageName;

    if(!mdl.value(vid))
       add_vid();

    auto wall = mdl.value(vid);

    if(wall){

   //если стена уже содержит страницу с таким именем - уходим

   if(wall->contain_page(pageName)){
       //   qDebug()<<"уже есть такая страница "<<pageName;
   return true;
   }

    wall->add_page(QSharedPointer<Page>::create(pageName));
    if(wall->list.count()>0){
    mdl.value(vid)->setCurrent_page(wall->list.count()-1);
    }

show();
    return true;
    }
show();
    return false;
}

bool Model::delete_page( int page)
{
    //   qDebug()<<"на видеостене "<<vid<<" удаляем страницу ";
    show();return mdl.value(vid)->delete_page(page);
}

bool Model::to_page( int page)
{
    //   qDebug()<<"на видеостене "<<vid<<" переходим на страницу "<<page;

     if(!mdl.value(vid))
       return false;
    if(page<0 || page>=mdl.value(vid).data()->count()){
        //   qDebug()<<"у видеостены "<<vid<<" нет cтраницы c номером "<<page;
        int count = mdl.value(vid).data()->count();
        //   qDebug()<<"количество страниц на видеостене: "<<vid<<" : "<<count;
        show();return false;

    }
    mdl.value(vid)->setCurrent_page(page);
    //   qDebug()<<"Переход на видеостене "<<vid<<" на страницу "<<page;

    show();return true;


}

bool Model::to_page(QString name)
{
    if(!mdl.value(vid))
      return false;
    int i=0;
  for(auto one : mdl.value(vid)->list){
      if(one->name==name){
          to_page(i);
          return true;
      }
      i++;
  }
  return false;
}

bool Model::to_next_page()
{
    if(!mdl.value(vid))
      return false;

    int page =  mdl.value(vid)->current_page;

    int count = mdl.value(vid)->list.count();

    if(count<1)
        return false;

    if(page+1>=count)
        page=0;
    else
        page=page+1;

    mdl.value(vid)->current_page=page;

    show();

    return true;


}

int Model::current_page()
{

    //   qDebug()<<"Model::current_page()";
    show();return mdl.value(vid)->getCurrent_page();
}

bool Model::add_camera()
{
    //   qDebug()<<"Model::add_camera()";
    //   //   qDebug()<<""
    auto res = mdl.value(vid)->add_camera();
    show();
    return res;

    //   show();return false;

}

void Model::clear_if_not_alarm()
{
      mdl.value(vid)->clear_if_not_alarm();


}

void Model::next_scale()
{
    //   qDebug()<<"Model::next_scale()";
    mdl.value(vid)->next_scale();
    show();
}

void Model::set_scale(int val)
{
    mdl.value(vid)->list.at(mdl.value(vid)->current_page)->scale=val;
}

int Model::current_scale()
{
    //   qDebug()<<"Model::current_scale()";
    if(!mdl.value(vid)){
        add_vid();
    }

    auto res = mdl.value(vid)->current_scale();
    show();
    return res;

}

void Model::check_the_scale(int id, bool alarm)
{
    //   qDebug()<<"Model::check_the_scale";

    mdl.value(vid)->check_the_scale(id,alarm);
 //       show();
}

int Model::get_uid_at(int i)
{
    //   qDebug()<<"Model::get_uid_at(int i)";
    auto res = mdl.value(vid)->get_uid_at(i);
   // show();
    return res;
}

QList<int> Model::get_cids()
{
    //   qDebug()<<"Model::get_cids()";
    QList<int> lst;
    auto v1 =mdl.value(vid);

    if(!mdl.value(vid)){
        return lst;
    }

    auto v3=mdl.value(vid)->current_page;
    if(v3=-1)
        v3=0;

    if(v3>=v1->list.count())
        return lst;

    auto v2=v1->list.at(v3);
    auto v4=v2->map;





            auto v5=v4.keys();

            return v5;

    return mdl.value(vid)->list.at(mdl.value(vid)->current_page)->map.keys();
}

int Model::get_cid_at(int i)
{
        //   qDebug()<<"Model::get_cid_at(int i)";
   return mdl.value(vid)->get_cid_at(i);
}

QString Model::get_url_at(int i)
{
        //   qDebug()<<"Model::get_url_at(int i)";
   return mdl.value(vid)->get_url_at(i);
}

bool Model::get_alarm_at(int i)
{
            //   qDebug()<<"Model::get_alarm_at(int i)";
    return mdl.value(vid)->get_alarm_at(i);
}

void Model::set_cid_for_uid(int cid, int uid)
{
     //   //   qDebug()<<"Model::set_cid_for_uid(int cid, int uid)";
     mdl.value(vid)->set_cid_for_uid(cid,uid);
     show();
}

void Model::set_url_for_uid(QString url, int uid)
{
        //    //   qDebug()<<"Model::set_url_for_uid(QString url, int uid)";
     mdl.value(vid)->set_url_for_uid(url,uid);
     show();
}

QString Model::get_current_page_name()
{

    if(!mdl.value(vid))
        return "err";

    if(mdl.value(vid)->list.count()==0 )
        return "err";

    if(mdl.value(vid)->current_page<0)
        mdl.value(vid)->current_page=0;

    if(mdl.value((vid))->list.count()<=current_page())
        return "err";

    QString res = mdl.value(vid)->list.at(current_page())->name;

    return res;
}



void Model::setVid(const QString src)
{
            //   qDebug()<<"Model::setVid(const QString src)";
    vid = src;
    if(!mdl.value(vid))
        add_vid();
}

void Model::save_to_settings()
{
    //   qDebug()<<"save_to_settings: ";

    QSettings settings("MySoft", "Star Runner");
    settings.beginGroup("Videowalls");
//    //   qDebug()<<"count: "<<mdl.count();
    settings.setValue("count",mdl.count());
    int i=0;
    for(auto vid : mdl.keys()){
        settings.beginGroup(QString("Videowall %1").arg(i));
        i++;
        settings.setValue("vid",vid);
        settings.setValue("count",mdl.value(vid)->list.count());
     //   //   qDebug()<<"стена: "<<vid;
        int j=0;
        for(auto page : mdl.value(vid)->list){
            settings.beginGroup(QString("Page %1").arg(j));

    //        //   qDebug()<<"страница: "<<page->name;
    //        //   qDebug()<<"количеcтво камер: "<<page->map.count();
            settings.setValue("name",page->name);
            settings.setValue("count",page->map.count());
            settings.setValue("scale",page->scale);

            int ii=0;
            for(auto uid : mdl.value(vid)->list.at(j)->map.keys()){
                settings.beginGroup(QString("Camera %1").arg(ii));
                ii++;

                auto camera = mdl.value(vid)->list.at(j)->map.value(uid);

                auto cid =  camera->cid;
                auto url = camera->url;

           //     //   qDebug()<<"camera "<<ii<<": "<<uid<<" "<<cid<<" "<<url;

                settings.setValue("uid",uid);
                settings.setValue("cid",cid);
                settings.setValue("url",url);

                settings.endGroup();
            }
            j++;

            settings.endGroup();
        }

        settings.endGroup();



    }
    settings.endGroup();

}

void Model::load_from_settings()
{
    //   qDebug()<<" ";
    //   qDebug()<<"Читаем настройки --->: ";

    QSettings settings("MySoft", "Star Runner");

    settings.beginGroup("Videowalls");

    int count = settings.value("count").toInt();

 //   //   qDebug()<<"количество видеоэкранов: "<<count;


    for(int i=0;i<count;i++){
        settings.beginGroup(QString("Videowall %1").arg(i));
        auto vid = settings.value("vid").toString();
   //     //   qDebug()<<"vid: "<<vid;

        setVid(vid);

        auto count = settings.value("count").toInt();
     //   //   qDebug()<<"количество страниц: "<<count;

        for(int j=0;j<count;j++){
            settings.beginGroup(QString("Page %1").arg(j));

            auto name = settings.value("name").toString();
      //      //   qDebug()<<"страница: "<<name;
            auto count = settings.value("count").toInt();
     //       //   qDebug()<<"количество камер: "<<count;
            auto scale = settings.value("scale").toInt();
     //       //   qDebug()<<"масштаб: "<<scale;


         //   auto wall = mdl.value(vid);


            mdl.value(vid)->list.append(QSharedPointer<Page>::create(name));
            mdl.value(vid)->setCurrent_page( mdl.value(vid)->list.count()-1);


            set_scale(scale);
            if(name!="Архив")
            for(int ii=0;ii<count;ii++){

                settings.beginGroup(QString("Camera %1").arg(ii));


                auto uid = settings.value("uid").toInt();
                auto cid =  settings.value("cid").toInt();
                auto url = settings.value("url").toString();


                mdl.value(vid)->list.at(mdl.value(vid)->list.count()-1)->map.insert(uid,QSharedPointer<Camera>::create());

                  mdl.value(vid)->set_cid_for_uid(cid,uid);
                  mdl.value(vid)->set_url_for_uid(url,uid);






       //         //   qDebug()<<"camera "<<ii<<": "<<uid<<" "<<cid<<" "<<url;





                settings.endGroup();
            }

            settings.endGroup();

        }

        settings.endGroup();

        //   qDebug()<<"<------ ";
        //   qDebug()<<" ";
    }
}

bool Model::add_vid()
{
            //   qDebug()<<"Model::add_vid()";
    if(mdl.value(vid))
        return true;

        //   qDebug()<<"добавляю "<<vid;
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

 for(int i=0;i<36;i++){
     page->add_camera();
}

 return true;
}

bool Wall::contain_page(QString nm)
{
    for(auto one : list){
        if(one->name==nm){
            return true;
        }
    }
    return false;
}

bool Wall::delete_page(int page)
{
      //   qDebug()<<"удаляем страницу "<<page;
 if(page<0 || page>=list.count()){
     //   qDebug()<<"нет старницы с таким номером "<<page;
             return false;
 }

 list.removeAt(page);
 current_page=0;

 return true;
}

bool Wall::add_camera()
{
    //   qDebug()<<"Добавляем камеру ";

if(current_page<0||current_page>=list.count())
    return false;

 auto page = list.at(current_page);

 if(!page){
      //   qDebug()<<"нет страницы с таким номером "<<page;
     return false;
 }

return page->add_camera();



//page->list.insert(uid++,QSharedPointer<Camera>::create());

}

void Wall::next_scale()
{

if(current_page==-1)
    current_page=0;

    if(current_page<0 || current_page>=list.count())
        return;

 auto page = list.at(current_page);
 page->next_scale();
}

int Wall::current_scale()
{

    if(current_page<0)
        current_page=0;


     if(current_page>=list.count())
         return -1;

    if(!list.at(current_page))
        return -1;

    return list.at(current_page)->current_scale();

}

Wall::~Wall()
{
    //   qDebug()<<"Wall::~Wall()";
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
    if(current_page==-1)
        return -1;


    if(list.count()<=current_page)
        return -1;

    if(list.at(current_page))
    return list.at(current_page)->get_uid_at(i);

    return -1;
}

int Wall::get_cid_at(int i)
{
    if(current_page==-1)
        return -1;

    if(list.count()<=current_page)
        return -1;

    if(list.at(current_page))
    return list.at(current_page)->get_cid_at(i);

    return -1;
}

QString Wall::get_url_at(int i)
{
    if(current_page==-1)
        return "";

    if(list.count()<=current_page)
        return "";

    if(list.at(current_page))
    return list.at(current_page)->get_url_at(i);

    return "";
}

bool Wall::get_alarm_at(int i)
{
    if(current_page==-1)
        return false;

    if(list.count()<=current_page)
        return false;

    if(list.at(current_page))
    return list.at(current_page)->get_alarm_at(i);

    return false;
}

void Wall::check_the_scale(int id,bool alarm)
{
    if(current_page==-1)
        current_page=0;

    if(list.count()==0){
        list.append(QSharedPointer<Page>::create("def"));

        current_page=0;
    }


    list.at(current_page)->check_the_scale(id, alarm);
}

void Wall::set_cid_for_uid(int cid, int uid)
{
    if(current_page==-1)
        return;

    if(list.count()<=current_page)
        return;

    if(list.at(current_page))
    list.at(current_page)->set_cid_for_uid( cid, uid);


}

void Wall::set_url_for_uid(QString url, int uid)
{
    if(current_page==-1)
        return;

    if(list.count()<=current_page)
        return ;

    if(list.at(current_page))
        list.at(current_page)->set_url_for_uid(url, uid);
}

void Wall::clear_if_not_alarm()
{
    auto page = list.at(current_page);

    page->clear_if_not_alarm();
}

Page::Page(QString nm)
{
    //   qDebug()<<"Страница создана ";
    scale=1;
    name=nm;
}

Page::Page(QObject *parent, QString nm)
{
    //   qDebug()<<"Страница создана ";
    scale=1;
    name=nm;
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

    //   qDebug()<<"scale: "<<scale;

    for(int i = 0;i<scale*scale; i++){
        if(i>=map.count()){
           add_camera();
        }
    }

}

void Page::check_the_scale(int id,bool alarm)
{
    if(map.count()==0){
     for(int i=0;i<36;i++)
        add_camera();
    }
    auto list = map.keys();

    int i=1;

    foreach(auto key , list){


        if(i>(scale*scale)){


        //   qDebug()<<"--- i: "<<i<<" scale: "<<scale;
        next_scale();


        }

       if(map.value(key)->cid==-1){
           map.value(key)->cid=id;
           map.value(key)->alarm=alarm;
     //       cids.setProperty(i,"cid",id)
     //       cids.setProperty(i,"alarm",alarm)
//   qDebug()<<"i: "<<i<<" scale: "<<scale;

            break;
            //выделить этот cid

        }
         i++;
    }



}

void Page::set_cid_for_uid(int cid, int uid)
{
//    //   qDebug()<<"set cid "<<cid<<" for uid "<<uid;
    if(map.value(uid))
        map.value(uid)->cid=cid;
}

void Page::set_url_for_uid(QString url, int uid)
{
  //  //   qDebug()<<"set url "<<url<<" for uid "<<uid;
    if(map.value(uid))
        map.value(uid)->url=url;
}

int Page::get_uid_at(int i)
{
    if(map.count()<=i)
        return -1;

    return map.keys().at(i);


}

int Page::get_cid_at(int i)
{
    if(map.count()<=i)
        return -1;

    return map.values().at(i)->cid;
}

QString Page::get_url_at(int i)
{
    if(map.count()<=i)
        return "";

    return map.values().at(i)->url;
}

bool Page::get_alarm_at(int i)
{
    if(map.count()<=i)
        return false;

    if(map.values().at(i)->cid==-1){
        map.values().at(i)->alarm=false;
    }

    return map.values().at(i)->alarm;
}

void Page::clear_if_not_alarm()
{
    for(auto one : map.values()){

        if(one->alarm==0){
            one->cid=-1;
            one->url="";


        }


    }
}

Page::~Page()
{
    //   qDebug()<<"Страница удалена";
}

Camera::Camera(QObject *parent)
{
  //  //   qDebug()<<"Камера добавлена";
    cid=-1;
    alarm = false;

}

Camera::~Camera()
{
    //   qDebug()<<"Камера удалена";
}
