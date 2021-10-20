import QtQuick 2.11

import QtQuick.Controls 2.4


/*ScrollView {
    width: 200
    height: 200
    clip: true*/
Flickable {
    id: flickable
    property real maxScale: 4
    property real minScale: 1 / maxScale
    onWidthChanged: Qt.callLater(setScale, planScale, 0, 0)
    onHeightChanged: Qt.callLater(setScale, planScale, 0, 0)

    // antialiasing: https://stackoverflow.com/questions/48895449/how-do-i-enable-antialiasing-on-qml-shapes
    layer.enabled: true
    layer.samples: 4

    interactive: -2 === currentAnchor
    //anchors.fill: parent
    contentWidth: image.sourceSize.width // parent.width//image.sourceSize.width * planScale//image.width
    contentHeight: image.sourceSize.height // parent.height//image.sourceSize.height * planScale //image.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn
    ScrollBar.horizontal: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn

    Image {
        id: image
        cache: false
        source: currentMap && 'plan' === currentMap.type ? "http://" + serverHost + "/0/plan?id=" + currentMap.id + '&ac=' + anticache : ''
        anchors.fill: parent
        //width: sourceSize.width * planScale
        //height: sourceSize.height * planScale
        fillMode: Image.PreserveAspectFit
        onSourceSizeChanged: {
            var sx = flickable.width / sourceSize.width,
                sy = flickable.height / sourceSize.height,
                scale = Math.min(sx, sy)
            console.log(sx, sy, scale)
            Qt.callLater(setScale, scale, 0, 0)
            //flickable.contentWidth = image.sourceSize.width * planScale
            //flickable.contentHeight = image.sourceSize.height * planScale
        }

        onStatusChanged: {
            console.log("Plan image status:", status)
            //if (Image.Error === status && currentMap.id && currentMap.id > 0)
              //  reloadTimer.running = true
        }
        /*Timer {
            id: reloadTimer
            //running: socket.active
            interval: 3000
            onTriggered: {
                console.log('RELOAD')
                anticache = Math.round(Math.random() * 2e9)
            }
        }*/

        MouseArea {
            anchors.fill: parent
            onWheel: {
                var normOne
                if (wheel.modifiers & Qt.ControlModifier) {
                    normOne = wheel.angleDelta.y / 120
                    flickable.setScale(planScale * (1 + .1 * normOne), wheel.x, wheel.y)
                } else {
                    wheel.accepted = false
                }
            }
        }
    }

    function setScale(scale, x, y) {
        var sx = flickable.width / image.sourceSize.width,
            sy = flickable.height / image.sourceSize.height,
            min = Math.min(sx, sy)

        if (scale < minScale)
            scale = minScale
        if (scale > maxScale)
            scale = maxScale
        if (scale < min)
            scale = min

        planScale = scale
        flickable.resizeContent(
                    image.sourceSize.width * scale,
                    image.sourceSize.height * scale,
                    Qt.point(x, y))

        flickable.returnToBounds()
    }

    Repeater {
        model: currentMap && 'plan' === currentMap.type ? currentMap.shapes : emptyModel
        delegate: Loader {
            z: model.z
            property var handlers: ({icon: 'MapIcon', text: 'MapText'})
            source: (handlers[model.type] || 'MapShape') + '.qml'
        }
    }

    ShapeAnchors{}
    MapMouseArea{}

    function reload() {
        anticache = Math.round(Math.random() * 2e9)
    }
}
