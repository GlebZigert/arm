import QtQuick.Controls 2.4
import QtQuick 2.11

Text {
    //z: model.z
    color: model.color
    text: model.data
    font.pixelSize: model.h * currentScale //fontSize
    rotation: model.r
    x: ('map' === currentMap.type ? 0 : model.x * currentScale) - width / 2
    y: ('map' === currentMap.type ? 0 : model.y * currentScale) - height / 2
    property real flashOpacity
    property string display: model.display || ''
    onDisplayChanged: 'flash' === display ? flashAnimation.start() : flashAnimation.stop()

    opacity: switch (display) {
         case 'blink': return blinkOpacity
         case 'flash': return flashOpacity
         default: return 0.8
     }

    onWidthChanged: model.w = width / currentScale
    //onHeightChanged: model.h = height

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
        model.w = width / currentScale// Text.paintedWidth ?
        appendFinished = true
        root.log(currentMap.type, ":", currentMap.shapes.count, model.type, model.x, model.y, model.w, model.h)
    }

}
