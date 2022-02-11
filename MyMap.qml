
// https://stackoverflow.com/questions/60141251/how-can-i-dynamically-draw-a-polygon-and-make-its-points-markers-movable-in-qml?rq=1
import QtQuick 2.0
import QtQuick.Window 2.11
import QtLocation 5.11
import QtPositioning 5.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQml.Models 2.4

import "qml/mymap" as MyMap
//import "js/utils.js" as Utils

RowLayout {
//    anchors.fill: parent
    property int panePosition

    id: myMap
    spacing: 0

    property bool adminMode

    //property var statesColors: Utils.statesColors
    property string anticache // TODO: only for changed pics, not for all
    //signal reCache()

    property bool asyncWait
    //property string viewMode: "map"
    property var currentMap
    property int handleSize: 10

    property int iconSize: 32
    property int fontSize: 24
    property int initialZoom: 6
    property int maxSize: 8192
    //property real currentScale: currentMap && 'plan' === currentMap.type ? 1 : Math.pow(2, map.zoomLevel - initialZoom)
    property var mapPosition: ({}) // id: {x, y, scale}
    property real planScale: 1
    onPlanScaleChanged: currentMap && 'plan' === currentMap.type && Qt.callLater(arrangeAnchors)
    property real currentScale: currentMap && 'plan' === currentMap.type ? planScale : Math.pow(2, map.zoomLevel - initialZoom)

    //property real currentScale: !currentMap ? 1 : Math.pow(2, 'plan' === currentMap.type ? plan.zoomLevel : map.zoomLevel - initialZoom)

    property var currentItem
    property var nextItem // due to problems with TapHandler with Map
    property int currentOrder: 1e6
    property int currentAnchor: -2 // -2 = move flickable, -1 move shape, >0  = move anchor
    //property bool tooltipActive: false
    property real startPhi
    property bool appendFinished: true
    onAppendFinishedChanged: if (appendFinished) arrangeAnchors()
    property real blinkOpacity: 0.8

    onCurrentMapChanged: {
        console.log('Selected ', currentMap.type, currentMap.id, map.zoomLevel)
        planScale = 'plan' === currentMap.type && mapPosition[currentMap.id] && mapPosition[currentMap.id].scale || 1
        anchorsModel.clear()
        currentItem = null
    }

    NumberAnimation on blinkOpacity {
        loops: Animation.Infinite
        from: 0.1
        to: 1
        duration: 1000
    }

    Item {
        Layout.fillHeight: true
        Layout.fillWidth: true
        onWidthChanged: arrangeAnchors()
        onHeightChanged: arrangeAnchors()


        ListModel {id: emptyModel}
        ListModel {id: anchorsModel}

        MyMap.Map{
            id: map
            //visible: !currentMap || currentMap.type === "map"
            zoomLevel: initialZoom
            anchors.left: parent.left
            anchors.top: parent.top
            width: (!currentMap || currentMap.type === "map") ? parent.width : 0
            height: width > 0 ? parent.height : 0
            //onZoomLevelChanged: console.log("ZLC:", zoomLevel)
        }
        MyMap.Plan{
            id: plan
            property real zoomLevel: initialZoom
            visible: map.width === 0
            anchors.fill: parent
        }

        ComboBox {
            id: mapChooser
            enabled: !asyncWait
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            textRole: "name"
            model: root.maps
            flat: true
            //currentIndex: 1
            /*background: Rectangle {
                color: parent.down ? "white" : "transparent"
                opacity: parent.down ? 1 : 0.5
                border.color: parent.palette.highlight
                border.width: !parent.editable && parent.visualFocus ? 2 : 0
            }*/
            onCurrentIndexChanged: activateMap()
            onCountChanged: activateMap()

            function activateMap() {
                //console.log('Activate map #', currentIndex, 'of', count)
                var newMap
                if (currentIndex >= count || currentIndex < 0)
                    currentIndex = count - 1

                if (currentIndex < 0)
                    anchorsModel.clear()
                else { // index valid
                    newMap = model.get(currentIndex)
                    if (newMap && currentMap !== newMap) {  // map has changed
                        currentMap = newMap
                    }
                }
            }
        }
    }
    // Settings panel
    //MyMap.Panel{}
    Loader {
        visible: adminMode
        Layout.fillHeight: true
        width: 400
        source: adminMode ? "qml/mymap/Panel.qml" : ''
    }

    DevContextMenu {id: contextMenu}

    /*Component.onCompleted: {
        if (root.maps.count === 0)
            initMap()
        selectMap()
    }*/

///////////////////////////////////////////////////////////////////////////////////////////////////////

    function selectMap() {
        mapChooser.currentIndex = 0
    }

    function removePoint(index) {
        if (!isPoly())
            return

        var points = currentItem.data.split(' ')
        if (points.length > ('polyline' === currentItem.type ? 2 : 3)) {
            points.splice(index, 1)
            currentItem.data = points.join(' ')
            arrangeAnchors()
        }
    }

    function addPoint(x, y) {
        if (!currentItem || !isPoly())
            return

        var center = getCenter()
        if ('map' === currentMap.type)
            currentItem.data += ' ' + ((x - center.x) / currentScale) + ',' + ((y - center.y) / currentScale)
        else
            currentItem.data += ' ' + (x / currentScale) + ',' + (y / currentScale)
        arrangeAnchors()
    }

    function moveAnchor(x, y) {
        var points = currentItem.data.split(' '),
            center = getCenter()

        if ('map' === currentMap.type)
            points[currentAnchor] = ((x - center.x) / currentScale) + ',' + ((y - center.y) / currentScale)
        else
            points[currentAnchor] = (x / currentScale) + ',' + (y / currentScale)
        currentItem.data = points.join(' ')
    }

    function rotate(x, y) {
        var center = getCenter(),
            phi = Math.atan2(y - center.y, x - center.x) / Math.PI * 180
        if (isNaN(startPhi))
            startPhi = currentItem.r - phi
        currentItem.r = startPhi + phi // clockwise
    }

    function isPoly() {
        return currentItem && ['polyline', 'polygon'].indexOf(currentItem.type) >= 0
    }

    function selectItem(item) {
        if (!adminMode)
            return

        var i, m, shapes = currentMap.shapes || {count: -1};

        for (i = 0; i < shapes.count; i++) {
            m = shapes.get(i)
            if (equal(item, m)) {
                m.z = currentOrder++
                currentItem = m
                arrangeAnchors()
                console.log("Selected", m.color, m.type, m.z, m.state, '(' + m.sid + ',' + m.did + ')')
                break
            }
        }

        if (i >= shapes.count) {
            anchorsModel.clear()
            currentItem = null
            console.log(item.color, item.type, "not found")
        }
    }

    function rotatePoint(dx, dy, phi) {
        var sin = Math.sin(phi / 180 * Math.PI),
            cos = Math.cos(phi / 180 * Math.PI);
        return [dx * cos - dy * sin, dy * cos + dx * sin]
    }

    function equal(m1, m2) {
        var i, fields = ['x', 'y', 'w', 'h', 'r', 'z', 'data']
        //console.log(m1.color, m1.type, "<=>", m2.color, m2.type)

        if (!m1 || !m2 || m1.type !== m2.type)
            return false
        for (i = 0; i < fields.length; i++)
            if (m1[fields[i]] !== m2[fields[i]])
                return false
        //console.log('YES')
        return true;
        //return m1.longitude === m2.longitude && m1.latitude === m2.latitude && m1.width === m2.width && m1.height === m2.height && m1.rotation === m2.rotation
    }

    function dumpModel(m) {
        for (var i = 0; i < m.count; i++)
            console.log(i, JSON.stringify(m.get(i)))
    }
    function purgeModel(m) {
        var item
        for (var i = m.count-1; i >= 0 ; i--) {
            item = m.get(i)
            if (!item.visible) {
                console.log("remove", i, JSON.stringify(item))
                m.remove(i)
            }
        }
    }

    function getCenter(item) {
        item = item || currentItem
        var coord, center;
        if ('map' === currentMap.type) {
            coord = QtPositioning.coordinate(item.y, item.x)
            center = map.fromCoordinate(coord, false)
        } else
            center = Qt.point(item.x * currentScale, item.y * currentScale)
        return center
    }

    function scaleShape(x, y) {
        var center = getCenter(),
            scale = /*'text' === currentItem.type ? 1 :*/ currentScale,
            rp = rotatePoint(x - center.x, y - center.y, -currentItem.r)

        var x1 = rp[0] + center.x,
            y1 = rp[1] + center.y

        if ([0, 2, 3, 4, 6, 7].indexOf(currentAnchor) >= 0 && currentItem.type !== 'text')
            currentItem.w = 2 * Math.abs(x1 - center.x) / currentScale

        if ([0, 1, 2, 4, 5, 6].indexOf(currentAnchor) >= 0)
            currentItem.h = 2 * Math.abs(y1 - center.y) / scale
    }

    function arrangeAnchors() {
        if (!currentItem || currentItem.w * currentScale > maxSize || currentItem.h * currentScale > maxSize) {
            anchorsModel.clear()
            return
        }
        var i,
            scale = currentScale,
            coords = anchorCoords(currentItem)

        if (anchorsModel.count === coords.length) {
            for (i = 0; i < coords.length; i++)
                anchorsModel.set(i, coords[i])
        } else {
            anchorsModel.clear()
            anchorsModel.append(coords)
        }
    }

    function anchorCoords(item) {
        var coords,
            center = getCenter(item)

        if (['rectangle', 'ellipse', 'text'].indexOf(item.type) >= 0) {
            coords = [
                [-item.w/2, -item.h/2], [0, -item.h/2], [item.w/2, -item.h/2],
                [item.w/2, 0],
                [item.w/2, item.h/2], [0, item.h/2], [-item.w/2, item.h/2],
                [-item.w/2, 0],
                [item.w/3, item.h/3]
            ].map(function (v) {
                var p = rotatePoint(v[0] * currentScale, v[1] * currentScale, item.r)
                return {x: center.x + p[0], y: center.y + p[1], r: item.r}
            })
        } else if (item.data) {
            coords = item.data.split(' ').map(function (v) {
                var pair = v.split(',')
                if ('map' === currentMap.type)
                    return {x: center.x + currentScale * parseFloat(pair[0]), y: center.y + currentScale * parseFloat(pair[1]), r: 0}
                else
                    return {x: currentScale * parseFloat(pair[0]), y: currentScale * parseFloat(pair[1]), r: 0}
            })
        }
        return coords
    }


    // https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    function pointDistance(x, y, x1, y1, x2, y2) {
      var A = x - x1;
      var B = y - y1;
      var C = x2 - x1;
      var D = y2 - y1;

      var dot = A * C + B * D;
      var len_sq = C * C + D * D;
      var param = -1;
      if (len_sq !== 0) //in case of 0 length line
          param = dot / len_sq;

      var xx, yy;

      if (param < 0) {
        xx = x1;
        yy = y1;
      } else if (param > 1) {
        xx = x2;
        yy = y2;
      } else {
        xx = x1 + param * C;
        yy = y1 + param * D;
      }

      var dx = x - xx,
          dy = y - yy
      return Math.sqrt(dx * dx + dy * dy);
    }

    function lineClicked(mx, my) {
        var i, j,
            yes,
            item,
            p // points
        for (i = 0; i < currentMap.shapes.count; i++) {
            item = currentMap.shapes.get(i)
            if ('polyline' === item.type) {
                p = item.data.split(/,| /).map(function (v) {return parseInt(v)})
                for (j = 0; j < p.length - 3; j += 2)
                    if (pointDistance(mx, my, p[j], p[j+1], p[j+2], p[j+3]) <= 3)
                        return item
            }
        }
        return null
    }

    /*function initMap() {
        //mapmodel.clear()
        root.maps.append([
        {
            id: 10,
            type: "map",
            name: "Главная карта",
            shapes: [
                 {x: 35, y: 60, w: 250, h: 150, r: 30, type: "ellipse", color: "red", z: 1, state: 'blink'},
                 {x: 37, y: 54, w: 200, h: 100, r: 0, type: "rectangle", color: "orange", z: 4},
                 {type: "polygon", x: 38, y: 55, r: 0, data: "0,0 200,0 200,200", color: "magenta", z: 4, state: 'flash'},
                 {type: "polyline", x: 37, y: 56, r: 0, data: "0,0 300,200 300,400", color: "magenta", z: 4},
                 {color: "blue", x: 35, y: 53, w: 24, h: 24, r: 0, type: "text", data: "Hello!", z:10},
                 {color: "blue", x: 36, y: 55, r: 0, w: 24, h: 24, type: "icon", data: "t2", z:11}]
        },{
          id: 11,
          type: "plan",
          name: "1 этаж",
          shapes: [
              {x: 500, y: 245, w: 250, h: 150, r: 30, type: "ellipse", color: "red", z: 1},
              {x: 311, y: 245, w: 200, h: 100, r: 0, type: "rectangle", color: "orange", z: 4},
              {type: "polygon", x: 150, y: 250, r: 0, data: "100,200 200,200 200,300", color: "magenta", z: 4},
              {type: "polyline", x: 250, y: 350, r: 0, data: "200,300 300,300 300,400", color: "magenta", z: 4},
              {color: "blue", r: 0, w: 24, h: 24, x: 254, y: 234, type: "text", data: "Hello!", z:10},
              {color: "blue", r: 0, w: 24, h: 24, x: 54, y: 39, type: "icon", data: "t2", z:11}]
        }])
    }*/
}
