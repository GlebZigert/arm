import QtQuick 2.0
import QtQuick.Controls 2.4


Rectangle{
    id:container
    property int side: (width>height)?height:width

    color: "gray"

    signal current_page(int page)
    signal do_it()

    ListModel{
    id: model
    }


    Grid {
        columns: 4
        spacing: 2
        anchors.fill:parent

       ComboBox{
        id: combo
        model:model
        width:height*4
        height:container.side
        wheelEnabled: true



       }

       Button{

           width:height*3
           height:container.side

           onClicked: {
           var index=combo.currentIndex
           if(index>0)
           {
           combo.currentIndex--
           }
           else
           {
           combo.currentIndex=combo.count-1
           }
           container.current_page_changed()
           }
       }


       Button{
           width:height*3
           height:container.side

           onClicked: {
           var index=combo.currentIndex
           if(index<combo.count-1)
           {
           combo.currentIndex++
           }
           else
           {
           combo.currentIndex=0
           }
           container.current_page_changed()
           }

       }

    }


    function set_count(val)
    {
    model.clear()
        for(var i=0;i<val;i++)
         model.append({number:i+1})
    }

    Component.onCompleted: {
    combo.activated.connect(current_page_changed)

    }

    function current_page_changed()
    {
        var dt=new Date();
        current_page(combo.currentIndex+1)
    }


}


