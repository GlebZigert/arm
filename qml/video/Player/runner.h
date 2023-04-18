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

#include <QThread>

extern "C"{
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavformat/avio.h>
    #include <libswscale/swscale.h>
    #include <libavutil/hwcontext.h>
}




class Runner : public QObject
{
    Q_OBJECT


private:

public:
    QDateTime time;
    bool frash_stream;
    bool go_to_free_state;

    static int created;
    static int deleted;
    static int index;
    static int av_codec_open;
    static int av_codec_not_open;
    static int av_codec_close;



    enum StreamType
          {
         Nothing  ,
          Storage,
             Streaming,
             Snapshot

          };
     Q_ENUMS(StreamType)

    enum Mode
           {
        TurnOff,
        Started,
        Free,
        Prepare,
        Play,
        Hold,
        Lost,
        Exit,
        Waiting //wait first frame


           };



           Q_ENUMS(Mode)
    StreamType streamType;
    explicit Runner( QObject *parent = nullptr);
        explicit Runner(int index, QObject *parent = nullptr);
        explicit Runner(int index,AVPicture** data,int *h, int *w, QString URL,Runner::StreamType type, QObject *parent = nullptr);
    ~Runner();
    void output();

    int get_m_index() const;
    QString get_state();
    static void declareQML() {
       qmlRegisterType<Runner>("MyQMLEnums", 13, 37, "Mode");
         qmlRegisterType<Runner>("MyQMLEnums", 13, 37, "StreamType");
       qRegisterMetaType<Runner::Mode>("const Runner::Mode");


        qRegisterMetaType<Runner::StreamType>("const Runner::StreamType");
    }


    int running() const;
    int count;  // Счётчик, по которому будем ориентироваться на то,

    bool is_over;

    QString str;

    clock_t delay;
    QTimer tmr;
    static int interrupt_cb(void *ctx);
    QString URL;
    clock_t prev;
    AVPicture **data;
    int *h;
    int *w;

    AVDictionary* options;
    int getVideoWidth() const;

    int getVideoHeight() const;

    Runner::Mode get_m_running();
    void set_m_running(Runner::Mode mode);
    bool check_frame();
private:

    bool first_frame_getted=false;

    Runner::Mode m_running;
    int m_index=-1;
    AVCodecContext *pAVCodecContext;
    AVFrame *pAVFrame, *svFrame;
    SwsContext * pSwsContext;
    AVPicture*  pAVPicture;
    AVCodec *pAVCodec;
    AVPacket packet;
    AVFormatContext *pFormatCtx;

    AVCodecParameters* param ;

    unsigned int videoindex;

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
    void lost_connection(QString URL);
    void new_frame(QString);
    void playing();
    void destroyed();



public slots:
   void run(); // Метод с полезной нагрузкой, который может выполняться в цикле               // что потоки выполняются и работают



};

#endif // RUNNER_H
