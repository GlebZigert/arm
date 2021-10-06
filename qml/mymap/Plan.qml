import QtQuick 2.11

import QtQuick.Controls 2.4


/*ScrollView {
    width: 200
    height: 200
    clip: true*/
Flickable {
    // antialiasing: https://stackoverflow.com/questions/48895449/how-do-i-enable-antialiasing-on-qml-shapes
    layer.enabled: true
    layer.samples: 4

    id: flickable
    interactive: -2 === currentAnchor
    //anchors.fill: parent
    contentWidth: image.width
    contentHeight: image.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn
    ScrollBar.horizontal: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn

    Image {
        id: image
        property string url: currentMap && 'plan' === currentMap.type ? "http://" + serverHost + "/0/plan?id=" + currentMap.id + '&rnd=' + anticache : ''
        cache: false
        source: url
        //anchors.fill: parent
        width: sourceSize.width * planScale
        height: sourceSize.height * planScale
        //fillMode: Image.PreserveAspectFit
        onStatusChanged: {
            console.log("Image status:", status)
            if (Image.Error === status && currentMap.id && currentMap.id > 0)
                reloadTimer.running = true
        }
        Timer {
            id: reloadTimer
            //running: socket.active
            interval: 3000
            onTriggered: {
                console.log('RELOAD')
                anticache = Math.round(Math.random() * 2e9)
            }
        }

        MouseArea {
            anchors.fill: parent
            onWheel: {
                var normOne
                if (wheel.modifiers & Qt.ControlModifier) {
                    normOne = wheel.angleDelta.y / 120
                    planScale += normOne * 0.05
                    if (planScale < 0.2)
                        planScale = 0.2
                    if (planScale > 2)
                        planScale = 2
                    //console.log("WHEEL+Ctrl:", planScale)
                } else {
                    wheel.accepted = false;
                }
            }
        }
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
}
