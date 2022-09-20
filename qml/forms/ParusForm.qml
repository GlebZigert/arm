import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import "helpers.js" as Helpers

ColumnLayout {
    property bool embedded: !!model.children
    property bool asyncWait
    anchors.fill: parent

    Text { text: embedded ? 'Добавить устройство' : 'Устройство ' + model.name; font.pixelSize: 14; font.bold: true}
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}

    GridLayout {
        id: devForm
        columns: 2
        Layout.fillWidth: true

        ///////////////////////////////////////////
        Text { text: "Название"; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: "name"
            placeholderText: "Название"
            Layout.fillWidth: true
            validator: RegExpValidator { regExp: /^\S+$/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.name : ''
        }
        ///////////////////////////////////////////
        Text { text: "IP-адрес"; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: "ip"
            placeholderText: "IP-адрес"
            Layout.fillWidth: true
            validator: RegExpValidator { regExp: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.ip : ''
        }
        ///////////////////////////////////////////
        Text { text: "Логин"; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: "login"
            placeholderText: "Логин"
            Layout.fillWidth: true
            validator: RegExpValidator { regExp: /\S{2,20}/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.login : ''
        }
        ///////////////////////////////////////////
        Text { text: "Пароль"; Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: "newPassword"
            placeholderText: "Пароль"
            Layout.fillWidth: true
            echoMode: TextInput.Password
            validator: RegExpValidator { regExp: /.{4,20}/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.newPassword : ''
        }
        ///////////////////////////////////////////
        Button {
            Layout.columnSpan: 2
            visible: embedded
            enabled: !asyncWait
            Layout.fillWidth: true
            font.family: faFont.name
            text: faFont.fa_plus
            font.pixelSize: 18
            onClicked: saveDev()
            ToolTip.visible: hovered
            ToolTip.text: "Добавить устройство"
        }
    }
    Item {
        visible: !embedded
        Layout.fillHeight: true
    }
    RowLayout {
        visible: !embedded
        Button {
            text: "Сохранить"
            enabled: !asyncWait
            Layout.fillWidth: true
            onClicked: saveDev()
        }
        Button {
            text: "Удалить"
            enabled: !asyncWait
            Layout.fillWidth: true
            onClicked: deleteDev()
        }
    }

    function deleteDev() {
        root.send(model.serviceId, "DeleteDevice", model.id)
    }

    function saveDev() {
        var payload = {id: embedded ? 0 : model.id}
        if (Helpers.readForm(devForm, payload)) {
            //console.log("UPD parus:", itemId, JSON.stringify(payload))
            asyncWait = true
            root.newTask(model.serviceId, 'UpdateDevice', payload, done, fail)
        } else
            messageBox.error("Заполните форму")
    }

    function done(msg) {
        asyncWait = false
        tree.findItem({id: msg.data.id, serviceId: msg.service})
    }

    function fail(txt) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }
}
