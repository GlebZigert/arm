import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import QtQml.Models 2.1

import "helpers.js" as Helpers

GridLayout {
    id: form
    columns: 2
    anchors.fill: parent

    property ListModel myCamList: ListModel{}
    property int itemId: model.id
    onItemIdChanged: customCamList() // TODO: use signals for list rebuild? See: https://doc.qt.io/qt-5/qabstractitemmodel.html#rowsInserted

    function customCamList() {
        myCamList.clear()
        myCamList.append({id: 0, name: "-- нет --"})
        for (let i = 0; i < cameraList.count; i++) {
            let item = cameraList.get(i)
            myCamList.append({id: item.id, name: item.name})
        }
    }

    ///////////////////////////////////////////
    Text { text: "Название";  Layout.alignment: Qt.AlignRight }
    TextField {
        property string name: 'name'
        placeholderText: 'Название'
        text: model && model[name] || ''
        validator: RegExpValidator { regExp: /\S+.*/ }
        color: acceptableInput ? palette.text : "red"
    }
    ///////////////////////////////////////////
    Text { text: "Вход";  Layout.alignment: Qt.AlignRight }
    //property int intZone: model && model.zones.length > 0 && model.zones[0].id || 0
    property int intZone: findZone(1)
    ComboBox {
        // entrance is a gate to the `internalZone`
        property string name: 'internalZone'
        textRole: "name"
        model: root.zones.get(0).children
        Layout.fillWidth: true
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.intZone; i--); i}
    }
    ///////////////////////////////////////////
    Text { text: "Камера 1";  Layout.alignment: Qt.AlignRight }
    property int extCam: model.externalCam
    ComboBox {
        // `externalCam` is watching for the `entrance` to the `internalZone`
        property string name: 'externalCam'
        Layout.fillWidth: true
        textRole: "name"
        model: myCamList
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.extCam; i--); i}
    }
    ///////////////////////////////////////////
    Text { text: "Выход";  Layout.alignment: Qt.AlignRight }
    //property int extZone: model && model.zones.length > 1 && model.zones[1].id || 0
    property int extZone: findZone(2)
    ComboBox {
        // exit is a gate to the `externalZone`
        property string name: 'externalZone'
        textRole: "name"
        model: root.zones.get(0).children
        Layout.fillWidth: true
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.extZone; i--); i}

    }
    ///////////////////////////////////////////
    Text { text: "Камера 2";  Layout.alignment: Qt.AlignRight }
    property int intCam: model.internalCam
    ComboBox {
        // `internalCam` is watching for the `exit` to the `externalZone`
        property string name: 'internalCam'
        textRole: "name"
        model: myCamList
        Layout.fillWidth: true
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.intCam; i--); i}
    }
    ///////////////////////////////////////////
    //Text { text: "ID:";  Layout.alignment: Qt.AlignRight }
    //Text { text: model.id}
    //////////////////////// free space placeholder
    Item {
        Layout.columnSpan: 2
        Layout.fillHeight: true
    }
    ////////////////////////
    RowLayout {
        Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            Layout.fillWidth: true
            text: 0 === model.id ? "Создать" : "Обновить"
            // anchors.centerIn: parent
            onClicked: {
                var payload = {id: model.id || 0, zones: []}

                function done(msg) {
                    tree.findItem({id: msg.data.id, serviceId: msg.service})
                }

                //console.log(model.serviceId, Helpers.readForm(form, payload), JSON.stringify(payload))
                if (Helpers.readForm(form, payload)) {
                    if (payload.internalZone)
                        payload.zones.push([0, payload.internalZone, 1])
                    if (payload.externalZone)
                        payload.zones.push([0, payload.externalZone, 2])

                    delete payload.externalZone
                    delete payload.internalZone
                    console.log(model.id, model.id, JSON.stringify(payload))
                    root.newTask(model.serviceId, 'UpdateDevice', payload, done, function (){console.log('Update Z5RWeb failed')})
                } else
                    messageBox.error("Заполните форму")
            }
        }
        Button {
            Layout.fillWidth: true
            text: "Удалить"
            enabled: model.id !== 0
            onClicked: root.send(model.serviceId, 'DeleteDevice', model.id)
        }
    }
    MessageBox {id: messageBox}

    function findZone(n) {
        var i, item, mz = model && model.zones
        for (i = 0; mz && i < mz.count; i++) {
            item = mz.get(i)
            if (item.flags === n)
                return item.id
        }
        return 0
    }
}
