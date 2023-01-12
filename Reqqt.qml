import QtQuick 2.0

Item {
    Rectangle{
    id: r1
    x:300
    y:300
    width: 100
    height: 100


 //   color:  area.containsMouse ? "red" : "green"

    onFocusChanged: {
    console.log(" ",activeFocus)
    }
   focus: true
    Keys.onPressed: {
        console.log(" !")

    }

    MouseArea{

        Rectangle{
        anchors.fill: parent
       color:  area.containsMouse ? "green" : "red"
        }

        id: area
        anchors.fill: r1
        hoverEnabled: true

    onEntered: {
        console.log(" containsMouse ",area.containsMouse)
        r1.forceActiveFocus()
        }


    onExited:  {
    console.log(" containsMouse ",area.containsMouse)
        r1.focus=false
    }
    }




    }
}
