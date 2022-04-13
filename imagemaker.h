#ifndef IMAGEMAKER_H
#define IMAGEMAKER_H

#include <QObject>

#include <QtQuick/QQuickPaintedItem>
#include <QObject>
#include <QPainter>
#include <QDebug>
#include <QDir>
#include <QtPrintSupport/QPrinter>
#include <QtPrintSupport/QPrintDialog>
#include <QNetworkReply>
class imageMaker : public QQuickPaintedItem
{
    Q_OBJECT

public:
    explicit imageMaker(QQuickItem *parent = 0);

    QNetworkAccessManager *manager;
    QString m_URL;
  QImage current;
    Q_INVOKABLE void test();

    QImage createImage(QString text="Leer",
                     QString path= "C:/",
                     QString imageName="TextImage.png",
                     QColor aColor=Qt::red);

     QImage createImage_1(QString name,
                       QString suname
                       );

    Q_INVOKABLE QImage createImage_2(
                        QImage photo,
                        QString name,
                        QString suname
                        );

     Q_INVOKABLE QImage createImage_3(
                         QString path_photo,
                         QString name,
                         QString suname
                         );

     QString name,surename;

     Q_INVOKABLE void take_photo_from_url_and_set_name_and_surename(QString URL,
                                                                    QString name,
                                                                    QString surename);

   Q_INVOKABLE  void printImage();


 void paint(QPainter *painter) override; // Переопределяем метод, в котором будет отрисовываться наш объект


    void drawText(QPainter* painter,int x,int y,int width,int height, QString Text);

private:
     QImage m_image;


public slots:

    void replyFinished(QNetworkReply* reply);

signals:



};

#endif // IMAGEMAKER_H
