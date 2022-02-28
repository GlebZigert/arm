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
    property real realWidth: 0
    property real realHeight: 0


    clip: true
    // antialiasing: https://stackoverflow.com/questions/48895449/how-do-i-enable-antialiasing-on-qml-shapes
    layer.enabled: true
    layer.samples: 4
    interactive: -2 === currentAnchor
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn
    ScrollBar.horizontal: ScrollBar {policy: ScrollBar.AsNeeded} // .AlwaysOn

    onMovingChanged: savePosition()

    function resize() {
        var x = 0, y = 0,
            sx = realWidth ? flickable.width / realWidth : 1,
            sy = realHeight ? flickable.height / realHeight : 1,
            scale = Math.min(sx, sy),
            position = currentMap && mapPosition[currentMap.id]

        //console.log("SIZE0:", realWidth, realHeight, contentWidth, contentHeight)
        //console.log("SIZE1:", contentItem.childrenRect.width, contentItem.childrenRect.height)
        //console.log("SCALE:", sx, sy, scale)
        //console.log("F-SIZE:", width, height)

        //flickable.contentWidth = realWidth * scale
        //flickable.contentHeight = realHeight * scale
        planScale = scale
/*
        if (position) {
            x = position.x
            y = position.y
            scale = position.scale
        }
        planScale = scale
        Qt.callLater(function() {
            flickable.contentWidth = realWidth * scale
            flickable.contentHeight = realHeight * scale
            flickable.contentX = x
            flickable.contentY = y
            console.log("SIZE:", realWidth, realHeight, flickable.contentWidth, flickable.contentHeight)
        })
        //console.log(x, y, sx, sy, scale)*/
    }

    Image {
        id: image
        cache: false
        source: currentMap && 'plan' === currentMap.type ? "http://" + serverHost + "/0/plan?id=" + currentMap.id + '&ac=' + anticache : ''
        //anchors.fill: parent
        //fillMode: Image.PreserveAspectFit
        width: sourceSize.width * planScale
        height: sourceSize.height * planScale
        onSourceSizeChanged: {
        }

        /*onSourceSizeChanged: {
            var x = 0, y = 0,
                sx = flickable.width / sourceSize.width,
                sy = flickable.height / sourceSize.height,
                scale = Math.min(sx, sy),
                position = currentMap && mapPosition[currentMap.id]

            if (position) {
                x = position.x
                y = position.y
                scale = position.scale
            }
            planScale = scale
            Qt.callLater(function() {
                flickable.contentWidth = sourceSize.width * scale
                flickable.contentHeight = sourceSize.height * scale
                flickable.contentX = x
                flickable.contentY = y
                //console.log("SIZE:", flickable.contentItem.width, flickable.contentItem.height, flickable.contentWidth, flickable.contentHeight)
                console.log("SIZE:", flickable.contentItem.children.length)
                listChildren()
            })

            //console.log(x, y, sx, sy, scale)

        }*/

        onStatusChanged: if (Image.Ready === status) setImageSize(sourceSize)
    }

    Repeater {
        //anchors.fill: parent
        model: currentMap && 'plan' === currentMap.type ? currentMap.shapes : emptyModel
        delegate: Loader {
            z: model.z
            property var handlers: ({icon: 'MapIcon', text: 'MapText'})
            source: (handlers[model.type] || 'MapShape') + '.qml'
        }
        onModelChanged: Qt.callLater(setDrawingSize, model)
        //onItemAdded: console.log("+++++++++++++++++", index, count, realWidth, realHeight)
    }

    ShapeAnchors{}
    MapMouseArea{}
    MouseArea {
        anchors.fill: parent
        onWheel: {
            var normOne
            if (wheel.modifiers & Qt.ControlModifier) {
                //console.log("WHEEL", contentWidth, contentHeight, realWidth, realHeight)
                normOne = wheel.angleDelta.y / 120
                //planScale *= (1 + .1 * normOne)
                flickable.setPosition(planScale * (1 + .1 * normOne), wheel.x, wheel.y)
                flickable.savePosition()
            } else {
                wheel.accepted = false
            }
        }
    }

    /*Timer {
        running: true
        interval: 2000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log('TIMER', realWidth, realHeight)
        }
    }*/

    function savePosition() {
        if (!moving && currentMap) {
            var data = {x: contentX, y: contentY, scale: planScale}
            //console.log("*** STORE DATA:", JSON.stringify(data), '#', currentMap.id)
            mapPosition[currentMap.id] = data
        }
    }

    function setPosition(scale, x, y) {
        if (!realWidth || !realHeight)
            return
        var sx = width / realWidth,
            sy = height / realHeight,
            min = Math.min(sx, sy)
        if (scale < minScale)
            scale = minScale
        if (scale > maxScale)
            scale = maxScale
        if (scale < min)
            scale = min

        planScale = scale
        flickable.resizeContent(
            realWidth * scale,
            realHeight * scale,
            Qt.point(x, y))
        flickable.returnToBounds()
    }


    // set size on drawing update
    // drawing size is always called before image size
    function setDrawingSize(shapes) {
        var item,
            coords,
            sx = 0,
            sy = 0

        for (var i = 0; i < shapes.count; i++) {
            item = shapes.get(i)
            coords = anchorCoords(item)
            for (var j = 0; j < coords.length; j++) {
                if (sx < coords[j].x)
                    sx = coords[j].x
                if (sy < coords[j].y)
                    sy = coords[j].y
            }
        }
        realWidth = sx / planScale
        realHeight = sy / planScale
        restorePosition()
        //console.log("+++ SetDrwSize", realWidth, realHeight)
    }

    function setImageSize(size) {
        // check image is not greater than drawing
        if (realWidth < size.width)
            realWidth = size.width
        if (realHeight < size.height)
            realHeight = size.height

        restorePosition()
        //console.log("+++ SetImgSize", realWidth, realHeight)
    }

    function restorePosition() {
        var scale = 1,
            x = 0, y = 0,
            position = currentMap && mapPosition[currentMap.id]
        if (position) {
            x = position.x
            y = position.y
            scale = position.scale
            //console.log("*** RESTORE DATA:", JSON.stringify(position), '#', currentMap.id)
        }

        // don't check constraints for saved values
        contentWidth = realWidth * scale
        contentHeight = realHeight * scale
        contentX = x
        contentY = y
        planScale = scale
    }
}
