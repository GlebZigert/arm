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

    function resetAlarms(all) {
        var counter,
            names = {},
            lists = {},
            failures = [],
            ignored = false
        var done = () => {
            if (--counter <= 0 && failures.length > 0)
                messageBox.error(failures.join('\n'))
        }
        var fail = (serviceId, t) => {
            failures.push(names[serviceId] + ': ' + t)
            done()
        }
        var process = (i) => {
            var item = alarms.get(i)
            if (!(item.serviceId in lists)) {
                names[item.serviceId] = item.serviceName
                lists[item.serviceId] = {}
            }
            lists[item.serviceId][item.deviceId] = true
            ignored = ignored || "" === item.reason.trim() || "" === item.reaction.trim()
        }
        var reset = () => {
            counter = Object.keys(lists).length
            for (let i in lists) {
                let devs = Object.keys(lists[i]).map((v) => {return parseInt(v)})
                root.newTask(i, 'ResetAlarm', devs, done, fail.bind(this, i))
            }
        }

        if (all)
            for (let i = 0; i < alarms.count; i++) process(i)
        else
            tableView.selection.forEach(process)

        if (ignored)
            messageBox.ask("Не все тревоги обработаны, продолжить?", reset)
        else
            reset()
    }

    ColumnLayout {
        anchors.fill: parent
        JournalStub {
            id: tableView

            //frameVisible: false
            model: alarms
            Layout.fillHeight: true
            Layout.fillWidth: true
            selectionMode: 2 // SelectionMode.MultiSelection => https://doc.qt.io/qt-5/qabstractitemview.html#SelectionMode-enum
            //sortIndicatorVisible: true
        }

        RowLayout {
            Layout.columnSpan: 2
            CheckBox {
                id: autoOpen
                text: "Открывать при тревоге"
                checked: true
            }

            Button {
                Layout.fillWidth: true
                text: "Обработка"
                enabled: 1 === tableView.selection.count
                onClicked: tableView.showPopup()
            }

            Button {
                Layout.fillWidth: true
                text: "Сброс выбранных"
                enabled: tableView.selection.count > 0
                onClicked: resetAlarms()
            }

            Button {
                Layout.fillWidth: true
                text: "Сброс всех"
                enabled: alarms.count > 0
                onClicked: resetAlarms(true)
            }

            Button {
                Layout.fillWidth: true
                text: "Выход"
                onClicked: popup.close()
            }

            Keys.onReturnPressed: {
                event.accepted = true
            }
        }
    }

    onClosed: scale = 1 // fix for enter/exit animation side effect in Linux
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
