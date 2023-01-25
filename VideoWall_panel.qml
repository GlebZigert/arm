import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import "qml/video" as Video
Item {


 //   anchors.fill: parent
    width: parent.width
    height: parent.height
    id: supreme
    ListModel {
        id: work_model

        dynamicRoles: true

     }



Rectangle{

    anchors.fill: parent
    color: "green"

    GridLayout {
        anchors.fill: parent
        id: grid

        columnSpacing: 0

        rowSpacing: 0
           rows: 5
           columns: 5




 baselineOffset: 1

    Repeater{
    //    id: rpt

        model: 20




        Item {
            width: grid.width/grid.columns
            height: grid.height/grid.rows

        //      width: (height/1080)*1920
        //      height: 250

            signal isSelected(int index)

            property int index
            property bool selected
     //       property bool contain_mouse: area.containsMouse ? true : false

            Rectangle{
                anchors.fill:parent
            color: selected? "lightgray" : "gray"

            Component.onCompleted: {
            console.log(grid.width," ",grid.height)
            }

             }

}


}

}

}

}



