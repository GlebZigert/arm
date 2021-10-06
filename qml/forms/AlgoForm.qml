import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers
import "../../js/utils.js" as Utils
import "../../js/constants.js" as Const

GridLayout {
    id: form
    columns: 2
    anchors.fill: parent
    anchors.margins: 5

    property int userId: model.userId || 0
    //property int zoneId: model.zoneId || 0
    property int serviceId: model.serviceId || 0
    property int deviceId: model.deviceId || 0
    property int targetServiceId: model.targetServiceId || 0
    property int targetDeviceId: model.targetDeviceId || 0

    property alias sourceType: sourceCombo.currentIndex
    property alias targetType: targetCombo.currentIndex

    onSourceTypeChanged: 0 === sourceType ? updateDevEvents() : updateZoneEvents()
    onTargetTypeChanged: 0 === targetType? updateDevCommands() : updateZoneCommands()

    /*property var model0: model
    onModel0Changed: if (itemId) {
        //toEvent.model.clear()
        //fromState.model.clear()
    }*/

    onUserIdChanged: if (0 !== userId) Qt.callLater(updateUser)
    onDeviceIdChanged: if (0 !== deviceId) Qt.callLater(updateSource)
    onTargetDeviceIdChanged: if (0 !== targetDeviceId) Qt.callLater(updateTarget)
    //onTargetServiceIdChanged: updateCommands() // TODO: double call?

    ///////////////////////////////////////////
    Text { text: "Название";  Layout.alignment: Qt.AlignRight }
    TextField {
        property string name: 'name'
        Layout.fillWidth: true
        placeholderText: 'Название алгоритма'
        text: model && model[name] || ''
        validator: RegExpValidator { regExp: /\S+.*/ }
        color: acceptableInput ? palette.text : "red"
    }
    ///////////////////////////////////////////
    Rectangle { // separator
        Layout.columnSpan: 2
        Layout.fillWidth: true
        height: 2
        color: "gray"
        Layout.topMargin: 10
        Layout.bottomMargin: 10
    }
    ///////////////////////////////////////////
    Text { text: "Источник";  Layout.alignment: Qt.AlignRight }
    property int userId0: model.userId || 0
    ComboBox {
        id: sourceCombo
        Layout.fillWidth: true
        model: ['Устройство', 'Пользователь']
        //onCurrentIndexChanged: 0 === currentIndex ? userId = 0 : serviceId = serviceId = 0//updateDevEvents() : updateZoneEvents()
        currentIndex: itemId ? (userId0 > 0 ? 1 : 0) : -1
    }
    ///////////////////////////////////////////
    Text { text: "Пользователь"; visible: 1 === sourceType; Layout.alignment: Qt.AlignRight }
    TextField {
        id: srcUser
        Layout.fillWidth: true
        readOnly: true
        visible: 1 === sourceType
        onPressed: userSelector.display(userId, function (item) {
            userId = item && item.id || 0
        })
    }
    ///////////////////////////////////////////
    Text { text: "Устройство"; visible: 0 === sourceType; Layout.alignment: Qt.AlignRight }
    TextField {
        id: sourceDevice
        readOnly: true
        Layout.fillWidth: true
        visible: 0 === sourceType
        onPressed: deviceSelector.display(serviceId, deviceId, selected)
        function selected(item) {
            //console.log("Selected:", item.name, item.serviceId, item.id)
            if (item && item.id && item.serviceId) {
                /*model.serviceId = item.serviceId
                model.deviceId = item.id
                model = model // force update*/
                serviceId = item.serviceId
                deviceId = item.id
            }
        }
    }
    ///////////////////////////////////////////
    Text { text: "Переход из"; visible: 0 === sourceType; Layout.alignment: Qt.AlignRight }
    property int fromState0: model.fromState || 0
    ComboBox {
        id: fromState
        Layout.fillWidth: true
        enabled: visible
        visible: 0 === sourceType
        property string name: 'fromState'
        property int fieldValue
        textRole: "text"
        model: ListModel{} // all states
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== fromState0; i--); i}
        onCurrentIndexChanged: fieldValue = currentIndex < 0 || currentIndex >= model.count ? -1 : model.get(currentIndex).id
    }
    ///////////////////////////////////////////
    Text { text: "Зона"; visible: 1 === sourceType; Layout.alignment: Qt.AlignRight }
    property int srcZone0: model.zoneId || 0
    ComboBox {
        id: srcZoneCombo
        property string name: 'zoneId'
        property int fieldValue
        enabled: 1 === sourceType
        visible: enabled
        Layout.fillWidth: true
        textRole: "name"
        model: root.zones.get(0).children
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== srcZone0; i--); i}
        onCurrentIndexChanged: fieldValue = currentIndex < 0 || currentIndex >= model.count ? -1 : model.get(currentIndex).id
    }
    ///////////////////////////////////////////
    property string eventText: 0 === sourceType ? "...в" : "Событие"
    Text { text: eventText; Layout.alignment: Qt.AlignRight }
    property int event0: model.event || 0
    ComboBox {
        id: toEvent
        property string name: 'event'
        property int fieldValue
        Layout.fillWidth: true
        textRole: "text"
        model: ListModel{} // all roles
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== event0; i--); i}
        onCurrentIndexChanged: fieldValue = currentIndex < 0 || currentIndex >= model.count ? -1 : model.get(currentIndex).id
    }
    ///////////////////////////////////////////
    Rectangle { // separator
        Layout.columnSpan: 2
        Layout.fillWidth: true
        height: 2
        color: "gray"
        Layout.topMargin: 10
        Layout.bottomMargin: 10
    }
    ///////////////////////////////////////////
    Text { text: "Цель";  Layout.alignment: Qt.AlignRight }
    property int tgtZoneId0: model.targetZoneId || 0
    ComboBox {
        id: targetCombo
        Layout.fillWidth: true
        model: ['Устройство', 'Зона']
        //onCurrentIndexChanged: 0 === currentIndex ? targetZoneId = 0 : targetServiceId = targetDeviceId = 0//updateDevCommands() : updateZoneCommands()
        currentIndex: itemId ? (tgtZoneId0 > 0 ? 1 : 0) : -1
    }
    ///////////////////////////////////////////
    Text { text: "Устройство";  visible: 0 === targetCombo.currentIndex; Layout.alignment: Qt.AlignRight }
    TextField {
        id: targetDevice
        visible: 0 === targetType
        readOnly: true
        Layout.fillWidth: true
        onPressed: deviceSelector.display(targetServiceId, targetDeviceId, function (item) {
            //console.log("Selected:", item.name, item.serviceId, item.id)
            if (item && item.id && item.serviceId) {
                /*model.targetServiceId = item.serviceId
                model.targetDeviceId = item.id
                model = model  // force update*/
                targetServiceId = item.serviceId
                targetDeviceId = item.id
            }
        })
    }
    ///////////////////////////////////////////
    Text { text: "Зона"; visible: 1 === targetType; Layout.alignment: Qt.AlignRight }
    property int tgtZone0: model.targetZoneId || 0
    ComboBox {
        id: tgtZoneCombo
        property string name: 'targetZoneId'
        property int fieldValue
        enabled: 1 === targetType
        visible: enabled
        Layout.fillWidth: true
        textRole: "name"
        model: root.zones.get(0).children
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== tgtZone0; i--); i}
        onCurrentIndexChanged: fieldValue = currentIndex < 0 || currentIndex >= model.count ? -1 : model.get(currentIndex).id
    }
    ///////////////////////////////////////////
    Text { text: "Команда";  Layout.alignment: Qt.AlignRight }
    property int command0: model.command || 0
    ComboBox {
        id: commands
        property string name: 'command'
        property int fieldValue
        Layout.fillWidth: true
        textRole: "text"
        model: ListModel{}
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== command0; i--); i}
        onCurrentIndexChanged: fieldValue = currentIndex < 0 || currentIndex >= model.count ? -1 : model.get(currentIndex).id

    }
    ///////////////////////////////////////////
    Text { text: "Аргумент";  Layout.alignment: Qt.AlignRight }
    // TODO: bug fix
    TextField {
        property string name: 'argument'
        Layout.fillWidth: true
        text: model.argument || ''
        validator: RegExpValidator { regExp: /\d*/ }
    }


    RowLayout {
        Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            Layout.fillWidth: true
            text: 0 === itemId ? "Создать" : "Обновить"
            // anchors.centerIn: parent
            onClicked: saveForm()
        }
        Button {
            Layout.fillWidth: true
            text: "Удалить"
            enabled: itemId !== 0
            onClicked: root.send('configuration', 'DeleteAlgorithm', model.id)
        }
    }

    MessageBox {id: messageBox}
    DeviceSelector {
        id: deviceSelector
        devicesTree: root.devices
    }
    UserSelector {
        id: userSelector
        userTree: root.users
    }

    function updateUser() {
        var user = Utils.findItem(root.users, userId)
        srcUser.text = user ? user.label : ''
        updateZoneEvents()
        //updateZoneCommands()
    }

    function updateTarget() {
        var device = Utils.findItem(root.devices, {id: targetDeviceId, serviceId: targetServiceId})
        targetDevice.text = device ? device.name : ''
        updateDevCommands()
    }

    function updateDevCommands() {
        var list,
            k,
            model = [],
            service = root.services[targetServiceId]

        // update commands
        commands.model.clear()
        if (service && 'listCommands' in service) {
            list = service.listCommands(targetDeviceId)
            //console.log("Commands:", JSON.stringify(list))
            if (list) {
                for (k in list)
                    model.push({id: Number(k), text: list[k]})
                commands.model.append(model)
            }
        }
    }

    function updateZoneCommands() {
        commands.model.clear()
        commands.model.append([
              {id: Const.EC_ARMED, text: "Поставить на охрану"},
              {id: Const.EC_DISARMED, text: "Снять с охраны"}
        ])
    }

    function updateZoneEvents() {
        toEvent.model.clear()
        toEvent.model.append([
              {id: Const.EC_ENTER_ZONE, text: "Вход в зону"},
              {id: Const.EC_EXIT_ZONE, text: "Выход из зоны"}
        ])
    }

    function updateSource() {
        //console.log('UPD SOURCE!')
        var device = Utils.findItem(root.devices, {id: deviceId, serviceId: serviceId})
        sourceDevice.text = device ? device.name : ''
        updateDevEvents()
    }

    function updateDevEvents() {
        var list,
            k,
            model = [],
            service = root.services[serviceId]

        // update states
        toEvent.model.clear()
        fromState.model.clear()
        if (service && 'listStates' in service) {
            list = service.listStates(deviceId)
            //console.log("States:", JSON.stringify(list))
            if (list) {
                model = []
                for (k in list)
                    model.push({id: Number(k), text: list[k]})

                //console.log("MODEL:", JSON.stringify(model))
                model.unshift({id: -1, text: 'Любое'})
                toEvent.model.append(model)
                fromState.model.append(model)
            }
        }
    }

    //////////////////////////////////////////////////////////////////////////

    function done(msg) {
        tree.findItem(msg.data.id)
    }

    function saveForm() {
        var payload = {id: itemId},
            ok = Helpers.readForm(form, payload) && 0 < payload.command

        console.log("OK-1", ok)
        if (0 === sourceType) {
            // source - device
            payload.serviceId = serviceId
            payload.deviceId = deviceId
            ok = ok && 0 < serviceId && 0 < deviceId
        } else {
            // source - user
            payload.userId = userId
            //payload.zoneId = zoneId
            ok = ok && userId > 0 && payload.zoneId > 0
        }
        console.log("OK-2", ok)
        if (0 === targetType) {
            // target - device
            payload.targetServiceId = targetServiceId
            payload.targetDeviceId = targetDeviceId
            ok = ok && 0 < targetServiceId && 0 < targetDeviceId
        } else {
            // target - zone
            ok = ok && payload.targetZoneId > 0
        }

        console.log("OK-3", ok)
        if (ok) {
            payload.argument = parseInt(payload.argument)
            console.log("AlgoForm payload:", JSON.stringify(payload))
            root.newTask('configuration', 'UpdateAlgorithm', payload, done, function (){console.log('UpdateAlgo failed')})
        } else
            messageBox.error("Форма заполнена некорректно")
    }
}
