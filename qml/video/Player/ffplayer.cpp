#include "ffplayer.h"
#include <QImage>
#include <QDebug>
#include <time.h>

#define AVIO_FLAG_NONBLOCK   8

FFPlayer::FFPlayer(QObject *parent) :  QObject(parent)
{
    /*
    AVHWDeviceType hwtype = AV_HWDEVICE_TYPE_NONE;
     while ((hwtype = av_hwdevice_iterate_types(hwtype)) !=
                             AV_HWDEVICE_TYPE_NONE)
     {
         printf("%s\n", av_hwdevice_get_type_name(hwtype));
     }
     */

}



int FFPlayer::func(void *ctx)
{
    emit finished();
}

int FFPlayer::interrupt_cb(void *ctx)
{
  //  qDebug()<<"[timeout]";
    FFPlayer* pl=(FFPlayer*)ctx;

    clock_t delay=clock()-pl->prev;

   // qDebug()<<"delay: "<<delay;



        if(delay>1000000)
        {
            qDebug()<<"[TIMEOUT]";
            emit pl->lost_connection();
            pl->m_running=mode::turnOff;
            return 1;
}


    return 0;

}


void FFPlayer::run()
{
    qDebug()<<"RUN";
    prev=clock();
    //variable
    AVFormatContext *pFormatCtx;

    QString str ("rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.17/SourceEndpoint.video:0:0");

    QString str1 = "rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.17/SourceEndpoint.video:0:0";
    QByteArray ba = URL.toLatin1();
    char *c_str2 = ba.data();

//    qDebug()<<"URL: "<<URL;


  //  char *filepath = "rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.17/SourceEndpoint.video:0:0";
    char *filepath = ba.data();
    //AVPacket *packet;
    //initialization


    av_register_all();

    avformat_network_init();

    pFormatCtx = avformat_alloc_context();


    qDebug()<<"     1";
        pFormatCtx->interrupt_callback.callback=interrupt_cb;
        pFormatCtx->interrupt_callback.opaque = this;
    qDebug()<<"     2";


    AVDictionary* options = NULL;
//1024000
//425984
    av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
    av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
    av_dict_set(&options, "stimeout", "200000", 0); //Set timeout disconnect time, unit is microsecond "20000000"
    av_dict_set(&options, "max_delay", "50", 0); //Set the maximum delay


/*
    av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
    av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
    av_dict_set(&options, "stimeout", "20000000", 0); //Set timeout disconnect time, unit is microsecond
    av_dict_set(&options, "max_delay", "500", 0); //Set the maximum delay
*/


    /*
    av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
    av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
    av_dict_set(&options, "stimeout", "20000000", 0); //Set timeout disconnect time, unit is microsecond
    av_dict_set(&options, "max_delay", "5000000", 0); //Set the maximum delay
    */


    //av_dict_set(&options, "fps", "30", 0); //Set the number of frames
    //packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    //Open network stream or file stream
    if (avformat_open_input(&pFormatCtx, filepath, NULL, &options) != 0)
    {
        qDebug()<<"=================Couldn't open input stream.\n";
        emit lost_connection();
        emit finished();
        return;
    }


    //Find stream information
    //Set search time to avoid taking too long
    pFormatCtx->probesize = 1000;
    pFormatCtx->max_analyze_duration = AV_TIME_BASE;
    if (avformat_find_stream_info(pFormatCtx, NULL)<0)
    {
        qDebug()<<"Couldn't find stream information.\n";
        emit finished();
        emit lost_connection();
        return;
    }

    //Find if there is a video stream in the code stream
    int videoindex = -1;
    for (int i = 0; i<pFormatCtx->nb_streams; i++)
        if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO)
        {
            videoindex = i;
            break;
        }

    if (videoindex == -1)
    {
        qDebug()<<"Didn't find a video stream.\n";
        emit lost_connection();
        emit finished();
        return;
    }
    qDebug()<<"-----------rtsp stream input information --------------\n";
    av_dump_format(pFormatCtx, 0, filepath,0);
    qDebug()<<"---------------------------------------\n";
    /*********************************************/
    AVCodecContext *pAVCodecContext;
       AVFrame *pAVFrame;
       SwsContext * pSwsContext;
       AVPicture  pAVPicture;
    //Get the resolution size of the video stream
        pAVCodecContext = pFormatCtx->streams[0]->codec;
        int videoWidth=pAVCodecContext->width;
        int videoHeight=pAVCodecContext->height;


        avpicture_alloc(&pAVPicture,AV_PIX_FMT_RGB32,videoWidth,videoHeight);

        AVCodec *pAVCodec;

        //Get the video stream decoder
        pAVCodec = avcodec_find_decoder(pAVCodecContext->codec_id);
     //   pAVCodec = avcodec_find_decoder("h264_qsv");


        qDebug()<<"videoWidth: "<<videoWidth;
        qDebug()<<"videoHeight: "<<videoHeight;
        if((videoWidth==0)&&(videoHeight==0))
        {
            qDebug()<<"Failed just failed";
            emit lost_connection();
            emit finished();
            return;

        }
        pSwsContext = sws_getContext(videoWidth,videoHeight,pAVCodecContext->pix_fmt,videoWidth,videoHeight,AV_PIX_FMT_RGB32,SWS_BICUBIC,0,0,0);
        qDebug()<<"[12]";
        //Open the corresponding decoder
        pAVCodecContext->thread_count=10;
        int result=avcodec_open2(pAVCodecContext,pAVCodec,NULL);

        if (result<0){
            qDebug()<<"Failed to open decoder";
            emit lost_connection();
            emit finished();
            return;
        }

        pAVFrame = av_frame_alloc();


        int y_size = pAVCodecContext->width * pAVCodecContext->height;
            AVPacket *packet = (AVPacket *) malloc(sizeof(AVPacket)); //Assign a packet
            av_new_packet(packet, y_size); //Assign packet data
        qDebug()<<"Successfully initialized video stream" <<","<<videoWidth << "," << videoHeight << "," ;
    //
      //  return;
    //Save video stream for a period of time and write to file
    //FILE  * fpSave;
    //fopen_s(&fpSave, "geth264.h264", "wb");
        int m_i_frameFinished =-1;
        int ret =-1;
