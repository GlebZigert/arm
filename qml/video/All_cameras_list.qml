import QtQuick 2.0

Rectangle{
    id:container


color: "lightgray"

//------------------------------------
ListModel{
id: model
ListElement{number:"1"}
ListElement{number:"2"}
ListElement{number:"3"}


}


Column{
    anchors.fill: parent

Repeater{

model: model

delegate:

Rectangle{
width: 100
height: 30
color: "#ffe4c4"
border.color: "black"
border.width: 2

Text{

x: parent.width/4
y:parent.height/4
font.family: "Helvetica"
font.pointSize: 10
color: "black"
text: modelData.number
}


MouseArea {
    id: dragArea1
    anchors.fill: parent

    drag.target: parent

    onReleased:
    {
        //console.log("[onReleased]")

    }

}
}
}
}
//------------------------------------
}
