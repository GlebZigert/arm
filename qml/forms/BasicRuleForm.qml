import QtQuick 2.0
import QtQuick.Layouts 1.5
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers
import "../../js/utils.js" as Utils
import "../forms" as Forms

GridLayout {
    Forms.MessageBox {id: messageBox}
    id: form
    columns: 2
    anchors.fill: parent
    anchors.margins: 5
    ///////////////////////////////////////////
    /*Text { text: "Номер режима"; Layout.alignment: Qt.AlignRight}
    property int modeIndex: model && model.priority || 0
    ComboBox {
        property string name: 'priority'
        width: 150
        enabled: 0 === itemId
        currentIndex: modeIndex
        textRole: 'text'
        model: ListModel{}
        Component.onCompleted: {for (var i = 0; i < 7; i++) model.append({id: i, text: i + 1})}
    }*/

    ///////////////////////////////////////////
    Text { text: "Название";  Layout.alignment: Qt.AlignRight }
    TextField {
        property string name: 'name'
        placeholderText: 'название'
        text: model && model[name] || 'Rule Name'
        validator: RegExpValidator { regExp: /\S+.*/ }
        color: acceptableInput ? palette.text : "red"
    }
    ///////////////////////////////////////////
    Text { text: "Время действия";  Layout.alignment: Qt.AlignRight }
    Row {
        property var range: form.timeRange()
        Layout.fillWidth: true
        TextField {
            property string name: 'from'
            //inputMask: "99:99"
            text: parent.range && parent.range.from || ''
            placeholderText: "C (ЧЧ:ММ)"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):([0-5\s][0-9\s])$/ }
            color: acceptableInput ? palette.text : "red"
            width: 100
        }
        Text { text: " ... "; anchors.bottom: parent.bottom}
        TextField {
            property string name: 'to'
            //inputMask: "99:99"
            text: parent.range && parent.range.to || ''
            placeholderText: "По (ЧЧ:ММ)"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):([0-5\s][0-9\s])$/ }
            color: acceptableInput ? palette.text : "red"
            width: 100
        }
    }
    ///////////////////////////////////////////
    Text { text: "";  Layout.alignment: Qt.AlignRight }
    GridLayout {
        id: weekDays
        columns: 2
        Layout.fillWidth: true
        //property string name: 'weekDays'
        property int fieldValue: 3
        CheckBox {text: "Понедельник"; checked: form.checkDay(0)}
        CheckBox {text: "Вторник"; checked: form.checkDay(1)}
        CheckBox {text: "Среда"; checked: form.checkDay(2)}
        CheckBox {text: "Четверг"; checked: form.checkDay(3)}
        CheckBox {text: "Пятница"; checked: form.checkDay(4)}
        CheckBox {text: "Суббота"; checked: form.checkDay(5)}
        CheckBox {text: "Воскресенье"; checked: form.checkDay(6)}
    }

    RowLayout {
        Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30
        Button {
            Layout.fillWidth: true
            text: itemId ? "Обновить" : "Создать"
            // anchors.centerIn: parent
            onClicked: {
                var i,
                    payload = {id: itemId, timeRanges: []}

                if (0 === itemId && 7 <= tree.model.get(0).children.get(0).children.count) {
                    messageBox.error("Максимум 7 базовых режимов")
                    return
                }

                if (Helpers.readForm(form, payload)) {
                    //{"id":0,"priority":0,"name":"Rule Name","from":"08:00","to":"18:00","weekDays":3}
                    for (i = 0; i < weekDays.children.length; i++) {
                        if (weekDays.children[i].checked) {
                            payload.timeRanges.push({
                                from: new Date('1970-02-0' + (i+1) + 'T' + payload.from + '+0'),
                                to: new Date('1970-02-0' + (i+1) + 'T' + payload.to + '+0')
                            })
                        }
                    }
                    delete payload.from
                    delete payload.to
                    console.log("UpdRule >", JSON.stringify(payload))
                    if (payload.timeRanges.length > 0)
                        root.newTask('configuration', 'UpdateRule', payload, done, function (){console.log('UpdateRule failed')})
                    else
                        messageBox.error("Укажите дни недели")
                }

                function done(msg) {
                    if (msg.data.id > 0)
                        tree.findItem(msg.data.id)
                    else
                        messageBox.error("Правило не создано")
                }
            }
        }
        Button {
            Layout.fillWidth: true
            text: "Удалить"
            visible: itemId
            onClicked: root.send('configuration', 'DeleteRule', model.id)
        }
    }

    function checkDay(n) {
        if (model && model.weekDays && model.weekDays.count === 7)
            return model.weekDays.get(n).children.count > 0
        return false
    }

    function timeRange() {
        var i, item
        if (model && model.weekDays && model.weekDays.count === 7)
            for (i = 0; i < model.weekDays.count; i++) {
                item = model.weekDays.get(i).children
                if (item.count > 0) {
                    item = item.get(0)
                    return {from: item.timeStart, to: item.timeEnd}
                }
            }
        return null
    }

}
