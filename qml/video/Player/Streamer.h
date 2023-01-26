#ifndef STREAMER_H
#define STREAMER_H

#include <QObject>
#include <QMap>
#include <QSharedPointer>
#include "mythread.h"

class Streamer : public QObject
{
    Q_OBJECT
public:
    explicit Streamer(QString URL,Runner::Mode mode,QObject *parent = nullptr);
    ~Streamer();
    QSharedPointer<MyThread> mm;


    int followers=0;

    void followers_inc();
    void followers_dec();

    int h;
    int w;

    QImage* img;


    bool isValid;

    bool save=false;







    Runner::Mode mode;




    void stop();



    QTimer *tmrStart;



    int delay;

    AVPicture *getData() const;

    int getH() const;

    int getW() const;

    int getFollowers() const;

    const QString &getURL() const;

    bool getIsOver() const;

   int get_m_index() const;

   bool getSave() const;
   void setSave(bool newSave);

private:

    bool isOver=false;


    AVPicture *data;

    QString URL;

    static int index;

    int m_index;


public slots:
    void receiveFrame(QString);
    void lostConnection(QString);

    void start();

    void startRunner();

signals:
    void frame(QString URL);
    void lost(QString URL);

};

#endif // STREAMER_H
