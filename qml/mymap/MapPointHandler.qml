// for v2.11
//import QtQuick 2.11
//import Qt.labs.handlers 1.0

// for v2.13 and above
import QtQuick 2.13

PointHandler {
    property real startX
    property real startY
    property var startP
    property int pressedButtons
    property bool selected: equal(currentItem, model)

    target: null
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    //onActiveChanged: active ? onPress() : onRelease()

    Component.onCompleted: {
        if (typeof centroid !== 'undefined')
            centroidChanged.connect(dragHandler)
        else
            pointChanged.connect(dragHandler)
    }

    function onPress() {
        var leftBtn = Qt.LeftButton === point.pressedButtons
        if (!adminMode && leftBtn) {
            tooltip.x = point.pressPosition.x + 15
            tooltip.y = point.pressPosition.y + 15
            tooltip.visible = true
        }

        if (leftBtn && !nextItem) {
            nextItem = model
            currentAnchor = -1
        }
        pressedButtons = point.pressedButtons
    }

    function onRelease() {
        if (Qt.RightButton === pressedButtons) {
            console.log('ConMen:', model.sid, model.did)
            contextMenu.show(model.sid, model.did)
        } else {

            if (equal(nextItem, model)) {
                root.deviceSelected(panePosition, model.sid, model.did)
                selectItem(nextItem)
                nextItem = null
                currentAnchor = -2
            }
        }
    }

    function dragHandler() {
        // TODO: control bounds
        // TODO: use translation instead of dx & dy?
        //console.log('dragHandler', point.pressedButtons)
        if (point.pressedButtons === 0)
            onRelease()
        else
            onPress()

        if (!selected)
            return

        var poi;
        if (typeof centroid !== 'undefined')
            poi = centroid
        else
            poi = point

        var coord,
            dx = poi.scenePosition.x - poi.scenePressPosition.x,
            dy = poi.scenePosition.y - poi.scenePressPosition.y
        //console.log(currentAnchor, flickable.interactive, JSON.stringify(poi))
        if (['polyline', 'polygon'].indexOf(model.type) >= 0) {
            if (0 === dx && 0 === dy) {
                //console.log(model.color, model.type)
                currentAnchor = -1
                startP = model.data.split(' ').map(function (v) {
                    return v.split(',').map(function (n) {return parseInt(n)})
                })
            } else /*if (active)*/ {
                model.data = startP.map(function (v) {
                    return (v[0] + dx / currentScale) + ',' + (v[1] + dy / currentScale)
                }).join(' ')
                arrangeAnchors()
            }
        } else { // ellipse & rect
            if (0 === dx && 0 === dy) {
                //console.log(model.color, model.type)
                currentAnchor = -1
                if ('map' === currentMap.type) {
                    coord = getCenter()
                    startX = coord.x
                    startY = coord.y
                } else { // plan
                    startX = model.x
                    startY = model.y
                }
            } else {
                if ('map' === currentMap.type) {
                    coord = map.toCoordinate(Qt.point(startX + dx, startY + dy))
                    model.x = coord.longitude
                    model.y = coord.latitude
                } else { // plan
                    model.x = startX + dx / currentScale
                    model.y = startY + dy / currentScale
                }
                arrangeAnchors()
            }
        }
    }

}
