// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtMultimedia 5.15
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5
import "qml/forms" as Forms
import "js/utils.js" as Utils

Rectangle {
    id: rect
    //color: "yellow"
    Layout.margins: 10
    property string camStream
    property string camSnapshot
    property int maxImageSize: 250
    property real nocache: Date.now()
    property int fontSize: 22
    property int panePosition
    property var empty: ({id: 0, time: "", name: "", surename: "", rank: "", organization: "", position: "", deviceName: "", zoneName: ""})
    property var model: empty
    onModelChanged: nocache = Date.now()
    Column {
        width: parent.width
        Label {
            clip: true
            width: parent.width
            padding: 3
            text: model.message
            font.pixelSize: fontSize
            background: Rectangle {
               color: "#ddd"
            }
        }
        //Text {text: model.message; font.pixelSize: fontSize}
        GridLayout {
            columns: 1
            //spacing: 15
            Row {
                //implicitWidth: rect.width > maxImageSize ? maxImageSize : rect.width
                //implicitHeight: width
                Video {
                        id: cam1Stream
                        width: rect.width > maxImageSize ? maxImageSize : rect.width
                        height: width
                        source: camStream //"rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0"
                        autoPlay: true
                        opacity: 1.0
                        fillMode: Image.Stretch
                        muted: false

                }
                Image {
                    id: placeholder
                    width: (rect.width > maxImageSize ? maxImageSize : rect.width) * 0.9
                    clip: true
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/user-solid.svg"
                    visible: image.status !== 1
                }

                Image {
                    id: image
                    width: rect.width > maxImageSize ? maxImageSize : rect.width
                    clip: true
                    cache: false
                    fillMode: Image.PreserveAspectFit
                    source: Utils.makeURL("user", {nocache: nocache, id: model.id});
                }
            }
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Label {
                    clip: true
                    width: parent.width
                    padding: 3
                    text: model.message
                    font.pixelSize: fontSize
                    Layout.columnSpan: 2
                    background: Rectangle {
                       color: "#ddd"
                    }
                }
                ///////////////////////////////////////////
                Text { text: "Время:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.time; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Субъект:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.name + ' ' + model.surename; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Звание:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.rank; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Организация:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.organization; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Должность:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.position; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Проход в:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.zoneName; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
                ///////////////////////////////////////////
                Text { text: "Через:"; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
                Text { text: model.deviceName; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}

            }

            property int sysCount: devices.get(0).children.count
            onSysCountChanged: {
                logText.text = "SYS-C:" + sysCount
            }
        }

    }


    Component.onCompleted: {
        root.userIdentified.connect(userIdentified)

    }

    function userIdentified(event) {
        var user = Utils.findItem(root.users, event.userId)
        //console.log("pass events:", root.activePane, JSON.stringify(event), JSON.stringify(user))
        if (user) {
            model = {
                id: user.id,
                name: user.name || '',
                surename: user.surename || '',
                rank: user.rank || '',
                organization: user.organization || '',
                position: user.position || '',
                deviceName: event.deviceName || '',
                zoneName: event.zoneName || '',
                message: event.text,
                time: event.timeString
            }
        } else
            model = empty
        showCam(event)
    }

    function showCam(event) {
        var i,
            snapshot,
            camId = 0,
            dev = Utils.findItem(root.devices, event.deviceId)
        if (!dev) return
        for (i = 0; i < dev.zones.count; i++) {
            let zone = dev.zones.get(i)
            if (zone.id === event.zoneId) {
                camId = 1 === zone.flags ? dev.internalCam : dev.externalCam
                break
            }
        }

        if (0 === camId) return

        for (i = 0; i < cameraList.count; i++) {
            let cam = cameraList.get(i)
            if (camId === cam.id) {
                snapshot = cam.frash_snapshot
            }
        }

        camSnapshot = snapshot
        camStream = snapshot
            .replace(/^htt/, 'rts')
            .replace(':8000/', ':50554/')
            .replace('/live/media/snapshot/', '/hosts/')

        //console.log("SnSo>", snapshot)
        //console.log("SnSo>", camStream)
    }
}

/*
  {"sid":5,"id":726,"name":"Зона 1Камера 1","serviceId":5,"frash_snapshot":"http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0","color":"green","display":"","tooltip":"","mapState":"ok","stickyState":false,"actual":true,"telemetryControlID":"hosts/ASTRAAXXON/DeviceIpint.1/TelemetryControl.0","liveStream":"","storageStream":"","snapshot":"","ipadress":"192.168.0.90"}
== after cam start
{"sid":5,"id":726,"name":"Зона 1Камера 1","serviceId":5,"frash_snapshot":"http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0","color":"","display":"","tooltip":"","mapState":"ok","stickyState":false,"actual":true,"telemetryControlID":"hosts/ASTRAAXXON/DeviceIpint.1/TelemetryControl.0","liveStream":"rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0","storageStream":"","snapshot":"","ipadress":"192.168.0.90"}

===
http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0
rtsp://root:root@192.168.0.187:50554/hosts/             ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0

Warning: "Для типа «video/x-h264, stream-format=(string)avc, alignment=(string)au, codec_data=(buffer)014d0029ffe10019674d00299a6403c0113f2cd404040500000303e80000c3500401000468ee3c80, level=(string)4.1, profile=(string)main, width=(int)1920, height=(int)1080, framerate=(fraction)25/1, chroma-format=(string)4:2:0, bit-depth-luma=(uint)8, bit-depth-chroma=(uint)8, colorimetry=(string)bt709, parsed=(boolean)true» недоступен декодер."
Error: "В вашей установке GStreamer отсутствует модуль."
apt install gstreamer1.0-libav
*/
