import QtQuick 2.11
import QtQuick.Shapes 1.11
import QtPositioning 5.11
import QtQuick.Controls 2.4
//import QtQuick 2.13


import "../../js/line-as-polygon.js" as LAP


// https://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon/17490923#17490923

Shape {
    id: delegateItem
    //z: model.z
    property int shapeStroke: 2
    property int lineWidth: 3
    property real centerX: currentMap && 'plan' === currentMap.type ? currentScale * (model.x || 0) : 0
    property real centerY: currentMap && 'plan' === currentMap.type ? currentScale * (model.y || 0) : 0
    property real realW: model.w * currentScale
    property real realH: model.h * currentScale
    property real flashOpacity
    property string display: model.display || ''
    onDisplayChanged: 'flash' === display ? flashAnimation.start() : flashAnimation.stop()

    opacity: switch (display) {
         case 'blink': return blinkOpacity
         case 'flash': return flashOpacity
         default: return 0.8
     }

    visible: realW < maxSize && realH < maxSize // TODO: calc for polyline

    transform: Rotation {angle: model.r; origin.x: centerX; origin.y: centerY}
    //rotation: 90 & transformOrigin: Item.Center - does not work :-(
    // TODO: use BoundingRect for polyline
    containsMode: Shape.FillContains //'polyline' === model.type ? Shape.BoundingRectContains : Shape.FillContains
    //asynchronous: false
    ShapePath {
        //strokeStyle: ShapePath.DashLine
        fillRule: 'polyline' === model.type ? ShapePath.WindingFill : ShapePath.OddEvenFill
        strokeWidth: /*'polyline' === model.type ? 0 : */shapeStroke // 10 * Math.pow(2, zoomLevel - map.zoomLevel)
        strokeColor: 'polyline' === model.type ? "transparent" : 'black'
        fillColor: /*'polyline' === model.type ? 'transparent' :*/ model.color
        //PathSvg { path: "M 0, 0 a 150,75 0 1,0 1,0" }
        PathSvg {path: switch (model.type) {
                case 'rectangle':
                    //var center = getPoint(model.x, model.y)
                    return rectanglePath(centerX, centerY, realW, realH)
                case 'ellipse':
                    return ellipsePath(centerX, centerY, realW, realH)
                case 'polygon':
                    return polylinePath(polyCoords(model.x, model.y, model.data, currentScale)) + ' z'
                case 'polyline':
                    return lineAsPolygon(model.x, model.y, model.data, currentScale) + ' z'
                    //return polylinePath(polyCoords(model.x, model.y, model.data, currentScale))
                default:
                    console.log("ERROR: unknown shape type", model.type)
                    return ''
             }
        }
      //PathSvg { path: "L 100 0 L 100 100 z" }
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
        console.log(currentMap.type, ":", currentMap.shapes.count, model.type, model.x, model.y)
    }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /*function normalizePoly(data) {
        var points = data.split(' ').map(function (v){
            var pair = v.split(',')
            return {x: parseFloat(pair[0]), y: parseFloat(pair[1])}
        }),
        sum = points.reduce(function (sum, v){
        }, {cx: 0, cy: 0})
    }*/

    function ellipsePath(x, y, a, b) {
        return ["M", x, y-b/2, "a", a/2, b/2, 0, 1, 0, 1, 0, "z"].join(' ')
    }
    function rectanglePath(x, y, w, h) {
        return ["M", x - w/2, y-h/2, "l", w, 0, 0, h, -w, 0, "z"].join(' ')
    }

    function polyCoords(x, y, data, scale) {
        var points = data.split(' ').map(function (v) {
            var pair = v.split(',')
            return scale * parseFloat(pair[0]) + ',' + scale * parseFloat(pair[1])
        })
        //console.log(JSON.stringify(points))
        return points
    }

    function polylinePath(points) {
        var /*points = data.split(' '),*/
            begin = 'M ' + points.shift() + ' L ',
            res = begin + points.join(' ')
        return res
    }

    function lineAsPolygon(x, y, data, scale) {
        var points = data.split(' ').map(function (v) {
            var pair = v.split(',')
            return {x: scale * parseFloat(pair[0]), y: scale * parseFloat(pair[1])}
        })
        points = LAP.lineAsPolygon(points, lineWidth).map(function (v) {return v.x + ',' + v.y})
        return polylinePath(points)
    }


    /*function _polyCoords(x, y, data) {
        var coord = QtPositioning.coordinate(y, x),
            center = map.fromCoordinate(coord, false)

            var points = data.split(' ').map(function (v) {
                var pair = v.split(','),
                    coord = QtPositioning.coordinate(y + parseFloat(pair[1]), x + parseFloat(pair[0])),
                    point = map.fromCoordinate(coord, false)
                //coord = map.toCoordinate(Qt.point(center.x + parseFloat(pair[0]), center.y + parseFloat(pair[1])))
                return (point.x - center.x) + ',' + (point.y - center.y)
            }).join(' ')
        //console.log(JSON.stringify(points))
        return points
    }*/

}
