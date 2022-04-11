import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4

import "../forms/helpers.js" as Helpers
import "../forms" as Forms

ColumnLayout {
    id: form
    property bool asyncWait

    anchors.fill: parent

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}
    Text {
        wrapMode: Text.WordWrap
        //Layout.fillHeight: true
        Layout.fillWidth: true
        text: "Сохранение полной резервной копии текущего состояния базы данных. Максимальное число копий - 10, самые старые перезаписываются. Не используйте функцию излишне часто."
    }

    Text {
        font.bold: true
        text: 'Резервные копии:'
    }

    Repeater {
        model: root.databaseBackups
        delegate: RadioButton {
            text: model.file
        }
    }
    /*GridLayout {
        id: form
        columns: 2

        ///////////////////////////////////////////
        Text { text: "Ежедневно, в";  Layout.alignment: Qt.AlignRight }
        TextField {
            property string name: 'time'
            Layout.fillWidth: true
            placeholderText: '08:00'
            text: model && model[name] || ''
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):(([0-5\s][0-9\s])|\d)$/ }
            color: acceptableInput ? palette.text : "red"
        }
    }*/

    Item {Layout.fillHeight: true}

    RowLayout {
        Layout.fillWidth: true
        Button {
            text: "Новая копия"
            enabled: !asyncWait
            Layout.fillWidth: true
            onClicked: messageBox.ask("Создать новую резервную копию?", function () {
                asyncWait = true
                root.newTask(0, 'MakeBackup', null, backupDone, fail)
            })
        }

        Button {
            text: "Восстановить"
            enabled: !asyncWait
            Layout.fillWidth: true
            onClicked: startBackup()
        }
    }
    Forms.MessageBox {id: messageBox}

    function startBackup() {
        var node, btn
        for (var i = 0; i < form.children.length; i++) {
            console.log(i)
            node = form.children[i]
            if (node instanceof RadioButton && node.checked) {
                btn = node
                break
            }
        }
        if (btn) {
            messageBox.ask("Восстановить резервную копию " + btn.text + "?", function () {
                 // asyncWait = true
                // root.newTask(0, 'RestoreBackup', null, restoreDone, fail)
                // server will stop immediately
                root.send(0, 'RestoreBackup', btn.text)
            })
        } else {
            messageBox.error("Выберите резервную копию")
        }

    }

    function backupDone() {
        asyncWait = false
        messageBox.information("Создание резервной копии запущено")
    }

    function restoreDone() {
        asyncWait = false
    }


    function fail(txt) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }
}
