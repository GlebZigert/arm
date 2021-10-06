import QtQuick 2.11
import QtQuick.Window 2.11
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
    anchors.fill: parent


    visible: true
    width: 640
    height: 480



    Timer {
        id:timer
        interval: 100; running: true; repeat: true
        onTriggered:
        {

           console.log(player.status," ",player.hasVideo)

        }
    }
    MediaPlayer {
         id: player

         autoPlay: true

         notifyInterval: 10

      //   source:"rtsp://root:root@192.168.0.253:50554/hosts/AXXON253/DeviceIpint.4/SourceEndpoint.video:0:0"

         onPlaying: {


             //console.log("[playing]")
         }


     }

SplitView{
      anchors.fill:parent

       orientation: Qt.Vertical



    Rectangle{
    id: rect1
    width: parent.width
    color: "yellow"
     height: 400
     VideoOutput {

         id: live_videoOutput
         source: player
         visible: true
        anchors.fill: parent

       height: 500
         //---------------------------------------------------------------------
          fillMode: VideoOutput.PreserveAspectCrop

                     MouseArea {
                         anchors.fill: parent
                         property double factor: 2.0

                     }
         }

    }



SplitView{
    id: row
    width: parent.width
  //  color: "green"
     height: 100
        orientation: Qt.Horizontal


     Rectangle{
     id: rect01
     width: 300
     color: "green"
      height:100

      TextInput {
          id:urlInput
          anchors.fill: parent
          text: "Hello";
          font.capitalization: Font.AllLowercase

      }
     }

     Rectangle{
     id: rect02
     width: 100
     color: "blue"
      height: 100

      Button {
            text: "Button"
            onClicked:{

            console.log(urlInput.text)
                player.source=urlInput.text
                player.play()
            }
        }
     }
    }


 }

}
