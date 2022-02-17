#include "runner.h"
#define AVIO_FLAG_NONBLOCK   8
Runner::Runner( QObject *parent) : QObject(parent)
{
this->str=str;



    m_running=true;
}

bool Runner::running() const
{

}

int Runner::interrupt_cb(void *ctx)
{
  //  qDebug()<<"[timeout]";
    Runner* pl=(Runner*)ctx;

    clock_t delay=clock()-pl->prev;

  //  qDebug()<<"delay: "<<delay;



        if(delay>50000)
        {

            pl->prev=clock();
            qDebug()<<"[TIMEOUT]";
            emit pl->lost_connection(pl->URL);
            pl->m_running=mode::turnOff;


       //     return 1;
}


    return 0;

}

void Runner::run()
{

        qDebug()<<"RUN";
        prev=clock();
        //variable
        AVFormatContext *pFormatCtx;

        QString str ("rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.17/SourceEndpoint.video:0:0");

        QString str1 = "rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0";
      //  URL="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0";
        QByteArray ba = URL.toLatin1();
        char *c_str2 = ba.data();

          char *filepath = ba.data();



        av_register_all();

        avformat_network_init();

        pFormatCtx = avformat_alloc_context();







        AVDictionary* options = NULL;
    //1024000
    //425984
        av_dict_set(&options, "buffer_size", "1024000", 0); //Set the cache size, 1080p can increase the value
        av_dict_set(&options, "rtsp_transport", "udp", 0); //Open in udp mode, if open in tcp mode, replace udp with tcp
        av_dict_set(&options, "stimeout", "200000", 0); //Set timeout disconnect time, unit is microsecond "20000000"
        av_dict_set(&options, "max_delay", "50", 0); //Set the maximum delay

     //   av_dict_set_int(&options, "stimeout", (int64_t)10, 0);
   //    av_dict_set_int(&options, "timeout", (int64_t)10, 0);
       //       av_dict_set_int(&options, "rw_timeout", (int64_t)10, 0);

        if (avformat_open_input(&pFormatCtx, filepath, NULL, &options) != 0)
        {
            qDebug()<<"=================Couldn't open input stream.\n";
            emit lost_connection(URL);
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
            emit lost_connection(URL);
            emit finished();
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
            emit lost_connection(URL);
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
                emit lost_connection(URL);

            qDebug()<<" 4 error ";
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
                emit lost_connection(URL);
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
             prev=clock();
            pFormatCtx->interrupt_callback.callback=interrupt_cb;
            pFormatCtx->interrupt_callback.opaque = this;


            if(m_running==mode::Streaming){

                emit playing();
            }

           while(m_running!=mode::turnOff)
           {
               qDebug()<<"averror "<<AVERROR(EAGAIN);

    qDebug()<<"..."<<clock();
                prev=clock();
               int res=(av_read_frame(pFormatCtx, packet));
               qDebug()<<"res "<<res;
                 if(res<0){
                     emit lost_connection(URL);
                     emit finished();
                     return;
                 }
                      qDebug()<<"     1";
                if (packet->stream_index == videoindex)
                {
                        qDebug()<<"     2";
                    //qDebug()<<"pts : %d     size :%d one pkt\n",packet->pts,packet->size);
                    //fwrite(packet->data, 1, packet->size, fpSave);
                //    qDebug() << "pkt pts:" << packet->pts;
                    ret = avcodec_decode_video2(pAVCodecContext, pAVFrame, &m_i_frameFinished, packet);
                    if(ret < 0)
                    {
                            qDebug()<<"     3";
                        qDebug() << "Decoding failed!!";
                        emit lost_connection(URL);
                        emit finished();
                        return;
                    }
                    if (m_i_frameFinished)
                    {
                            qDebug()<<"     4";

                        sws_scale(pSwsContext,(const uint8_t* const *)pAVFrame->data,pAVFrame->linesize,0,videoHeight,pAVPicture.data,pAVPicture.linesize);
                        //Send to get a frame of image signal

                        *img=QImage(pAVPicture.data[0],videoWidth,videoHeight,QImage::Format_RGB32);



                   //     qDebug() << image.size();
                     //   image.save("/home/gleb/img","jpg",-1);
                       // img=image;
                        emit new_frame();
                        /*
                        if(m_running==mode::Snapshot){
                            m_running=mode::turnOff;
                        }
                        */
                   //     emit sig_GetOneFrame(image);
                   //     qDebug() << "emit!!!!!";
                    }
                        qDebug()<<"     5";
                 }
                    qDebug()<<"     6";

             }
        qDebug()<<"     7";

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
            return;


    /*
    count = 0;
    qDebug()<<"RUN "<<str;
    // Переменная m_running отвечает за работу объекта в потоке.
    // При значении false работа завершается
    while (m_running)
    {
        if(count<100000000){
        count++;
        }else{
                 qDebug()<<str;
            count=0;
        }
  //      emit sendMessage(m_message); // Высылаем данные, которые будут передаваться в другой поток
  //      qDebug() << m_message << " " << m_message_2 << " " << count;

    }
    qDebug()<<"finished "<<str;
    //emit finished();
    */
}


void Runner::setRunning(bool running)
{
    if (m_running == running){
        return;
    }
    m_running = running;

    emit runningChanged(running);
}


//https://patchwork.ffmpeg.org/project/ffmpeg/patch/ba124bc7-9436-703b-e8b8-c5a4459243c3@gmail.com/#48088
/*
int m_av_read_frame(AVFormatContext *s, AVPacket *pkt)
 {
     const int genpts = s->flags & AVFMT_FLAG_GENPTS;
     int          eof = 0;
     int ret;
     AVStream *st;

     if (!genpts) {
         ret = s->packet_buffer ?
             read_from_packet_buffer(&s->packet_buffer, &s->packet_buffer_end, pkt) :
             read_frame_internal(s, pkt);
         if (ret < 0)
             return ret;
         goto return_packet;
     }

     for (;;) {
         AVPacketList *pktl = s->packet_buffer;

         if (pktl) {
             AVPacket *next_pkt = &pktl->pkt;

             if (next_pkt->dts != AV_NOPTS_VALUE) {
                 int wrap_bits = s->streams[next_pkt->stream_index]->pts_wrap_bits;
                 // last dts seen for this stream. if any of packets following
                 // current one had no dts, we will set this to AV_NOPTS_VALUE.
                 int64_t last_dts = next_pkt->dts;
                 while (pktl && next_pkt->pts == AV_NOPTS_VALUE) {
                     if (pktl->pkt.stream_index == next_pkt->stream_index &&
                         (av_compare_mod(next_pkt->dts, pktl->pkt.dts, 2LL << (wrap_bits - 1)) < 0)) {
                         if (av_compare_mod(pktl->pkt.pts, pktl->pkt.dts, 2LL << (wrap_bits - 1))) { //not b frame
                             next_pkt->pts = pktl->pkt.dts;
                         }
                         if (last_dts != AV_NOPTS_VALUE) {
                             // Once last dts was set to AV_NOPTS_VALUE, we don't change it.
                             last_dts = pktl->pkt.dts;
                         }
                     }
                     pktl = pktl->next;
                 }
                 if (eof && next_pkt->pts == AV_NOPTS_VALUE && last_dts != AV_NOPTS_VALUE) {
                     // Fixing the last reference frame had none pts issue (For MXF etc).
                     // We only do this when
                     // 1. eof.
                     // 2. we are not able to resolve a pts value for current packet.
                     // 3. the packets for this stream at the end of the files had valid dts.
                     next_pkt->pts = last_dts + next_pkt->duration;
                 }
                 pktl = s->packet_buffer;
             }


             if (!(next_pkt->pts == AV_NOPTS_VALUE &&
                   next_pkt->dts != AV_NOPTS_VALUE && !eof)) {
                 ret = read_from_packet_buffer(&s->packet_buffer,
                                                &s->packet_buffer_end, pkt);
                 goto return_packet;
             }
         }

         ret = read_frame_internal(s, pkt);
         if (ret < 0) {
             if (pktl && ret != AVERROR(EAGAIN)) {
                 eof = 1;
                 continue;
             } else
                 return ret;
         }

         if (av_dup_packet(add_to_pktbuf(&s->packet_buffer, pkt,
                           &s->packet_buffer_end)) < 0)
             return AVERROR(ENOMEM);
     }

 return_packet:

     st = s->streams[pkt->stream_index];
     if (st->skip_samples) {
         uint8_t *p = av_packet_new_side_data(pkt, AV_PKT_DATA_SKIP_SAMPLES, 10);
         AV_WL32(p, st->skip_samples);
         av_log(s, AV_LOG_DEBUG, "demuxer injecting skip %d\n", st->skip_samples);
         st->skip_samples = 0;
     }

     if ((s->iformat->flags & AVFMT_GENERIC_INDEX) && pkt->flags & AV_PKT_FLAG_KEY) {
         ff_reduce_index(s, st->index);
         av_add_index_entry(st, pkt->pos, pkt->dts, 0, 0, AVINDEX_KEYFRAME);
     }

     if (is_relative(pkt->dts))
         pkt->dts -= RELATIVE_TS_BASE;
     if (is_relative(pkt->pts))
         pkt->pts -= RELATIVE_TS_BASE;

     return ret;
 }
 */


