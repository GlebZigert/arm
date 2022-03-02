#include "threadlist.h"

threadList::threadList(QImage* img, QObject *parent) : QObject(parent)
{
    this->img=img;
    tmr = new QTimer(this);
    connect(tmr,SIGNAL(timeout()), this,SLOT(process()));
}

bool threadList::append(QString str, int mode)
{
    foreach(MyThread* val, list.values()){
        val->stop();
    }

    foreach(MyThread* val, list.values()){

    if(val->runner.thread()->isFinished()){
        delete val;
        list.remove(list.key(val));
    }

    }
    foreach(QString val, list.keys()){

        if(val==str){
            return false;
        }
    }

    if(str!=0){
        MyThread*  mm=new MyThread(img,str,mode);
        connect(&mm->runner,SIGNAL(new_frame(QString)),this,SLOT(receiveFrame(QString)));
        connect(&mm->runner,SIGNAL(lost_connection(QString)),this,SLOT(lost_connection(QString)));
        list.insert(str,mm);
        mm->thread.start();
    }
    return true;
}

void threadList::remove(QString str)
{
    MyThread* current= list.value(str);
    current->stop();
}

void threadList::process()
{

    switch(step){

        case 0:

        this->firstFrame=false;
        step=1;
        cnt1=0;
        append(URL,mode);

        if(cnt2<10){
            tmr->start(100);
        }else{
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
        }else{

            cnt1++;

            if(cnt1<20){
                tmr->start(100);
            }else{
                *img=QImage(":/qml/video/no_signal.jpeg");
                emit frame();

                cnt2++;
                step=0;
            }
        }

        break;



    }

}

void threadList::receiveFrame(QString URL)
{
    this->firstFrame=true;
    emit frame();


}

void threadList::lost_connection(QString URL)
{
    if(URL==this->URL){
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