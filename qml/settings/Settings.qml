import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4

import "../forms/helpers.js" as Helpers
import "../forms" as Forms

ColumnLayout {
    id: form
    property bool asyncWait
    property var settings: ({})

    anchors.fill: parent

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}
    /*Text {
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        text: "Сохранение полной резервной копии текущего состояния базы данных. Максимальное число копий - 8, самые старые перезаписываются. Не используйте функцию излишне часто."
    }*/

    CheckBox {property string name: 'useAlarmShortcuts'; text: "Обработка тревог клавишами F9..F12"; checked: !!root.settings[name]; onCheckedChanged: settings[name] = checked}

    Item {Layout.fillHeight: true}


    Button {
        text: "Сохранить"
        enabled: !asyncWait
        Layout.fillWidth: true
        onClicked: saveSettings()
    }

    Forms.MessageBox {id: messageBox}

    function setValue(name, value) {
        settings['settings.' + name] = value
    }


    function saveSettings() {
        var s = {name: 'settings', value: JSON.stringify(settings)}
        //console.log("SET>", JSON.stringify(s))
        asyncWait = true
        root.newTask(0, 'UpdateSettings', s, done, fail)
    }


    function done() {
        asyncWait = false
    }


    function fail(txt) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }
}
