// guide1: https://martin.rpdev.net/2019/01/15/using-delegatemodel-in-qml-for-sorting-and-filtering.html
// guide2: http://imaginativethinking.ca/use-qt-quicks-delegatemodelgroup/

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import QtQml.Models 2.4
import "../../js/utils.js" as Utils


Rectangle {
    id: pageRoot
    property ListModel devicesTree: root.devices.get(0).children
    property ListModel devices: model.devices
    property var currentModel: model // TODO: not used on page2 for zones - much simple here!
    property bool changeable: adminMode && armConfig[activeComponent] & 4
    property var values: ({})//[{id: 1, serviceId: 1, value: 1}, {id: 2, serviceId: 1, value: 2}]
    property var currentItem: ({id: 0, serviceId: 0, scopeId: 0})
    property var folderIcon: ({text: faFont.fa_folder, color: 'gray'})
    property var icons: [
        {text: faFont.fa_eye_slash, color: 'gray'},
        {text: faFont.fa_eye, color: 'green'},
        {text: faFont.fa_hand_point_right, color: 'red'}]

    color: "white"
    clip: true

    Menu {
        id: menu
        property var currentItem

        MenuItem {
          text: "Без доступа"
          onTriggered: menu.set(0)
        }
        MenuItem {
          text: "Только просмотр"
          onTriggered: menu.set(1)
        }
        MenuItem {
          text: "Полный доступ"
          onTriggered: menu.set(2)
        }

        function set(n) {
            tree.changeSubnodes(currentItem.children, n)
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
            root.devices.updated.connect(update)

            //root.users.updated.connect(update)
            pageRoot.devicesChanged.connect(update)
            pageRoot.currentModelChanged.connect(update) // TODO: not used on page2 for zones
            update()
            //console.log('UF PAGE-3 INIT COMPLETED')
        }

        // populate values
        function update() {
            if (!tree) { // TODO: WTF?!
                console.log('UP3-UPD not ready')
                return
            }
            //console.log('UP3-UPD started')
            if (values)
                values = {}
            if (!devices || !devicesTree) {
                tree.iconProvider = getIcon // trigger update
                return
            }

            var i,
                key,
                flags,
                item
            for (i = 0; i < devices.count; i++) {
                item = devices.get(i)
                flags = item.flags & 3
                //console.log(item.id, flags)
                if (flags) {
                    key = [item.id , item.scope, 0].join(':')
                    values[key] = flags
                }
            }
            //console.log('=== VAL UPDATE ==>', JSON.stringify(values))
            tree.iconProvider = getIcon // trigger update
        }

        function getIcon(item) {
            //return values[item.id % values.length].value
            var key = [item.id || 0, item.serviceId || 0, item.scopeId || 0].join(':')
            //console.log('>>>>>>>>>', JSON.stringify(value))
            if (item.isGroup)
                return folderIcon
            else if (key in values)
                return icons[values[key]]
            else
                return icons[0]
        }

        function select(item) {
            if (item.isGroup) return
            //if (currentItem.id !== item.id || currentItem.serviceId !== item.serviceId || currentItem.scopeId !== item.scopeId) {
                currentItem.id = item.id
                currentItem.serviceId = item.serviceId
                currentItem.scopeId = item.scopeId
                //console.log(selected.id !== item.id, selected.serviceId !== item.serviceId, selected.scopeId !== item.scopeId)
            //}
        }

        function change(item) {
            if (item.isGroup) return
            var i,
                key = [item.id || 0, item.serviceId || 0, item.scopeId || 0].join(':'),
                realItem = Utils.findItem(devicesTree, {id: item.id, serviceId: item.serviceId})

            if (key in values)
                values[key] = (values[key] + 1) % icons.length
            else {
                values[key] = 1
            }
            //changeSubnodes(realItem.children, values[key])

            iconProvider = getIcon // trigger update
            //console.log(JSON.stringify(values))
        }

        function changeSubnodes(model, n) {
            //console.log("MC", model.count)
            if (!model)
                return
            var item, key

            for (var i = 0; i < model.count; i++) {
                item = model.get(i)
                if (!item.isGroup) {
                    key = [item.id || 0, item.serviceId || 0, item.scopeId || 0].join(':')
                    values[key] = n
                }
                changeSubnodes(item.children, n)
            }
            iconProvider = getIcon // trigger update
        }
    }
}
