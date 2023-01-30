#ifndef RUNNER_H
#define RUNNER_H

#include <QObject>
#include <QDebug>
#include <QTimer>
#include <QTime>
#include <time.h>

#include <QtGlobal>
#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    // Qt 4
    #include <QDeclarativeEngine>
#else
    // Qt 5
    #include <QQmlEngine>
#endif

extern "C"{
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavformat/avio.h>
    #include <libswscale/swscale.h>
    #include <libavutil/hwcontext.h>
}

/*
enum mode
      {
         turnOff,
         Streaming,
         Snapshot
      };
 Q_ENUMS(mode)
*/
class Runner : public QObject
{
    Q_OBJECT

    // Свойство, управляющее работой потока
    Q_PROPERTY(int running READ running WRITE setRunning NOTIFY runningChanged)

public:

    enum Mode
           {
        TurnOff,
        LiveStreaming,
        StorageStreaming,
        Snapshot
           };
           Q_ENUMS(Mode)

    explicit Runner( QObject *parent = nullptr);
        explicit Runner(int index,AVPicture** data,int *h, int *w, QString URL,Runner::Mode mode, QObject *parent = nullptr);
    ~Runner();
    void output();

    int get_m_index() const;

    static void declareQML() {
       qmlRegisterType<Runner>("MyQMLEnums", 13, 37, "Mode");
       qRegisterMetaType<Runner::Mode>("const Runner::Mode");
    }

int m_running;
    int running() const;
    int count;  // Счётчик, по которому будем ориентироваться на то,

    QString str;

    clock_t delay;
    QTimer tmr;
    static int interrupt_cb(void *ctx);
    QString URL;
    clock_t prev;
    AVPicture **data;
    int *h;
    int *w;
private:
    int m_index;
    AVCodecContext *pAVCodecContext;
    AVFrame *pAVFrame;
    SwsContext * pSwsContext;
    AVPicture  *pAVPicture;
    AVCodec *pAVCodec;
    AVPacket *packet;
    AVFormatContext *pFormatCtx;

    AVCodecParameters* param ;

    int videoindex;

    int videoWidth;
    int videoHeight;

    int m_i_frameFinished;
    int ret;





void load();
bool load_settings();
void free_settings();
void free();
bool capture();

    void close();


signals:
    void finished();    // Сигнал, по которому будем завершать поток, после завершения метода run
    void runningChanged(bool running);
    void lost_connection(QString URL);
    void new_frame(QString);
    void playing();
    void destroyed();



public slots:
   void run(); // Метод с полезной нагрузкой, который может выполняться в цикле               // что потоки выполняются и работают
   void setRunning(int running);


};

#endif // RUNNER_H
