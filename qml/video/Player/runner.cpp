#include "runner.h"
#include "QDebug"
#include <mutex>
#define AVIO_FLAG_NONBLOCK   8
AVDictionary* options;
static std::mutex local_mutex;
Runner::Runner( QObject *parent) : QObject(parent)
{
  //  qDebug()<<"Runner::Runner( QObject *parent) : QObject(parent)";
    av_log_set_level(AV_LOG_QUIET);



     pAVCodecContext = NULL;
     pAVFrame = NULL;
      pSwsContext = NULL;
     pAVPicture = NULL;
     pAVCodec = NULL;
     packet = NULL;
     pFormatCtx = NULL;

     param  = NULL;
}

Runner::Runner(AVPicture **data, int *h, int *w, QString URL, Runner::Mode mode, QObject *parent)
{
      qDebug()<<"Runner::Runner( QObject *parent) : QObject(parent)";
    pAVCodecContext = NULL;
    pAVFrame = NULL;
     pSwsContext = NULL;
    pAVPicture = NULL;
    pAVCodec = NULL;
    packet = NULL;
    pFormatCtx = NULL;

    param  = NULL;
    this->m_running=mode;
    this->data=data;
    this->URL=URL;
    this->h=h;
    this->w=w;

    qDebug()<<"runner mode: "<<mode;

}

Runner::~Runner()
{
     local_mutex.lock();
    qDebug()<<"DELETE Runner "<<this->URL;
    close();
    qDebug()<<"runner destroyed "<<this->URL;
 local_mutex.unlock();
}

int Runner::running() const
{

}

int Runner::interrupt_cb(void *ctx)
{

    Runner* pl=(Runner*)ctx;
    clock_t delay=clock()-pl->prev;
   // qDebug()<<delay;
    if(delay>150000){
        qDebug()<<"Interrupt";
        pl->prev=clock();
        pl->m_running=Mode::TurnOff;
        emit pl->lost_connection(pl->URL);

        return 1;
    }
    return 0;

}

void Runner::load()
{
    avformat_network_init();
    pAVFrame = av_frame_alloc();
    pAVPicture = new AVPicture();
    packet = (AVPacket *) malloc(sizeof(AVPacket));
//    pFormatCtx = avformat_alloc_context();
}

bool Runner::load_settings()
{
//   QString URL="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0";
    qDebug()<<"URL: "<<URL;
    QByteArray ba = URL.toLatin1();
    char *c_str2 = ba.data();
    char *filepath = ba.data();


    av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
    av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
    av_dict_set(&options, "stimeout", "200000", 0); //Set timeout disconnect time, unit is microsecond "20000000"
    av_dict_set(&options, "max_delay", "50", 0); //Set the maximum delay
    qDebug()<<"avformat_open_input -->";
    int error = avformat_open_input(&pFormatCtx, filepath, NULL, &options);
    qDebug()<<"<-- avformat_open_input";
    if (error != 0){
      //  emit lost_connection(URL);


        qDebug()<<"FAIL with: avformat_open_input "<<error;

        return false;
    }

    pFormatCtx->probesize = 1000;
    pFormatCtx->max_analyze_duration = AV_TIME_BASE;

    if (avformat_find_stream_info(pFormatCtx, NULL)<0){
    //    emit lost_connection(URL);

        qDebug()<<"FAIL with: avformat_find_stream_info ";
        return false;
    }

    videoindex = -1;
    for (int i = 0; i<pFormatCtx->nb_streams; i++)
    if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
        videoindex = i;
        break;
    }


    if (videoindex == -1){
    //    emit lost_connection(URL);

         qDebug()<<"FAIL with: videoindex ";
        return false;
    }

    av_dump_format(pFormatCtx, 0, filepath,0);

    param = avcodec_parameters_alloc();
    pAVCodecContext = avcodec_alloc_context3(NULL);
    pAVCodec = avcodec_find_decoder(pFormatCtx->streams[0]->codec->codec_id);

    avcodec_parameters_from_context(param, pFormatCtx->streams[0]->codec);
    avcodec_parameters_to_context(pAVCodecContext, param);

    videoWidth=pAVCodecContext->width;
    videoHeight=pAVCodecContext->height;

    avpicture_alloc(pAVPicture,AV_PIX_FMT_RGB32,videoWidth,videoHeight);

    pAVCodec = avcodec_find_decoder(pAVCodecContext->codec_id);

    if((videoWidth==0)&&(videoHeight==0)){
    //     emit lost_connection(URL);
    //     emit finished();
         //close();
        qDebug()<<"FAIL with: videoWidth videoHeight";
       return false;
     }

    pSwsContext = sws_getContext(videoWidth,videoHeight,pAVCodecContext->pix_fmt,videoWidth,videoHeight,AV_PIX_FMT_RGB32,SWS_BICUBIC,0,0,0);

    pAVCodecContext->thread_count=10;

    int result=avcodec_open2(pAVCodecContext,pAVCodec,NULL);
    if (result<0){
    //    emit lost_connection(URL);
        emit finished();
        close();
        qDebug()<<"FAIL with: avcodec_open2t";
        return false;
    }

    int y_size = pAVCodecContext->width * pAVCodecContext->height;
    qDebug()<<"y_size "<<y_size;
