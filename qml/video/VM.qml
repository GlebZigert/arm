import QtQuick 2.0
import QtMultimedia 5.11
import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5

import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5


import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import QtQuick 2.0

Item {
    id: container

    property string current_dt: ""


    property string url_livestream: ""
    property string url_storagestream: ""
    property string url_snapshot: ""
    property string current_camera:""
    property int flag
    property int count
    signal send_stream(MediaPlayer src)
    signal playing()
    signal live_playing()


    Timer {
        id:timer
        interval: 50; running: true; repeat: true
        onTriggered:
        {

        //    if(live_player.status==)
        //    if((live_player.error==1)||
        //            (live_player.hasVideo==false)
         //       )
         //   {
            /*
        console.log(".")
        console.log(".")
        console.log(".")
        console.log(".")
        console.log(".")
        console.log(".")
            console.log("live_player.source: ",live_player.source)
            console.log("live_player.status: ",live_player.status)
            console.log("live_player.playbackState: ",live_player.playbackState)
            console.log("live_player.hasVideo: ",live_player.hasVideo)
            console.log("live_player.error: ",live_player.error)
            console.log("live_player.errorString: ",live_player.errorString)
            console.log("live_player.availability: ",live_player.availability)
         console.log(".")
         console.log(".")
         console.log(".")
         console.log(".")
         console.log(".")
         console.log(".")
*/
            if((live_player.error==1)||
               (live_player.hasVideo==false))
            {
                count++
         // console.log(".......................count ",count )
                if(count>41)
                {
                    if(current_camera==""){
                      background.source="check_camera.jpeg"
                    }else{
                    background.source="no_signal.jpeg"
                }
                    live_videoOutput.visible=false
                    image.visible=false
                    storage_videoOutput.visible=false
                    background.visible=true

                set_live_stop()


                }
                if(count>100)
                {
                count=0
            //    set_live_play()
                    live_player.source=url_livestream
                    live_player.play()
                }

            }

     //   }

        }
    }




    //       width: parent.width
    //       height: parent.height

       MediaPlayer {
            id: storage_player

            autoPlay: false



            onPlaying: {
            container.playing()
                storage_videoOutput.visible=true

                live_videoOutput.visible=false
                image.visible=false

                //console.log("[playing]")
            }





        }
       MediaPlayer {
            id: live_player



            autoPlay: false

            onPlaying: {


console.log("[LIVE playing]")

                if(live_player.source!="")
                {

            container.live_playing()

                    live_videoOutput.visible=true
                    image.visible=false
                    storage_videoOutput.visible=false
                    background.visible=false
             //   live_videoOutput.visible=true
            //    image.visible=false
            //    storage_videoOutput.visible=false
            //console.log("[LIVE playing]")

            }
            }

            onStopped:{
                /*
                 console.log(" ")
                    console.log(" ")
                    console.log(" ")
                    console.log(" ")
                    console.log("onStopped ")
                    console.log(" ")
                    console.log(" ")
                    console.log(" ")
                    console.log(" ")
                live_player.source=""
                live_player.play()
                */


            }

            onPlaybackStateChanged:{
            /*  console.log(" ")
                console.log(" ")
                console.log(" ")
                console.log(" ")
                console.log("onPlaybackStateChanged ", live_player.playbackState)
                console.log(" ")
                console.log(" ")
                console.log(" ")
                console.log(" ")*/
            }


        }


Rectangle{

  //  anchors.fill:parent

    clip:true

    x:(parent.width- width)/2
    width: (height/1080)*1920


    height: parent.height

    color: "lightgray"


Rectangle{
    id: rect
    width: parent.width
    height: parent.height
    clip:true


    VideoOutput {
        id: storage_videoOutput
        source: storage_player

        visible: false



        anchors.fill:parent
        //---------------------------------------------------------------------
         fillMode: VideoOutput.PreserveAspectCrop


                    MouseArea {
                        anchors.fill: parent
                        property double factor: 2.0
                        onWheel:
                        {
                              //console.log("---------------------" )
                            if(wheel.angleDelta.y > 0)  // zoom in
                                var zoomFactor = factor
                            else                        // zoom out
                                zoomFactor = 1/factor

         //console.log("zoomFactor ",zoomFactor )

                    }

                        onEntered: {
                            //console.log("[onEntered 2]")
                            Tlmtr.capture_session(point)

                        //    mouse.accepted = false


                        }

                    }
}

    VideoOutput {

        id: live_videoOutput
        source: live_player

        visible: false



        anchors.fill:parent
        //---------------------------------------------------------------------
         fillMode: VideoOutput.PreserveAspectCrop


                    MouseArea {
                        anchors.fill: parent
                        property double factor: 2.0
                        onWheel:
                        {
                              //console.log("---------------------" )
                            if(wheel.angleDelta.y > 0)  // zoom in
                                var zoomFactor = factor
                            else                        // zoom out
                                zoomFactor = 1/factor

         //console.log("zoomFactor ",zoomFactor )

                    }

                        onEntered: {
                            //console.log("[onEntered 1]")
                            //Tlmtr.capture_session(point)
                           // timer.start()
                        //    mouse.accepted = false


                        }
                    }
}


    Image {
        id: background

        anchors.fill: parent
          visible: true

        //  source:"http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0"

                            fillMode: VideoOutput.PreserveAspectCrop


          }


    Image {
        id: image

        anchors.fill: parent
          visible: false

                            fillMode: VideoOutput.PreserveAspectCrop


          }


    }

}



        Component.onCompleted: {



            set_live_play()
            background.source="http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0"


        }

function reload_livestream()
{


}

function set_live_stop(){
 //   console.log("..............................[set_live_stop]")
 //   live_player.pause()
 //   live_player.stop()
    live_player.source="no any fucking source"
    live_player.play()


}

function set_live_play(){
    timer.start()
    count=0
 //   timer.stop()
//    set_live_stop()
 /*
        console.log("..............................[set_live_play]")
    console.log("live_player.source: ",live_player.source)
    console.log("live_player.status: ",live_player.status)
    console.log("live_player.playbackState: ",live_player.playbackState)
    console.log("live_player.hasVideo: ",live_player.hasVideo)
    console.log("live_player.error: ",live_player.error)
    console.log("live_player.errorString: ",live_player.errorString)
    console.log("live_player.availability: ",live_player.availability)
*/
    current_camera=live_player.source

    background.visible=false

 //   live_player.stop()

    live_player.source=url_livestream

  console.log("..............................url_livestream: ",url_livestream)
    live_player.play()

    live_videoOutput.visible=true
    image.visible=false
    storage_videoOutput.visible=false
    background.visible=false



console.log("[LIVE playing]")
    var pb=live_player.playbackState
    //console.log("playbackState:", pb)


    console.log("live_player.hasVideo: ",live_player.hasVideo)


        }


function set_live_pause(){
    timer.stop()
        //console.log("..............................[set_live_pause]")

        live_player.pause()


        }

function set_storage_pause(dt){
    timer.stop()
        console.log("..............................[set_storage_pause]")



            var pb=storage_player.playbackState
            console.log("playbackState:", pb)


            if(pb==2)
            {


                if(container.flag==1)
                 container.flag=0
                else
                {
                 storage_videoOutput.visible=false
                background.visible=true
                }
                 image.visible=false

                //console.log("current_dt!=dt")

                background.source=image.source
          //      background.visible=true

        //        image.source=""
                image.source=url_snapshot

                if(image.source=="")
                {
                    image.source="no_in_storage"
                background.source="no_in_storage"
                }



                //console.log(image.source)
                image.visible=true

            //    background.visible=false




            }
            else            {



            storage_videoOutput.visible=true
            storage_player.pause()

            background.visible=false
        //    live_videoOutput.visible=false
            image.visible=false
                container.flag=1
            }
  image.visible=true
        //    background.visible=false


        }

function clear_storage_player(){
storage_player.source=""
}

 function set_storage_play(dt,speed){
     timer.stop()
       console.log("..............................[set_storage_play]")



     if(url_storagestream=="")
     {
         image.source="no_in_storage"
     background.source="no_in_storage"
         image.source="no_in_storage"
         background.visible=true
     }
     else
     {

    background.visible=false

       //     storage_player.stop()

        //    storage_player.play()
       //     storage_player.stop()


            var pb=storage_player.playbackState
            //console.log("playbackState:", pb)


            if(pb==2)
            {

               storage_player.play()

            }



           storage_player.source=url_storagestream



            storage_player.play()

            storage_videoOutput.visible=true
            live_videoOutput.visible=false
            image.visible=false


            //console.log(storage_player.source)
            //console.log(storage_player.status)








        //    storage_videoOutput.visible=false

        }
}

}
