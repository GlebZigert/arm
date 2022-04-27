#include "runner.h"
#include "QDebug"
#define AVIO_FLAG_NONBLOCK   8
Runner::Runner( QObject *parent) : QObject(parent)
{
    av_log_set_level(AV_LOG_QUIET);
    this->str=str;
    m_running=true;
}

Runner::~Runner()
{
    qDebug()<<"DELETE Runner "<<this->URL;


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
AVDictionary* options = NULL;

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
    close();
    return;
}

pFormatCtx->probesize = 1000;
pFormatCtx->max_analyze_duration = AV_TIME_BASE;

if (avformat_find_stream_info(pFormatCtx, NULL)<0){
    emit lost_connection(URL);
    emit finished();
    close();
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
    close();
    return;
}

av_dump_format(pFormatCtx, 0, filepath,0);


pAVCodecContext = pFormatCtx->streams[0]->codec;
int videoWidth=pAVCodecContext->width;
int videoHeight=pAVCodecContext->height;
qDebug()<<"avpicture_alloc 1";
pAVPicture = new AVPicture();
avpicture_alloc(pAVPicture,AV_PIX_FMT_RGB32,videoWidth,videoHeight);
qDebug()<<"avpicture_alloc 2";

pAVCodec = avcodec_find_decoder(pAVCodecContext->codec_id);

if((videoWidth==0)&&(videoHeight==0)){
    emit lost_connection(URL);
    emit finished();
    close();
    return;
}

pSwsContext = sws_getContext(videoWidth,videoHeight,pAVCodecContext->pix_fmt,videoWidth,videoHeight,AV_PIX_FMT_RGB32,SWS_BICUBIC,0,0,0);
pAVCodecContext->thread_count=10;
int result=avcodec_open2(pAVCodecContext,pAVCodec,NULL);

if (result<0){
    emit lost_connection(URL);
    emit finished();
    close();
    return;
}

pAVFrame = av_frame_alloc();
int y_size = pAVCodecContext->width * pAVCodecContext->height;
packet = (AVPacket *) malloc(sizeof(AVPacket));
av_new_packet(packet, y_size);
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

        close();
        return;
    }

    if (packet->stream_index == videoindex){
        ret = avcodec_decode_video2(pAVCodecContext, pAVFrame, &m_i_frameFinished, packet);

        if(ret < 0){
        emit lost_connection(URL);
            emit finished();

            close();
            return;
        }

        if (m_i_frameFinished){

            sws_scale(pSwsContext,
                      (const uint8_t* const *)pAVFrame->data,
                      pAVFrame->linesize,
                      0,
                      videoHeight,
                      pAVPicture->data,
                      pAVPicture->linesize
                      );

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


}

close();

emit finished();

return;



}

void Runner::close()
{

    av_free_packet(packet);

    qDebug()<<"1";
    avcodec_close(pAVCodecContext);
    qDebug()<<"2";
    av_packet_unref(packet);
    qDebug()<<"3";
    if(pFormatCtx){
        avformat_close_input(&pFormatCtx);
    }
    qDebug()<<"4";
 //   avpicture_alloc(&pAVPicture,AV_PIX_FMT_RGB32,videoWidth,videoHeight);
 //

    qDebug()<<"5";

    av_frame_free(&pAVFrame);
    qDebug()<<"6";
    sws_freeContext(pSwsContext);
    qDebug()<<"7";
    av_free(pAVFrame);
    qDebug()<<"8";

        qDebug()<<"avpicture_free";
      //  qDebug()<<"sizeof avpicture "<<sizeof (pAVPicture);
   // avpicture_free(&pAVPicture);

    qDebug()<<"9";

}



void Runner::setRunning(bool running)
{
    if (m_running == running){
        return;
    }
    m_running = running;

    emit runningChanged(running);
}





