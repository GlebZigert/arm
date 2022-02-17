#ifndef RUNNER_H
#define RUNNER_H

#include <QObject>
#include <QDebug>
#include <QTimer>
#include <QImage>
#include <QTime>
#include <time.h>
extern "C"{
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavformat/avio.h>
    #include <libswscale/swscale.h>
    #include <libavutil/hwcontext.h>
}


enum mode
      {
         turnOff,
         Streaming,
         Snapshot
      };

class Runner : public QObject
{
    Q_OBJECT

    // Свойство, управляющее работой потока
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)

public:
    explicit Runner( QObject *parent = nullptr);

    void output();

bool m_running;
    bool running() const;
    int count;  // Счётчик, по которому будем ориентироваться на то,

    QString str;
    QTimer tmr;
    static int interrupt_cb(void *ctx);
    QImage* img;
    QString URL;
    clock_t prev;


signals:
    void finished();    // Сигнал, по которому будем завершать поток, после завершения метода run
    void runningChanged(bool running);
    void lost_connection(QString URL);
    void new_frame();
    void playing();

public slots:
   void run(); // Метод с полезной нагрузкой, который может выполняться в цикле               // что потоки выполняются и работают
   void setRunning(bool running);


};

#endif // RUNNER_H
