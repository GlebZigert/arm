import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4 as QQC1

Rectangle{
    id:container
    property int side: (width>height)?height:width

    color: "gray"

    signal cancel

    signal current_page(int page)
    signal do_it()

    ListModel{
    id: model
    }

    Timer{
    id: timer
    running: false
    repeat: false
    interval: 300
    onTriggered: {
        console.log("current_page(combo.currentIndex+1)")
        var dt=new Date();
        current_page(combo.currentIndex+1)
    }
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

        QQC1.Button{

           width:height*3
           height:container.side
           style: ButtonStyle {
               label: Text {
                   text:"Назад"
               }
           }
           onClicked: {
               console.log("combo.currentIndex ",combo.currentIndex)
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


        QQC1.Button{
           width:height*3
           height:container.side
           style: ButtonStyle {
               label: Text {
                   text:"Вперед"
               }
           }
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


        QQC1.Button{
           width:height*3
           height:container.side
           style: ButtonStyle {
               label: Text {
                   text:"Отмена"
               }
           }
           onClicked: {
              container.cancel()
           }

       }



    }


    function set_count(val)
    {var cnt=combo.currentIndex;
     //   console.log("set_count")
    model.clear()
        for(var i=0;i<val;i++)
         model.append({number:i+1})

        if(cnt<combo.count)
            combo.currentIndex=cnt
    }

    Component.onCompleted: {
    combo.activated.connect(current_page_changed)

    }

    function current_page_changed()
    {
        timer.stop()
        timer.start()
      //  var dt=new Date();
      //  current_page(combo.currentIndex+1)
    }


}



