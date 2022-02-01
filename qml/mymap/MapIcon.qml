import QtQuick 2.11
import QtQuick.Controls 2.4

Rectangle {
    property var extraIcons: ({
        t12: ['alarm113', 'error111', 'error112', 'error113', 'lost111', 'lost112', 'lost113', 'na111', 'na112', 'na113', 'ok112'],
        t25: ['error100', 'error101']
    })

    //z: model.z
    width: iconSize + 4// * scaleFactor
    height: iconSize + 4// * scaleFactor
    x: (currentMap && 'map' === currentMap.type ? 0 : currentScale * model.x) - (iconSize / 2 - 2)
    y: (currentMap && 'map' === currentMap.type ? 0 : currentScale * model.y) - (iconSize / 2 - 2)
    border.width: equal(model, currentItem) ? 1 : 0
    border.color: "gray"
    property real flashOpacity
    property string display: model.display || ''
    onDisplayChanged: 'flash' === display ? flashAnimation.start() : flashAnimation.stop()

    opacity: switch (display) {
         case 'blink': return blinkOpacity
         case 'flash': return flashOpacity
         default: return 0.8
     }

    Image {
        property var list: extraIcons[model.data]
        property string fn: list && list.indexOf(model.state) >= 0 ? model.state : model.state.replace(/\d+/, '')
        anchors.centerIn: parent
        source: "qrc:/images/devices/" + model.data + "/" + fn + ".svg"
        width: iconSize// * scaleFactor
        height: iconSize// * scaleFactor
        x: model.x
        y: model.y
        id: img
    }

    ToolTip {
        id: tooltip
        timeout: 3e3
        text: model.name + ': ' + model.tooltip
    }

    NumberAnimation on flashOpacity {
        id: flashAnimation
        loops: 3
        from: 0.1
        to: 1
        duration: 300
        onStopped: if ('flash' === model.display) model.display = ''
    }

    MapPointHandler{}


    Component.onCompleted: {
        //root.log(currentMap.type, ":", currentMap.shapes.count, model.type, model.x, model.y)
    }

}
