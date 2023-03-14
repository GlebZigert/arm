import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import "qml/video" as Video
Item {

    anchors.fill: parent


    Video.MultiVM{
    anchors.fill: parent
    }


    onVisibleChanged: {
        if (visible)
            console.log("Item wh: ",width," ",height)
        else
            console.log("Item wh: ",width," ",height)
    }

    onHeightChanged: console.log("onHeightChanged Item wh: ",width," ",height);
    onWidthChanged: console.log("onWidthChanged Item wh: ",width," ",height);

    Component.onCompleted: {
        console.log("Component.onCompleted Item wh: ",width," ",height)
    }

}



