import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers

GridLayout {
    id: form
    columns: 2
    anchors.fill: parent

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
        property string name: 'internalZone'
        textRole: "name"
        model: root.zones.get(0).children
        Layout.fillWidth: true
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.intZone; i--); i}
    }
    ///////////////////////////////////////////
    Text { text: "Выход";  Layout.alignment: Qt.AlignRight }
    //property int extZone: model && model.zones.length > 1 && model.zones[1].id || 0
    property int extZone: findZone(2)
    ComboBox {
        property string name: 'externalZone'
        textRole: "name"
        model: root.zones.get(0).children
        Layout.fillWidth: true
        currentIndex: {for (var i = model.count - 1; i >= 0 && model.get(i).id !== parent.extZone; i--); i}

    }
    ///////////////////////////////////////////
    Text { text: "ID:";  Layout.alignment: Qt.AlignRight }
    Text { text: model.id}
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

                //root.log(model.serviceId, Helpers.readForm(form, payload), JSON.stringify(payload))
                if (Helpers.readForm(form, payload)) {
                    if (payload.internalZone)
                        payload.zones.push([0, payload.internalZone, 1])
                    if (payload.externalZone)
                        payload.zones.push([0, payload.externalZone, 2])

                    delete payload.externalZone
                    delete payload.internalZone
                    root.log(model.id, model.id, JSON.stringify(payload))
                    root.newTask(model.serviceId, 'UpdateDevice', payload, done, function (){root.log('Update Z5RWeb failed')})
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
