#include "threadlist.h"

threadList::threadList(QImage* img, QObject *parent) : QObject(parent)
{
this->img=img;
tmr = new QTimer(this);
       connect(tmr,SIGNAL(timeout()), this,SLOT(process()));
//       tmr->start(1000);
}

bool threadList::append(QString str, int mode)
{

    foreach(MyThread* val, list.values()){



      val->stop();

    }
qDebug()<<"всего потоков: "<<list.values().count();
    foreach(MyThread* val, list.values()){


qDebug()<<val->runner.URL<<" "<<val->runner.m_running<<" "<<val->runner.thread()->isFinished();




if(val->runner.thread()->isFinished()){
delete val;

list.remove(list.key(val));
}
  //  if(val->runner.thread()->isFinished()){


   //     list.remove(list.key(val));
   //     delete val;
 //   }else{
  //  qDebug()<<"kill em!! "<<list.key(val);


  //  val->thread.quit();
  //  val->thread.terminate();
  //  }


    }


    foreach(QString val, list.keys()){

       if(val==str){

           qDebug()<<"уже есть такой";
           return false;


       }
    }




    qDebug("append");

    if(str!=0){
         MyThread*  mm=new MyThread(img,str,mode);
       //  connect(mm->runner,&Runner::new_frame,this,receiveFrame());

        connect(&mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
        connect(&mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lost_connection(QString)));
        //list.append(str);
        list.insert(str,mm);

        mm->thread.start();
    }




    return true;
}

void threadList::remove(QString str)
{
MyThread* current= list.value(str);
    current->stop();
   // delete current;
   //list.remove(str);

}

void threadList::process()
{
  //  qDebug()<<"step "<<step;
    switch(step){

    case 0:


     this->firstFrame=false;
     step=1;
     cnt1=0;
    append(URL,mode);


  //  qDebug()<<"cnt2 "<<cnt2;
     if(cnt2<10){
    tmr->start(100);
     }else
     {
         tmr->start(1000);
     }

    break;

    case 1:

    if(firstFrame){

        if(mode==mode::Snapshot){
        tmr->stop();
        }else{
            firstFrame=false;
            tmr->start(100);

        }
     //   this->firstFrame=false;

    }else{



    cnt1++;
  //  qDebug()<<"cnt1 "<<cnt1;

    if(cnt1<20){
    tmr->start(100);
    }else{
        *img=QImage(":/qml/video/no_signal.jpeg");
        emit frame();
        qDebug()<<"cnt2++";
        cnt2++;
    step=0;
    }
    }

    break;

    case 2:


    break;

    }


}

void threadList::receiveFrame(QString URL)
{
    this->firstFrame=true;
    qDebug()<<"receiveFrame "<<URL;
    emit frame();


}

void threadList::lost_connection(QString URL)
{
    if(URL==this->URL){
     qDebug()<<" !!! !!! CONNECTION LOST "<<URL;
 //    remove(URL);
     step=0;
     *img=QImage(":/qml/video/no_signal.jpeg");
     emit frame();
     cnt3++;

     if(cnt3<10)
     tmr->start(100);
     else
     tmr->start(1000);
}

}
