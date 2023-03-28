// https://stackoverflow.com/questions/60141251/how-can-i-dynamically-draw-a-polygon-and-make-its-points-markers-movable-in-qml?rq=1
import QtQuick 2.0
import QtQuick.Window 2.13
import QtLocation 5.13
import QtPositioning 5.13

Window {
    visible: true
    width: 640
    height: 480
    property int currentIndex: -1
    ListModel{
        id: polygonmodel
    }
    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin {
            name: "esri"
        }
        gesture.enabled: currentIndex == -1
        center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14
        MapItemView{
            z: polygon.z + 1
            model: polygonmodel
            delegate: MapQuickItem{
                anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                coordinate: QtPositioning.coordinate(model.coords.latitude, model.coords.longitude)
                sourceItem: Rectangle {
                    width: 10
                    height: 10
                    color: Qt.rgba(255, 255, 255, .5)
                    border.color: "black"
                    border.width: 1

                    MouseArea{
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        propagateComposedEvents: true
                        onPressed: {
                            currentIndex = index
                            mouse.accepted = false
                        }
                    }
                }
            }
        }
        MapPolygon{
            id: polygon
            color: Qt.rgba(0, 0, 255, 0.2)
            border.color: "blue"
            border.width: 2
        }
        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                var point = Qt.point(mouse.x, mouse.y)
                var coord = map.toCoordinate(point);
                if (mouse.button === Qt.RightButton)
                    addMarker(coord)
            }
            onPositionChanged: {
                    checkMarker(mouse.x, mouse.y)
            }
            onReleased: {
                if (mouse.button === Qt.LeftButton) {
                    checkMarker(mouse.x, mouse.y)
                    currentIndex = -1;
                }
            }
        }
    }
    function checkMarker(x, y) {
        var point = Qt.point(x, y)
        var coord = map.toCoordinate(point);
        if(currentIndex !== -1 && coord.isValid)
            moveMarker(currentIndex, coord)

    }

    function moveMarker(index, coordinate){
        polygonmodel.set(index, {"coords": coordinate})
        var path = polygon.path;
        path[index] = coordinate
        polygon.path = path
    }
    function addMarker(coordinate){
        polygonmodel.append({"coords": coordinate})
        polygon.addCoordinate(coordinate)
    }
}
