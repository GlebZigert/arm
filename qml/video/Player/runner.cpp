#include "runner.h"
#include "QDebug"
#define AVIO_FLAG_NONBLOCK   8
AVDictionary* options;

Runner::Runner( QObject *parent) : QObject(parent)
{
     pAVCodecContext = NULL;
     pAVFrame = NULL;
      pSwsContext = NULL;
     pAVPicture = NULL;
     pAVCodec = NULL;
     packet = NULL;
     pFormatCtx = NULL;
     options = NULL;
     param = NULL;

    av_log_set_level(AV_LOG_QUIET);
    this->str=str;
    m_running=true;
}

Runner::~Runner()
{
    qDebug()<<"DELETE Runner "<<this->URL;
close();

}

int Runner::running() const
{

}

int Runner::interrupt_cb(void *ctx)
{
    Runner* pl=(Runner*)ctx;
    clock_t delay=clock()-pl->prev;
    if(delay>150000){
        pl->prev=clock();
        emit pl->lost_connection(pl->URL);
        pl->m_running=mode::turnOff;
        return 1;
    }
    return 0;

}


void Runner::run()
{

prev=clock();

QByteArray ba = URL.toLatin1();
char *c_str2 = ba.data();
char *filepath = ba.data();
av_register_all();
avformat_network_init();
pFormatCtx = avformat_alloc_context();


av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
av_dict_set(&options, "stimeout", "200000", 0); //Set timeout disconnect time, unit is microsecond "20000000"
av_dict_set(&options, "max_delay", "50", 0); //Set the maximum delay

prev=clock();
pFormatCtx->interrupt_callback.callback=interrupt_cb;
pFormatCtx->interrupt_callback.opaque = this;


if (avformat_open_input(&pFormatCtx, filepath, NULL, &options) != 0){
    emit lost_connection(URL);
    emit finished();

    return;
}

pFormatCtx->probesize = 1000;
pFormatCtx->max_analyze_duration = AV_TIME_BASE;

if (avformat_find_stream_info(pFormatCtx, NULL)<0){
    emit lost_connection(URL);
    emit finished();

    return;
}

int videoindex = -1;
for (int i = 0; i<pFormatCtx->nb_streams; i++)

if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
    videoindex = i;
    break;
}


if (videoindex == -1){
    emit lost_connection(URL);
    emit finished();

    return;
}

av_dump_format(pFormatCtx, 0, filepath,0);


//pAVCodecContext = pFormatCtx->streams[0]->codec;

param = avcodec_parameters_alloc();
pAVCodecContext = avcodec_alloc_context3(NULL);
pAVCodec = avcodec_find_decoder(pFormatCtx->streams[0]->codec->codec_id);

avcodec_parameters_from_context(param, pFormatCtx->streams[0]->codec);
avcodec_parameters_to_context(pAVCodecContext, param);

int videoWidth=pAVCodecContext->width;
int videoHeight=pAVCodecContext->height;
qDebug()<<"avpicture_alloc 1";
pAVPicture = new AVPicture();
avpicture_alloc(pAVPicture,AV_PIX_FMT_RGB32,videoWidth,videoHeight);
qDebug()<<"avpicture_alloc 2";

//pAVCodec = avcodec_find_decoder(pAVCodecContext->codec_id);

if((videoWidth==0)&&(videoHeight==0)){
    emit lost_connection(URL);
    emit finished();

    return;
}

pSwsContext = sws_getContext(videoWidth,videoHeight,pAVCodecContext->pix_fmt,videoWidth,videoHeight,AV_PIX_FMT_RGB32,SWS_BICUBIC,0,0,0);
pAVCodecContext->thread_count=10;
int result=avcodec_open2(pAVCodecContext,pAVCodec,NULL);

if (result<0){
    emit lost_connection(URL);
    emit finished();

    return;
}

pAVFrame = av_frame_alloc();
int y_size = pAVCodecContext->width * pAVCodecContext->height;
packet = (AVPacket *) malloc(sizeof(AVPacket));
av_init_packet(packet);
int m_i_frameFinished =-1;
int ret =-1;


if(m_running==mode::Streaming){
    emit playing();
}
int res;

while(m_running!=mode::turnOff){

    prev=clock();


    res=(av_read_frame(pFormatCtx, packet));




    if(res<0){
        emit lost_connection(URL);
        emit finished();


        return;
    }
int used=0;
int got_frame=0;
    if (packet->stream_index == videoindex){
     // ret = avcodec_decode_video2(pAVCodecContext, pAVFrame, &m_i_frameFinished, packet);

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

        if(got_frame < 0){
        emit lost_connection(URL);
            emit finished();


            return;
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

       //     for(int i=0;i<1000;i++)
            *img=QImage(pAVPicture->data[0],
                        videoWidth,
                        videoHeight,
                        QImage::Format_RGB32);

            emit new_frame(URL);


            if(m_running==mode::Snapshot){
                m_running=mode::turnOff;
            }
        }


    }

 //    av_packet_unref(packet);

     av_packet_unref(packet);
     av_frame_unref(pAVFrame);


}



emit finished();

return;



}

void Runner::close()
{

    if(options){
qDebug()<<"  av_dict_free(&options);";
        av_dict_free(&options);
    }





     if(param)   {
    qDebug()<<"  avcodec_parameters_free(&param);";
    avcodec_parameters_free(&param);
     }

     if(pAVCodecContext){
             qDebug()<<" avcodec_free_context(&pAVCodecContext);";
    avcodec_free_context(&pAVCodecContext);
     }




    if(packet){
qDebug()<<"av_packet_unref(packet);";
    av_packet_unref(packet);
qDebug()<<"av_packet_free(&packet);";
    av_packet_free(&packet);
qDebug()<<"av_free(packet);)";
    av_free(packet);

    }

        if(pFormatCtx){
            qDebug()<<"avformat_close_input(&pFormatCtx);";
        avformat_close_input(&pFormatCtx);
        }






    if(pAVFrame){
    *img=QImage();
        qDebug()<<"av_frame_free(&pAVFrame);";
    av_frame_free(&pAVFrame);
    qDebug()<<"av_free(pAVFrame);";
    av_free(pAVFrame);
    }

    if(pSwsContext){
        qDebug()<<"sws_freeContext(pSwsContext);";
    sws_freeContext(pSwsContext);
    }



        qDebug()<<"avpicture_free";
      //  qDebug()<<"sizeof avpicture "<<sizeof (pAVPicture);

if(pAVPicture){
    qDebug()<<"avpicture_free(pAVPicture);";
     avpicture_free(pAVPicture);
qDebug()<<"av_free(pAVPicture);";
    av_free(pAVPicture);
}


}



void Runner::setRunning(bool running)
{
    if (m_running == running){
        return;
    }
    m_running = running;

    emit runningChanged(running);
}





