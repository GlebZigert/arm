import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1

import "helpers.js" as Helpers
import "../../js/upload.js" as Upload
import "../../js/utils.js" as Utils

import "../forms" as Forms

ColumnLayout {
    id: column
    property bool asyncWait
    property int savedId // for passing thru callbacks

    anchors.fill: parent
    spacing: 5

    RowLayout {
        id: topButtons
        //width: parent.width
        Repeater {
            model: ['Пользователь', 'Доступ', 'Права']
            delegate: Button {
                //enabled: false
                Layout.fillWidth: true
                text: modelData
                palette {
                    button: index === stack.currentIndex ? "transparent" : undefined
                }
                onClicked: stack.currentIndex = index
            }
        }
    }

    //property int id: model['id'] || 0

    /*property var defaults: ({
        'rif': {'Host': '127.0.0.1:1974', 'KAInterval': 5, 'DBHost': '127.0.0.1:1975'}
    })*/

    StackLayout {
        id: stack
        Layout.fillHeight: true
        currentIndex: 0
        UserFormPage1 {id: form1}
        UserFormPage2 {id: form2}
        UserFormPage3 {id: form3}
    }

    ///////////////////////////////////////////
    //Text { text: "Test:";  Layout.alignment: Qt.AlignRight }
    //RadioButton { text: qsTr("Small") }
    ///////////////////////////////////////////
    /*RowLayout {
        visible: typeCombo.currentIndex > 0
        Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            text: newItem ? "Создать" : "Обновить"
            // anchors.centerIn: parent
            onClicked: {

        }
        Button {
            text: "Удалить"
            visible: id != 0
            onClicked: {
                root.send('configuration', 'DeleteUser', id)
            }
        }
    }*/
    //////////////////////////////////////////////////////////////////////
    ////////////////////// A C T I O N   B U T T O N S ///////////////////
    //////////////////////////////////////////////////////////////////////
    RowLayout {
        id: bottomButtons
        //width: parent.width
        //Layout.margins: 5
        spacing: 5
        Button {
            text: newItem ? "Создать" : "Обновить"
            Layout.fillWidth: true
            //Layout.alignment: Qt.AlignCenter
            // anchors.centerIn: parent
            onClicked: saveUser()
            enabled: !asyncWait && armConfig[activeComponent] > 0 && (!newItem || form1.changeable)

        }
        Button {
            visible: !newItem && model.id !== 1 && form1.changeable
            text: "Удалить"
            //Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            enabled: !asyncWait && form1.changeable
            onClicked: messageBox.ask('Удалить ' + (1 === model.type ? 'группу?' : 'пользователя?'), function () {
                asyncWait = true
                root.newTask(0, 'DeleteUser', itemId, null, fail)
            })

        }
    }

    Forms.MessageBox {id: messageBox}
    ImageFileDialog {id: fileDialog}

    function saveUser() {
        var name, value,
            filename,
            payload = /*newItem
            ? {parentId: itemId}
            : */ {id: itemId, parentId: model['parentId']},
            ok = Helpers.readForm(form1, payload)

        if (ok && payload.type !== 0) {
            if (!form1.changeable) {
                delete payload.cards
            }
            if (form2.changeable)
                payload.zones = Helpers.getLinks(model.zones)
            if (form3.changeable) {
                Helpers.processDevLinks(model.devices, form3.values)
                payload.devices = Helpers.getLinks(model.devices)//.reduce(function (acc, v) {if (v.flags > 0) acc.push(v); return acc}, [])
            }

            if (fileDialog.file) {
                filename = fileDialog.file
                fileDialog.reset()
            }

            //console.log("USER PAYLOAD:", filename, JSON.stringify(payload))
            asyncWait = true
            root.newTask('configuration', 'UpdateUser', payload, done.bind(this, filename), fail)
        } else
            messageBox.error("Форма заполнена не полностью, либо неправильно.")
    }

    function fail(txt) {
        //console.log('UpdateUser failed:', txt)
        asyncWait = false
        messageBox.error("Операция не выполнена: " + txt)
    }

    function done(filename, msg) {
        //console.log("User Err & Warn:", JSON.stringify(msg.data.warnings))
        if (msg.data.errors) {
            messageBox.error(msg.data.errors.join('\n'))
        } else {
            if (msg.data.warnings) {
                messageBox.warning(msg.data.warnings.join('\n'))
            }
            savedId = msg.data.id
            saveDone(filename)
        }

            //tree.findItem(msg.data.id)
        //console.log('done', JSON.stringify(msg))
    }
    function saveDone(filename) {
        console.log("UserForm upload:", filename)
        var url = Utils.makeURL("user", {id: savedId});
        if (filename) { // upload user image
            Upload.readFile(filename, function (arrayBuffer) {
                if (arrayBuffer)
                    Upload.postData(url, arrayBuffer, uploadDone)
                else {
                    messageBox.error("Не удаётся прочитать выбранный файл с изображением")
                    finish()
                }
            })
        } else
             finish()
    }

    function uploadDone(success) {
        if (success) {
            //nocache = Math.round(Math.random() * 2e9)
            fileDialog.ready = false
            //console.log("Upload done!", nocache)
        } else {
            messageBox.error("Не удаётся загрузить выбранный файл с изображением на сервер")
        }
        finish()
    }
    function finish() {
        asyncWait = false
        //
        if (newItem)
            tree.findItem(savedId)
    }
}



