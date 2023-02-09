import QtQuick 2.0
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5
import QtQml 2.13

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
        root.newAlarms.connect(openIfNeeded)
        if (null !== item)
            updateRecord(item)
        else
            updateList()
    })

    function openIfNeeded() {
        if (autoOpen.checked)
            open()
    }

    function showDeviceAlarm(deviceId) {
        var i,
            item,
            alarm
        for (i = 0; i < alarms.count; i++) {
            item = alarms.get(i)
            if (deviceId === item.deviceId) {
                alarm = item
                if ("" === item.reason || "" === item.reaction)
                    break
            }
        }
        if (alarm) {
            open()
            tableView.showPopup(alarm.id)
        }
    }

    function saveSelection() {
        var selected = {}
        tableView.selection.forEach((i) => {selected[alarms.get(i).id] = null})
        return selected
    }

    function restoreSelection(selected) {
        var i,
            item
        tableView.currentRow = -1
        tableView.selection.clear()
        for (i = 0; i < alarms.count; i++)
            if (alarms.get(i).id in selected)
                tableView.selection.select(i, i)
    }

    function updateList() {
        var i,
            item,
            alarmId,
            selection = saveSelection(),
            items = Journal.alarmRecords(),
            actual = items.reduce((o, v) => {o[v.id] = null; return o}, {})

        // topbar alarm text
        item = items.pop()
        if (item) {
            menu.setAlarm(1 + items.length, (item.deviceName || item.serviceName) + ': ' + item.text)
        } else
            menu.setAlarm(0, '')

        // inject new items
        for (i = alarms.count - 1; i >= 0; i--) {
            alarmId = alarms.get(i).id
            if (!(alarmId in actual)) {
                alarms.remove(i)
                continue
            }
            while (item && item.id !== alarmId) {
                alarms.insert(i+1, item)
                item = items.pop()
            }
            while (item && item.id === alarmId)
                item = items.pop()
        }

        // inject the rest
        while (item) {
            alarms.insert(0, item)
            item = items.pop()
        }

        restoreSelection(selection)
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

    function checkAlarms(lists) {
        var i,
            item
        for (i = 0; i < alarms.count; i++) {
            item = alarms.get(i)
            if (item.serviceId in lists && item.deviceId in lists[item.serviceId] && ("" === item.reason || "" === item.reaction))
                return false
        }
        return true
    }

    // accept failed services list
    function displayFailures(failures) {
        failures.push(names[serviceId] + ': ' + t)
        messageBox.error(failures.join('\n'))
    }

    // -1 => reset all
    // 0  => reset selected
    // n => reset zone #n
    function resetAlarms(zoneId) {
        var counter,
            names = {},
            lists = {},
            failures = {},
            filter = zoneId > 0 ? getZoneDevices(zoneId) : null

        var next = () => {
            if (--counter <= 0 && failures.length > 0)
                messageBox.error(failures.join('\n'))
        }
        var fail = (serviceId, t) => {
            failures.push(names[serviceId] + ': ' + t)
            next()
        }
        var process = (i) => {
            var item = alarms.get(i)
            if (filter && !(item.deviceId in filter)) return

            if (!(item.serviceId in lists)) {
                names[item.serviceId] = item.serviceName
                lists[item.serviceId] = {}
            }
            lists[item.serviceId][item.deviceId] = null
            //ignored = ignored || "" === item.reason || "" === item.reaction // .trim() is performed on the server side
        }
        var reset = () => {
            counter = Object.keys(lists).length
            for (let i in lists) {
                let devs = Object.keys(lists[i]).map((v) => {return parseInt(v)})
                root.newTask(i, 'ResetAlarm', devs, next, fail.bind(this, i))
            }
        }

        if (0 === zoneId)
            tableView.selection.forEach(process)
        else
            for (let i = 0; i < alarms.count; i++) process(i)

        if (!checkAlarms(lists))
            messageBox.ask("Не все тревоги обработаны, продолжить?", reset)
        else
            reset()
    }

    function getZoneDevices(zoneId) {
        var i,
            items,
            devices = {},
            zones = root.zones.get(0).children

        for (i = 0; i < zones.count && zones.get(i).id !== zoneId; i++);
        if (i >= zones.count) return

        items = zones.get(i).devices
        for (i = 0; i < items.count; i++)
            devices[items.get(i).id] = null

        return devices
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
                onClicked: tableView.showCurrent()
            }

            Button {
                Layout.fillWidth: true
                text: "Сброс выбранных"
                enabled: tableView.selection.count > 0
                onClicked: resetAlarms(0)
            }

            Button {
                Layout.fillWidth: true
                text: "Сброс зоны"
                enabled: alarms.count > 0
                onClicked: zMenu.show()
            }

            Button {
                Layout.fillWidth: true
                text: "Сброс всех"
                enabled: alarms.count > 0
                onClicked: resetAlarms(-1)
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

        Menu {
            id: zMenu
              Instantiator {
                  delegate: MenuItem {
                      font.bold: model.bold
                      text: model.name
                      onTriggered: resetAlarms(model.zoneId)
                  }

                  model: ListModel {
                      id: menuItemsModel
                      ListElement{zoneId: 0; name: "placeholder"; bold: false} // !important
                  }
                  onObjectAdded: zMenu.insertItem(index, object)
                  onObjectRemoved: zMenu.removeItem(object)
              }
              function show(serviceId, deviceId) {
                  var i, j,
                        id,
                        item,
                        devices = {}, // devs with alarm
                        zones = root.zones.get(0).children,
                        devId = tableView.currentRow < 0 ? -1 : alarms.get(tableView.currentRow).deviceId

                  for (i = 0; i < alarms.count; i++) {
                      item = alarms.get(i)
                      devices[item.deviceId] = null
                  }

                  menuItemsModel.clear()
                  for (i = 0; i < zones.count; i++) {
                      item = zones.get(i)
                      let add = 0 // 0 - don't add, 1 - regular, 2 - bold
                      for (j = 0; j < item.devices.count; j++) {
                          id = item.devices.get(j).id
                          if (id === devId)
                              add |= 2
                          else if (id in devices)
                              add |= 1
                      }

                      if (add > 0)
                          menuItemsModel.append({zoneId: item.id, name: item.name, bold: (add & 2) > 0})
                  }

                  if (menuItemsModel.count > 0)
                    zMenu.popup()
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
