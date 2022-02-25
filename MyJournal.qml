// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.5
import "qml/forms" as Forms
import "js/journal.js" as Journal

QC1.TableView {
    property int panePosition

    id: tableView
    //width: parent.width
//    anchors.fill: parent
    frameVisible: false
    model: root.events
    onRowCountChanged: Qt.callLater(positionViewAtRow, rowCount - 1, ListView.End)
    onDoubleClicked: root.eventSelected(model.get(row))
    //onClicked: showPopup(row)
   MouseArea{
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.RightButton
        onClicked:  {
            var row = tableView.rowAt(mouseX, mouseY)
            if (row >= 0){
                tableView.currentRow = row
                tableView.selection.clear()
                tableView.selection.select(row, row)
                showPopup(row)
            }
        }
    }

    QC1.TableViewColumn {
        role: "color"
        title: ""
        width: 20
        delegate: Text {
            padding: 4
            horizontalAlignment: Text.AlignHCenter
            color: styleData.value || 'gray'
            font.family: faFont.name
            text: faFont.fa_circle
            //font.pixelSize: 14
        }
    }


    QC1.TableViewColumn {
        id: idColumn
        role: "id"
        title: "#"
        width: 50
    }

    QC1.TableViewColumn {
        id: timeColumn
        role: "timeString"
        title: "Время"
        width: 140
    }

    QC1.TableViewColumn {
        id: serviceColumn
        role: "serviceName"
        title: "Источник"
        //width: 100
    }
    QC1.TableViewColumn {
        id: deviceColumn
        role: "deviceName"
        title: "Устройство"
        //width: 100
    }
    QC1.TableViewColumn {
        id: textColumn
        role: "text"
        title: "Событие"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "userName"
        title: "Пользователь"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "zoneName"
        title: "Зона"
        //width: 100
    }
    QC1.TableViewColumn {
        role: "reason"
        title: "Причины"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    QC1.TableViewColumn {
        role: "reaction"
        title: "Принятые меры"
        //width: tableView.viewport.width - serviceColumn.width - deviceColumn.width
    }
    Forms.AlarmPopup{id: popup}

    function showPopup(row) {
        var event = tableView.model.get(row),
            count = Journal.activeAlarms(event)
        if (count >= 0) {
            console.log("ACTIVE ALARMS", count)
            popup.event = event
            popup.alarmsCount = count
            popup.open()
        }

    }
}

