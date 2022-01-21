import QtQuick 2.11
import QtQuick.Window 2.11
import QtLocation 5.11
import QtPositioning 5.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQml.Models 2.4

import "../../js/shapes.js" as Shapes

Map {
    id: map
    layer.enabled: true
    layer.samples: 4
    zoomLevel: initialZoom
    plugin: Plugin {
        name: "esri"
        //name: "osm"
     //   PluginParameter { name: "osm.mapping.host"; value: "http://127.0.0.1:2973/" }
    }
    //activeMapType: supportedMapTypes[1]
    gesture.enabled: true// !tooltipActive //  -2 === currentAnchor
    gesture.acceptedGestures: MapGestureArea.PinchGesture | (-2 === currentAnchor /* && !tooltipActive*/ ? MapGestureArea.PanGesture : 0)
    //gesture.onPanStarted: console.log("MAP pan started")
    //gesture.preventStealing: true

    //center: QtPositioning.coordinate(0, 10.74) // Equator
    //center: QtPositioning.coordinate(59.91, 10.75) // Oslo
    center: QtPositioning.coordinate(55.745, 37.576) // Moscow
    //onZoomLevelChanged: console.log(zoomLevel)
    onCenterChanged: arrangeAnchors() // TODO: link anchors to currentItem.x and y
    onZoomLevelChanged: arrangeAnchors() // TODO: link anchors to currentItem.x and y

    MapItemView {
        model: currentMap && 'map' === currentMap.type ? currentMap.shapes : emptyModel
        delegate: MapQuickItem{
            z: model.z
            //anchorPoint: Qt.point(model.w/2, model.h/2)
            coordinate: QtPositioning.coordinate(model.y, model.x)
            sourceItem: Loader {
                //property var model: mdl
                property var handlers: ({icon: 'MapIcon', text: 'MapText'})
                source: (handlers[model.type] || 'MapShape') + '.qml'
            }
            //Component.onCompleted: console.log(JSON.stringify(model))
        }
    }

    ShapeAnchors{}
    MapMouseArea{}
/******************************* DRAW CENTERS ***********************************/
    /*MapItemView {
        model: currentMap && 'map' === currentMap.type ? currentMap.shapes : emptyModel
        delegate: MapCircle {
            z: 2e9
            center {
                latitude: polyCenter().y
                longitude: polyCenter().x
            }
            radius: 5000.0
            color: 'green'
            border.width: 1
            function polyCenter() {
                if (['polyline', 'polygon'].indexOf(model.type) >= 0) {
                    var coord = QtPositioning.coordinate(model.y, model.x),
                        center = map.fromCoordinate(coord, false),
                        sum = {x: 0, y: 0},
                        points = model.data.split(' ').map(function (v) {
                            var p = v.split(','),
                                x = parseFloat(p[0]),
                                y = parseFloat(p[1]);

                            sum.x += x
                            sum.y += y
                            return {x: x, y: y}
                        }),
                        n = points.length
                    coord = map.toCoordinate(Qt.point(center.x + sum.x / n * currentScale, center.y + sum.y / n * currentScale))
                    //console.log(JSON.stringify(coord))
                    return {x: coord.longitude, y: coord.latitude}
                } else {
                    return {x: model.x, y: model.y}
                }

            }
        }
    }*/
}
