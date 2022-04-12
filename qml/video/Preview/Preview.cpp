#include "Preview.h"
#include <QNetworkAccessManager>

Preview::Preview(QQuickItem *parent) :
    QQuickPaintedItem(parent)
{
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &Preview::onTimer);
    timer->start(5000);
    connect(this, &Preview::widthChanged, this, &Preview::onWidthChanged);
    connect(this, &Preview::heightChanged, this, &Preview::onWidthChanged);
    manager = new QNetworkAccessManager();
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    manager->get(QNetworkRequest(QUrl(m_URL)));
}

QString Preview::readURL() const
{
    return m_URL;
}

void Preview::setURL(const QString &URL)
{
    timer->stop();
    this->current = QImage();
    update();
    m_URL = URL;
    timer->start();
    manager->get(QNetworkRequest(QUrl(m_URL)));
}

void Preview::paint(QPainter *painter)
{
    if(!(this->current.isNull())){
    painter->drawImage(QRect(0, 0, width(), height()), this->current);
    }
}

void Preview::replyFinished(QNetworkReply *reply)
{
    this->current.loadFromData(reply->readAll());
    if((this->current.isNull())){
        manager->get(QNetworkRequest(QUrl(m_URL)));
    }else{
       update();
    }

}

void Preview::onWidthChanged(){
    update();
}

void Preview::onheightChanged(){
    update();
}

void Preview::onTimer()
{
    manager->get(QNetworkRequest(QUrl(this->m_URL)));
}




