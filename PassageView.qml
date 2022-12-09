import QtMultimedia 5.13
import QtQuick 2.13
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5
import QtQuick.Window 2.13

import "qml/forms" as Forms
import "js/utils.js" as Utils

Rectangle {
    id: rect
    //color: "yellow"
    //Layout.margins: 10
    clip: true
    onVisibleChanged: if (!visible) {
                          resumeCam = popup.visible
                          popup.close()
                      } else if (resumeCam) popup.open()
    property bool resumeCam
    property string camStream
    property string camSnapshot
    property int maxImageSize: 800
    property real nocache: Date.now()
    property int fontSize: 22
    property int panePosition
    property var empty: ({id: 0, time: "--:--", name: "-----", surename: "-----", rank: "-----", organization: "-----", position: "-----", deviceName: "-----", zoneName: "-----"})
    property var model: empty
    onModelChanged: nocache = Math.round(Date.now() / 1000)
    Column{
        id: column
        anchors.fill: parent
        clip: true
        Row {
            property int freeHeight: column.height - card.height
            property int srcHeight: Math.max(snapshot.sh, placeholder.sh, image.sh)
            property real srcWidth: snapshot.sw * srcHeight / snapshot.sh + placeholder.sw * srcHeight / placeholder.sh + image.sw * srcHeight / image.sh
            property bool useHeight: rect.width / srcWidth > freeHeight / srcHeight
            property real reqHeight: useHeight ? freeHeight : rect.width * srcHeight / srcWidth
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: snapshot
                property int sw: status === 1 ? sourceSize.width : 1
                property int sh: status === 1 ? sourceSize.height : 1
                height: parent.reqHeight
                verticalAlignment: Image.AlignBottom
                cache: false
                fillMode: Image.PreserveAspectFit
                source: camSnapshot + "?w=" + (785 + Math.round(Date.now() / 1000) % 30) + '&' + nocache
                MouseArea {
                    anchors.fill: parent
                    onClicked: popup.open()
                }
            }

            Image {
                id: placeholder
                property int sw: visible ? sourceSize.width : 0
                property int sh: visible ? sourceSize.height : 1 // for safe division op
                height: parent.reqHeight
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/user-solid.svg"
                visible: image.status !== 1
            }

            Image {
                id: image
                property int sw: visible ? sourceSize.width : 0
                property int sh: visible ? sourceSize.height : 1 // for safe division op
                visible: status === 1
                height: parent.reqHeight
                cache: false
                fillMode: Image.PreserveAspectFit
                source: Utils.makeURL("user", {nocache: nocache, id: model.id});
            }
        }
        GridLayout {
            id: card
            columns: 2
            width: parent.width
            Label {
                clip: true
                padding: 5
                text: model.message
                font.pixelSize: fontSize
                Layout.columnSpan: 2
                Layout.fillWidth: true
                background: Rectangle {
                   color: "#ddd"
                }
            }
            ///////////////////////////////////////////
            Text { text: "Время:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.time; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Субъект:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.name + ' ' + model.surename; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Звание:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.rank; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Организация:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.organization; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Должность:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.position; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Проход в:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.zoneName; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}
            ///////////////////////////////////////////
            Text { text: "Через:"; Layout.leftMargin: 5; Layout.alignment: Qt.AlignLeft; font.pixelSize: fontSize}
            Text { text: model.deviceName; Layout.rightMargin: 5; Layout.alignment: Qt.AlignRight; font.pixelSize: fontSize}

        }
    }
    Popup {
        id: popup
        property real scaleFactor: 1
        property int videoSX: snapshot.sourceSize.width || 0
        property int videoSY: snapshot.sourceSize.height || 0
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        closePolicy: Popup.CloseOnEscape
        width:  screen.width * scaleFactor / 5
        height: width / (videoSX && videoSY ? videoSX / videoSY : 16 / 9)
        padding: 1

        MouseArea{
            anchors.fill: parent
            property bool moved
            property point start: Qt.point(0, 0)
            onPressed: {moved = false; start = Qt.point(mouseX, mouseY)}
            onClicked: if (!moved) popup.close()
            onPositionChanged: {
                popup.x += mouse.x - start.x
                popup.y += mouse.y - start.y
                moved = moved || Math.abs(mouse.x - start.x) > 1 || Math.abs(mouse.y - start.y) > 1
            }
            onWheel: {
                if (wheel.angleDelta.y > 0)
                    popup.scaleFactor *= 1.05
                else if (wheel.angleDelta.y < 0)
                    popup.scaleFactor *= 0.95
                if (popup.scaleFactor < 0.5)
                    popup.scaleFactor = 0.5
                if (popup.scaleFactor > 2)
                    popup.scaleFactor = 2
            }
        }

        Video {
            id: camPlayer
            anchors.fill: parent
            autoPlay: true
            source: popup.visible && camStream ? camStream + '?' + Date.now() : ''
        }
    }

    Component.onCompleted: root.userIdentified.connect(userIdentified)

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

        camSnapshot = snapshot.replace(/:0$/, ':1') // secondary stream
        camStream = camSnapshot
            .replace(/^htt/, 'rts')
            .replace(':8000/', ':50554/')
            .replace('/live/media/snapshot/', '/hosts/')

        //console.log("SnSo>", snapshot)
        //console.log("CaSt>", camStream)
    }
}

/*
http://root:root@192.168.0.187:8000/live/media/snapshot/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0
rtsp://root:root@192.168.0.187:50554/hosts/             ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0
*/
