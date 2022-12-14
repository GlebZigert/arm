// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import "qml/forms" as Forms

RowLayout {
    property bool adminMode: true
    property int panePosition
    //anchors.fill: parent

    ListModel {id: eventsList}

    Item {
        //signal send(var msg);
        readonly property int maxRecords: 200

        Layout.fillHeight: true
        Layout.fillWidth: true

        Forms.EventTable {
            id: tableView
            //width: parent.width
            anchors.fill: parent
            frameVisible: false
            model: eventsList
            onDoubleClicked: root.eventSelected(model.get(row))
        }
    }
    // right panel
    Rectangle {
        visible: adminMode
        color: "lightgray"
        Layout.fillHeight: true
        Layout.minimumWidth: 330
        Forms.EventsFilterForm{}
    }
}

