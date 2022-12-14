// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import "../../js/journal.js" as Journal

EventTable {
    id: tableView
    onRowCountChanged: {
        selection.clear()
        if (currentRow >= 0)
            selection.select(currentRow)
        if (flickableItem.atYEnd)
            Qt.callLater(positionViewAtRow, rowCount - 1, ListView.Contain)
    }
    onVisibleChanged: if (visible) Qt.callLater(showRecent)
    onDoubleClicked: root.eventSelected(model.get(row))
    //onClicked: showPopup(row)
    Keys.onReturnPressed: {
        showPopup(tableView.currentRow)
        event.accepted = true
    }

    function showRecent() {
        positionViewAtRow(rowCount - 1, ListView.Contain)
    }

    MouseArea {
        property int headerHeight: 25
        anchors.fill: parent
        anchors.topMargin: headerHeight
        propagateComposedEvents: true
        acceptedButtons: Qt.RightButton
        onClicked:  {
            var row = tableView.rowAt(mouseX, mouseY + headerHeight)
            if (row >= 0){
                tableView.currentRow = row
                tableView.selection.clear()
                tableView.selection.select(row, row)
                showPopup(row)
            }
        }
    }


    AlarmPopup{id: popup}

    function showPopup(row) {
        var event = tableView.model.get(row),
            count = Journal.activeAlarms(event)
        if (count >= 0) {
            //console.log("ACTIVE ALARMS", count)
            popup.event = event
            popup.alarmsCount = count
            popup.open()
        }
    }
}