//    av_new_packet(packet, y_size);

    av_init_packet(packet);
/* */
    return true;
}

void Runner::free_settings()
{
    //  if(packet->buf){
    /*
    if(packet){
        //qDebug()<<"av_packet_unref(packet);";

     av_packet_unref(packet);
    }
    */
   //   }
   //   if(packet->buf){



      if(pAVPicture){
          //qDebug()<<"avpicture_free(pAVPicture);";
      avpicture_free(pAVPicture);
      }

      if(pFormatCtx){
          //qDebug()<<"vformat_close_input(&pFormatCtx);";
      avformat_close_input(&pFormatCtx);
      avformat_free_context(pFormatCtx);
      }



      if(options){
  //qDebug()<<"  av_dict_free(&options);";
          av_dict_free(&options);
      }

       if(param)   {
      //qDebug()<<"  avcodec_parameters_free(&param);";
      avcodec_parameters_free(&param);
       }

       if(pAVCodecContext){
               //qDebug()<<" avcodec_free_context(&pAVCodecContext);";
      avcodec_free_context(&pAVCodecContext);
       }

}
//  //qDebug()<<" ";
void Runner::free()
{
    if(packet){
     //qDebug()<<" av_free(packet); ";
    av_free(packet);
    }

    if(pAVFrame){
        //qDebug()<<"av_frame_free(&pAVFrame); ";
    av_frame_free(&pAVFrame);
    }

    if(pAVPicture){
        //qDebug()<<"av_free(pAVPicture); ";
    av_free(pAVPicture);
    }

    if(pSwsContext){
        //qDebug()<<"sws_freeContext(pSwsContext); ";
    sws_freeContext(pSwsContext);
    }
    //if(pAVCodecContext)
    //avcodec_free_context(&pAVCodecContext);

}

bool Runner::capture()
{

    int res=(av_read_frame(pFormatCtx, packet));
   if(res<0){
       qDebug()<<"interrupt lostConnection";
   //    emit lost_connection(URL);
   //    emit finished();

       //close();
       return false;
   }

   int used=0;
   int got_frame=0;
   if (pAVCodecContext->codec_type == AVMEDIA_TYPE_VIDEO ||
              pAVCodecContext->codec_type == AVMEDIA_TYPE_AUDIO) {
              used = avcodec_send_packet(pAVCodecContext, packet);
              if (used < 0 && used != AVERROR(EAGAIN) && used != AVERROR_EOF) {
             } else {
              if (used >= 0)
                  packet->size = 0;
              used = avcodec_receive_frame(pAVCodecContext, pAVFrame);
              if (used >= 0)
                  got_frame = 1;
 //             if (used == AVERROR(EAGAIN) || used == AVERROR_EOF)
 //                 used = 0;
              }
          }

   if (got_frame==1){
           sws_scale(pSwsContext,
                    (const uint8_t* const *)pAVFrame->data,
                    pAVFrame->linesize,
                    0,
                    videoHeight,
                    pAVPicture->data,
                    pAVPicture->linesize
                    );



         //  qDebug()<<".";

           *h=videoHeight;
           *w=videoWidth;

           *data=pAVPicture;

           emit new_frame(URL);

           if(m_running==Mode::Snapshot){
               m_running=Mode::TurnOff;
           }
/*
           *img=QImage(pAVPicture->data[0],
                       videoWidth,
                       videoHeight,
                       QImage::Format_RGB32);



           if(m_running==mode::Snapshot){
               m_running=mode::doNothing;
           }
*/


   }

//   av_packet_free(&packet);
   av_packet_unref(packet);
   return true;
}


void Runner::run()
{
    qDebug()<<"run";
av_log_set_level(AV_LOG_QUIET);
prev=clock();

 local_mutex.lock();
load();
if (!load_settings()){
    qDebug()<<"001";
    emit lost_connection(URL);
    emit  finished();
    local_mutex.unlock();
    return;
}
local_mutex.unlock();


prev=clock();

pFormatCtx->interrupt_callback.callback=interrupt_cb;
pFormatCtx->interrupt_callback.opaque = this;


if(m_running==Mode::LiveStreaming||m_running==Mode::StorageStreaming){
    emit playing();
}

int frame_cnt=0;



while(m_running!=Mode::TurnOff){

   prev=clock();

   if (!capture()){
       qDebug()<<"002";
       emit lost_connection(URL);
       emit  finished();
       return;
   }
//qDebug()<<"1235";
 //  qDebug()<<"count "<<frame_cnt++;


}
qDebug()<<"finished";
emit finished();

return;



}

void Runner::close()
{
free_settings();
free();

}



void Runner::setRunning(int running)
{
    if (m_running == running){
        return;
    }
    m_running = running;

    qDebug()<<"Runner::setRunning "<<running;

    emit runningChanged(running);
}

