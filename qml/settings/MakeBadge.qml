
import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.0

import "../forms/helpers.js" as Helpers
import "../forms" as Forms

ColumnLayout {
    id: form
    property bool asyncWait
    property int currentField
    anchors.fill: parent

    ListModel {
        id: list
        /*Component.onCompleted: append([
            {text: 'Фамилия'},
            {text: 'Имя'},
            {text: 'Отчество'},
            {text: 'Звание'},
            {text: 'Организация'},
            {text: 'Должность'}
        ])*/
    }

    Text { text: model.label; font.pixelSize: 14; font.bold: true }
    Rectangle {Layout.fillWidth: true; height: 2; color: "gray"}
/*    Text {
        wrapMode: Text.WordWrap
        //Layout.fillHeight: true
        Layout.fillWidth: true
        text: "Сохранение полной резервной копии текущего состояния базы данных. Максимальное число копий - 10, самые старые перезаписываются. Не используйте функцию излишне часто."
    }*/
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
    Rectangle {
        property real k: 3.375 / 2.125
        property real w: orientation.landscape ? parent.width : parent.width / k
        property real h: !orientation.landscape ? parent.width : parent.width / k
        border.color: "#999"
        border.width: 2
        radius: 5
        Layout.alignment: Qt.AlignHCenter // Qt.AlignCenter
        Layout.preferredWidth: w
        Layout.preferredHeight: h
        GridLayout {
            columns: orientation.landscape ? 2 : 1
            anchors.margins: 10
            anchors.fill: parent
            Rectangle {
                Layout.alignment: Qt.AlignTop | Qt.AlignCenter
                border.color: "#900"
                border.width: 2
                implicitWidth: parseInt(photoWidth.text)
                implicitHeight: parseInt(photoHeight.text)
            }
            ColumnLayout {
                id: badgeColumn
                Layout.alignment: Qt.AlignTop
                Repeater {
                    model: list
                    delegate: RowLayout {
                        Label {
                            padding: 4
                            Layout.preferredWidth: badgeColumn.width / 2
                            text: model.left
                            background: Rectangle {color: model.leftColor}
                        }
                        Label {
                            padding: 4
                            Layout.fillWidth: true
                            text: model.right
                            background: Rectangle {color: model.rightColor}
                        }
                    }
                }
            }
        }
    }

    ComboBox {
        id: orientation
        property bool landscape: 0 === currentIndex
        Layout.fillWidth: true
        model: ['Горизонтальная', 'Вертикальная']
    }

    GridLayout {
        columns: 5
        Text {text: "Ширина фото"}
        TextField {
            id: photoWidth
            text: '100'
            validator: IntValidator{bottom: 50; top: 200}
            color: acceptableInput ? "black" : "red"
            Layout.preferredWidth: 70
        }
        Item{Layout.fillWidth: true}

        ///////////////////////////////////////////
        Text {text: "Отступы"}
        TextField {
            id: paddings
            text: '100'
            validator: IntValidator{bottom: 50; top: 200}
            color: acceptableInput ? "black" : "red"
            Layout.preferredWidth: 70
        }
        ///////////////////////////////////////////
        Text {text: "Высота фото"}
        TextField {
            id: photoHeight
            text: '100'
            validator: IntValidator{bottom: 50; top: 200}
            color: acceptableInput ? "black" : "red"
            Layout.preferredWidth: 70
        }
        Item{Layout.fillWidth: true}

        ///////////////////////////////////////////
        Text {text: "Интервалы"}
        TextField {
            id: spacing
            text: '100'
            validator: IntValidator{bottom: 50; top: 200}
            color: acceptableInput ? "black" : "red"
            Layout.preferredWidth: 70
        }

        ///////////////////////////////////////////
        Text {text: "Число строк"}
        ComboBox {
            id: linesNumber
            model: Array.from({length: 7}, (_, i) => i + 1)
            implicitWidth: 2 * height
            onCurrentIndexChanged: updateLines(currentIndex+1)
        }
        Item{Layout.fillWidth: true; Layout.columnSpan: 3}
    }

    Repeater {
        model: list//linesNumber.currentIndex + 1
        delegate: RowLayout {
            TextField {
                Layout.fillWidth: true
                text: model.left
                onTextChanged: list.setProperty(index, 'left', text)
                onFocusChanged: if (focus) currentField = index * 2
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: currentField / 2 === index && currentField % 2 === 0 ? "red" : "transparent"
                }
            }
            TextField {
                Layout.fillWidth: true
                text: model.right
                onTextChanged: list.setProperty(index, 'right', text)
                onFocusChanged: if (focus) currentField = index * 2 + 1
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: currentField / 2 === index && currentField % 2 === 1 ? "white" : "transparent"
                }
            }
        }
    }
    RowLayout {
        ComboBox {
            font.family: faFont.name
            popup.font.family: font.family
            model: [faFont.fa_align_center, faFont.fa_align_right, faFont.fa_align_left]
            implicitWidth: 2 * height
        }
        Button {
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_paint_roller
            onClicked: colorDialog.open()
        }
        Button {
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_pen
            onClicked: colorDialog.open()
        }
        ComboBox {
            model: Array.from({length: 15}, (_, i) => i + 6)
            implicitWidth: 2 * height
        }
    }
    /******************************************************************************************************/
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

    ColorDialog {
        // TODO: check modality
        id: colorDialog
        title: "Выберите цвет"
        modality: Qt.ApplicationModal
        onAccepted: {
            console.log("You chose: " + colorDialog.color)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    function updateLines(count) {
        var tail = list.count - count
        console.log(count, tail)
        if (tail > 0) {
            list.remove(count, tail)
            return
        }

        for (; tail < 0; tail++) {
            list.append({
                left: "frst", right: "lst",
                leftColor: "red", rightColor: "green"
            })
        }
    }


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
