import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers
import "../../js/utils.js" as Utils

ColumnLayout {
    id: form
    //columns: 2
    anchors.fill: parent
    property bool asyncWait
    property bool changeable: adminMode && (armConfig[activeComponent] & 1)
    property ListModel devicesTree: root.devices.get(0).children
    property ListModel fakeDevices: ListModel{}
    property ListModel devices: model.devices ? model.devices : fakeDevices
    property var values: ({})//[{id: 1, serviceId: 1, value: 1}, {id: 2, serviceId: 1, value: 2}]
    property var currentItem: ({id: 0, serviceId: 0, scopeId: 0})
    property var icons: ({
        check: {text: faFont.fa_check, color: 'green'},
        times: {text: faFont.fa_times, color: 'orange'},
        folder: {text: faFont.fa_folder, color: 'gray'},
        ban: {text: faFont.fa_ban, color: 'orange'}})

    onDevicesChanged: fakeDevices.clear()//console.log('DC', devices)

    GridLayout {
        columns: 2
        Layout.fillWidth: true
        ///////////////////////////////////////////
        Text { text: "Название";  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'name'
            placeholderText: 'Название зоны'
            text: model && model[name] || ''
            enabled: changeable && 1 !== itemId
            validator: RegExpValidator { regExp: /\S+.*/ }
            color: acceptableInput ? palette.text : "red"
        }
        ///////////////////////////////////////////
        Text { text: "Посетителей";  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'maxVisitors'
            placeholderText: 'Максимум в зоне'
            text: model && model[name] || '0'
            enabled: changeable && 1 !== itemId
            validator: RegExpValidator { regExp: /\d+/ }
            color: acceptableInput ? palette.text : "red"
        }
    }

    Rectangle {
        color: "white"
        clip: true
        Layout.fillHeight: true
        Layout.fillWidth: true
        Menu {
            id: menu
            property var currentItem

            MenuItem {
              text: "Добавить всё"
              onTriggered: menu.set(true)
            }
            MenuItem {
              text: "Убрать всё"
              onTriggered: menu.set(false)
            }

            function set(mode) {
                tree.changeSubnodes(currentItem.children, mode)
            }

            function display(item) {
                if (item.children && item.children.count > 0) {
                    currentItem = item
                    menu.popup()
                }
            }
        }
        MyTree {
            id: tree
            //itemValues: ({serviceId: 1, id: 2, switchValue: 1})
            //itemValues: values
            iconProvider: getIcon
            model: devicesTree
            anchors.fill: parent
            getTNID: Utils.getDeviceTNID
            Component.onCompleted: {
                if (changeable) {
                    tree.selected.connect(select)
                    tree.activated.connect(change)
                    tree.contextMenu.connect(menu.display)
                }
                root.devices.updated.connect(redrawIcons)
                //root.users.updated.connect(update)
                form.devicesChanged.connect(redrawIcons)
                //update()
                //redrawIcons()
                //console.log('ZoneForm INIT COMPLETED')
            }

            function changeSubnodes(model, mode) {
                //console.log("MC", model.count)
                if (!model)
                    return
                var item, key

                for (var i = 0; i < model.count; i++) {
                    item = model.get(i)
                    if (!item.isGroup) {
                        removeDev(item.serviceId, item.id)
                        if (mode)
                            devices.append({scope: item.serviceId, id: item.id, flags: 0})
                    }
                    changeSubnodes(item.children, mode)
                }
                iconProvider = getIcon // trigger update
            }

            function redrawIcons() {
                tree.iconProvider = getIcon
            }

            function getIcon(item) {
                if (item.isGroup)
                    return icons.folder
                return devices && Utils.findItem(devices, {scope: item.serviceId, id: item.id}) ? icons.check : icons.times
            }

            function select(item) {
                if (!item.isGroup) {
                    currentItem.id = item.id
                    currentItem.serviceId = item.serviceId
                    currentItem.scopeId = item.scopeId
                }
            }

            function change(item) {
                // ignore "Внешняя территория" and groups
                if (1 === itemId || item.isGroup)
                    return

                if (!removeDev(currentItem.serviceId, currentItem.id))
                    devices.append({scope: currentItem.serviceId, id: currentItem.id, flags: 0})

                tree.redrawIcons()
            }

            function removeDev(serviceId, deviceId) { // find & remove zone-rule pair
                var i, item
                for (i = 0; i < devices.count; i++) {
                    item = devices.get(i)
                    if (item.id === deviceId && item.scope === serviceId) {
                        devices.remove(i)
                        return true
                    }
                }
                return false
            }
        }
    }


    RowLayout {
        //Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            Layout.fillWidth: true
            enabled: changeable && 1 !== itemId && !asyncWait
            text: 0 === itemId ? "Создать" : "Обновить"
            // anchors.centerIn: parent
            onClicked: {
                var payload = {id: itemId},
                    transforms = {maxVisitors: parseInt}

                if (Helpers.readForm(form, payload, transforms)) {
                    //payload.name += " = A"
                    payload.devices = Helpers.getLinks(devices)
                    //console.log("Zones payload:", JSON.stringify(payload))
                    asyncWait = true
                    root.newTask(0, 'UpdateZone', payload, done, fail)
                } else
                    messageBox.error("Заполните форму")
            }
        }
        Button {
            Layout.fillWidth: true
            text: "Удалить"
            enabled: changeable && itemId >= 2 && !asyncWait
            onClicked: messageBox.ask("Удалить зону?", function () {
                asyncWait = true
                root.newTask(0, 'DeleteZone', model.id, done, fail)
            })
        }
    }
    MessageBox {id: messageBox}

    function done(msg) {
        asyncWait = false
        if (0 === itemId)
            zonesTree.findItem(msg.data.id)
    }

    function fail(errText) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + errText)
    }
}
