#ifndef FFPLAYER_H
#define FFPLAYER_H

#include <QObject>
#include <QThread>
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

class FFPlayer : public QObject
{
    Q_OBJECT


    // Свойство, управляющее работой потока
    Q_PROPERTY(mode running READ running WRITE setRunning NOTIFY runningChanged)
public:
    explicit FFPlayer(QObject *parent = nullptr);
    QImage img;
    void run();
    mode running() const;
    void setRunning(mode running);
    QString URL;

    clock_t prev;

    int func(void *ctx);
    static int interrupt_cb(void *ctx);

private:
    mode m_running;
    void get_snapshot();
signals:
    void new_frame();
    void finished();    // Сигнал, по которому будем завершать поток, после завершения метода run
    void runningChanged(bool running);
    void lost_connection();
    void playing();

};

#endif // FFPLAYER_H
