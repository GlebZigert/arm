import QtQuick 2.0
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5

import "helpers.js" as Helpers
import "../../js/journal.js" as Journal

Popup {
    //property int arr:
    id: popup
    modal: true
    focus: true
    //anchors.centerIn: Overlay.overlay
    parent: Overlay.overlay
    anchors.centerIn: parent
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    width: parent.width > 1250 ? 1250 : (parent.width - 50)
    height: 600

    property ListModel alarms: ListModel{}

    onOpened: tableView.showRecent()
    Component.onCompleted: root.events.updated.connect(function (item) {
        //https://doc.qt.io/qt-5/qabstractitemmodel.html#rowsInserted
        if (null !== item)
            updateRecord(item)
        else
            updateList()
    })

    function openIfNeeded() {
        if (autoOpen.checked)
            open()
    }

    function updateList() {
        var ev,
            r = Journal.alarmRecords()
        alarms.clear()
        alarms.append(Journal.alarmRecords())
        if (r.length > 0) {
            ev = r[r.length-1]
            menu.setAlarm(r.length, (ev.deviceName || ev.serviceName) + ': ' + ev.text)
        } else
            menu.setAlarm(0, '')
    }

    function updateRecord(event) {
        var i,
            item
        for (i = 0; i < alarms.count; i++) {
            item = alarms.get(i)
            if (item.id === event.id) {
                alarms.set(i, event)
                break
            }
        }
    }


    ColumnLayout {
        anchors.fill: parent
        JournalStub {
            id: tableView

            //frameVisible: false
            model: alarms
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.columnSpan: 2
            CheckBox {
                id: autoOpen
                text: "Открывать при тревоге"
                checked: true
            }
            Item {Layout.fillWidth: true}

            Button {
                implicitWidth: autoOpen.width
                text: "Выход"
                onClicked: popup.close()
            }

            Keys.onReturnPressed: {
                event.accepted = true
            }
        }
    }

    enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity";
                    from: 0.0;
                    to: 1.0;
                    duration: 300
                }
                NumberAnimation {
                    property: "scale";
                    from: 0.4;
                    to: 1.0;
                    easing.type: Easing.OutBack
                    duration: 300
                }
            }
        }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity";
                from: 1.0
                to: 0.0;
                duration: 200
            }
            NumberAnimation {
                property: "scale";
                from: 1.0
                to: 0.6;
                duration: 200
            }
        }
    }
}
