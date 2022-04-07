import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import "../forms/helpers.js" as Helpers

ColumnLayout {
    anchors.fill: parent

    GridLayout {
        id: form
        columns: 2

        ///////////////////////////////////////////
        Text { text: "Время архивации";  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'time'
            Layout.fillWidth: true
            placeholderText: '08:00'
            text: model && model[name] || ''
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):(([0-5\s][0-9\s])|\d)$/ }
            color: acceptableInput ? palette.text : "red"
        }

    }
    Button {
        text: "Сохранить"
        Layout.fillWidth: true
        onClicked: save()
    }
    Item {
        Layout.fillHeight: true
    }


    function save() {
        var payload = {id: embedded ? 0 : model.id},
            ok = Helpers.readForm(devForm, payload)
        if (ok && itemId > 0) {
            console.log("UPD ping:", itemId, JSON.stringify(payload))
            root.send(model.serviceId, "UpdateDevice", payload)
        }

    }
}