// for (int i = 0; i <1000; i++) // here can adjust the size of i to change the video time in the file
//    {
        if(m_running==mode::Streaming){

            emit playing();
        }

       while(m_running!=mode::turnOff)
       {

//qDebug()<<"     01";
            prev=clock();
           int res=(av_read_frame(pFormatCtx, packet));
         //          qDebug()<<res;

              //    qDebug()<<"     1";
            if (packet->stream_index == videoindex)
            {
                //    qDebug()<<"     2";
                //qDebug()<<"pts : %d     size :%d one pkt\n",packet->pts,packet->size);
                //fwrite(packet->data, 1, packet->size, fpSave);
            //    qDebug() << "pkt pts:" << packet->pts;
                ret = avcodec_decode_video2(pAVCodecContext, pAVFrame, &m_i_frameFinished, packet);
                if(ret < 0)
                {
                 //       qDebug()<<"     3";
                    qDebug() << "Decoding failed!!";
                    emit lost_connection();
                    emit finished();
                    return;
                }
                if (m_i_frameFinished)
                {
                   //     qDebug()<<"     4";

                    sws_scale(pSwsContext,(const uint8_t* const *)pAVFrame->data,pAVFrame->linesize,0,videoHeight,pAVPicture.data,pAVPicture.linesize);
                    //Send to get a frame of image signal

                    img=QImage(pAVPicture.data[0],videoWidth,videoHeight,QImage::Format_RGB32);



               //     qDebug() << image.size();
                 //   image.save("/home/gleb/img","jpg",-1);
                   // img=image;
                    emit new_frame();
                    if(m_running==mode::Snapshot){
                        m_running=mode::turnOff;
                    }
               //     emit sig_GetOneFrame(image);
               //     qDebug() << "emit!!!!!";
                }
                 //   qDebug()<<"     5";
             }
              //  qDebug()<<"     6";

         }
   // qDebug()<<"     7";

       // av_packet_unref(packet);
        av_free_packet(packet);
      //   msleep(0.02);
    //}

      //}
       // fclose(fpSave);
        if(pFormatCtx){
            //    qDebug()<<"     8";
            avformat_close_input(&pFormatCtx);
             //   qDebug()<<"     1";
        }
         //   qDebug()<<"     9";
        //av_free(packet);
        av_frame_free(&pAVFrame);
        sws_freeContext(pSwsContext);
        av_free(pAVFrame);
        //  qDebug()<<"is end  !!! \n");
        qDebug()<<"[finished]";
        emit finished();
}
mode FFPlayer::running() const
{
    return m_running;
}


void FFPlayer::setRunning(mode running)
{
    if (m_running == running)
        return;

    m_running = running;
    qDebug()<<"m_running: "<<m_running;
    emit runningChanged(running);
}













