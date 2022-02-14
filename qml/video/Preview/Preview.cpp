#include "Preview.h"
#include <QNetworkAccessManager>

Preview::Preview(QQuickItem *parent) :
    QQuickPaintedItem(parent)


  /*,
    m_backgroundColor(Qt::white),
    m_borderActiveColor(Qt::blue),
    m_borderNonActiveColor(Qt::gray),
    m_angle(0),
    m_circleTime(QTime(0,0,0,0))
  */
{
    /*
    internalTimer = new QTimer(this);   // Инициализируем таймер
    //  А также подключаем сигнал от таймера к лямбда функции
    //  Структура лямбда-функции [объект](аргументы){тело}

    connect(internalTimer, &QTimer::timeout, [=](){
        setAngle(angle() - 0.3);                    // поворот определяется в градусах.
        setCircleTime(circleTime().addMSecs(50));   // Добавляем к текущему времени 50 милисекунд
        update();                                   // Перерисовываем объект
    });

    */
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &Preview::onTimer);
     timer->start(5000);


    connect(this, &Preview::widthChanged, this, &Preview::onWidthChanged);
    connect(this, &Preview::heightChanged, this, &Preview::onWidthChanged);



    manager = new QNetworkAccessManager();
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    manager->get(QNetworkRequest(QUrl(m_URL)));


  //  update();
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

    qDebug()<<"setURL: "<<URL;
    m_URL = URL;
    timer->start();
    manager->get(QNetworkRequest(QUrl(m_URL)));
}

void Preview::paint(QPainter *painter)
{

    if(!(this->current.isNull())){
    painter->drawImage(QRect(0, 0, width(), height()), this->current);
    }

/*
    QBrush  brush(Qt::white);               // выбираем цвет фона, ...
    QBrush  brushActive(Qt::blue);       // активный цвет ободка, ...
    QBrush  brushNonActive(Qt::gray); // не активный цвет ободка

    painter->setPen(Qt::NoPen);                             // Убираем абрис
    painter->setRenderHints(QPainter::Antialiasing, true);  // Включаем сглаживание

    painter->setBrush(brushNonActive);                          // Отрисовываем самый нижний фон в виде круга
    painter->drawEllipse(boundingRect().adjusted(1,1,-1,-1));   // с подгонкой под текущие размеры, которые
                                                                // будут определяться в QML-слое.
                                                                // Это будет не активный фон ободка

    // Прогресс бар будет формироваться с помощью отрисовки Pie графика
    painter->setBrush(brushActive);                         // Отрисовываем активный фон ободка в зависимости от угла поворота
    painter->drawPie(boundingRect().adjusted(1,1,-1,-1),    // с подгонкой под размеры в QML слое
                     90*16,         // Стартовая точка
                     30*16);   // угол поворота, до которого нужно отрисовать объект

    painter->setBrush(brush);       // основной фон таймера, перекрытием которого поверх остальных
    painter->drawEllipse(boundingRect().adjusted(10,10,-10,-10));   // будет сформирован ободок (он же прогресс бар)
*/
}

void Preview::replyFinished(QNetworkReply *reply)
{
  //  qDebug()<<"replyFinished";

    this->current.loadFromData(reply->readAll());

    if((this->current.isNull())){
  //    qDebug()<<"isNull !!!";
    manager->get(QNetworkRequest(QUrl(m_URL)));
    }else{
       update();
    }
}

void Preview::onWidthChanged(){
qDebug()<<width();
update();
}

void Preview::onheightChanged(){
qDebug()<<height();
update();
}

void Preview::onTimer()
{
   // qDebug()<<"onTimer";
    manager->get(QNetworkRequest(QUrl(this->m_URL)));

}




