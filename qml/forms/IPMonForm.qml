import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import "helpers.js" as Helpers

ColumnLayout {
    property bool embedded: !!model.children
    anchors.margins: 5
    anchors.fill: parent

    RowLayout {
        id: devForm

        Layout.fillWidth: true
        TextField {
            property string name: "ip"
            placeholderText: "IP-адрес"
            Layout.fillWidth: true
            validator: RegExpValidator { regExp: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.ip : ''
        }
        TextField {
            property string name: "name"
            placeholderText: "Название"
            Layout.fillWidth: true
            validator: RegExpValidator { regExp: /^\S+$/ }
            color: acceptableInput ? palette.text : "red"
            text: !embedded ? model.name : ''
        }
        Button {
            visible: embedded
            width: height
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_plus
            font.pixelSize: 18
            onClicked: saveDev()
        }
    }
    RowLayout {
        visible: !embedded
        Button {
            text: "Сохранить"
            Layout.fillWidth: true
            onClicked: saveDev()
        }
        Button {
            text: "Удалить"
            Layout.fillWidth: true
            onClicked: deleteDev()
        }
    }
    Item {
        visible: !embedded
        Layout.fillHeight: true
    }

    function deleteDev() {
        root.send(model.serviceId, "DeleteDevice", model.id)
    }

    function saveDev() {
        var payload = {id: embedded ? 0 : model.id},
            ok = Helpers.readForm(devForm, payload)
        if (ok && itemId > 0) {
            console.log("UPD ping:", itemId, JSON.stringify(payload))
            root.send(model.serviceId, "UpdateDevice", payload)
        }

    }
}
