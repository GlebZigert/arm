import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers
import "../../js/utils.js" as Utils
import "../../js/journal.js" as Journal

GridLayout {
    id: form
    property int userId
    columns: 2
    //anchors.fill: parent
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 5

    /*Text {
        anchors.margins: 10
        text: "Фильтр событий"
        font.pixelSize: 18
        font.bold: true
        Layout.columnSpan: 2
    }*/

    ///////////////////////////////////////////
    Text { text: "Подсистема:";  Layout.alignment: Qt.AlignRight }

    RowLayout {
        Layout.fillWidth: true
        ComboBox {
            id: typeCombo
            implicitWidth: 200
            property string name: 'serviceId'
            property int fieldValue: -1
            textRole: "label"
            model: root.devices.get(0).children
            Layout.fillWidth: true
            onCurrentIndexChanged: fieldValue = currentIndex < 0 ? -1 : model.get(currentIndex).scopeId
        }
        Button {
            id: button
            width: height
            font.family: faFont.name
            text: faFont.fa_times
            font.pixelSize: 18
            ToolTip.text: "Очистить"
            ToolTip.visible: hovered
            onClicked: typeCombo.currentIndex = -1
            implicitWidth: height
        }
    }
    ///////////////////////////////////////////
    Text { text: "Пользователь";  Layout.alignment: Qt.AlignRight }
    TextField {
        id: sourceDevice
        readOnly: true
        onPressed: userSelector.display(userId, selected)
        function selected(item) {
            //root.log("Selected user:", item.name, item.id)
            if (item && item.id) {
                userId = item.id
                text = item.label
            } else {
                userId = 0
                text = ''
            }
        }
    }
    ///////////////////////////////////////////
    Text { text: "События";  Layout.alignment: Qt.AlignRight }
    GridLayout {
        //id: eventClass
        property int fieldValue: 63
        property string name: 'class'
        columns: 1
        Layout.fillWidth: true
        CheckBox {text: "Информация"; checked: true; onCheckedChanged: parent.setBit(1, checked)}
        CheckBox {text: "Норма"; checked: true; onCheckedChanged: parent.setBit(2, checked)}
        CheckBox {text: "Неисправность"; checked: true; onCheckedChanged: parent.setBit(3, checked)}
        CheckBox {text: "Потеря связи"; checked: true; onCheckedChanged: parent.setBit(4, checked)}
        CheckBox {text: "Тревога"; checked: true; onCheckedChanged: parent.setBit(5, checked)}
        CheckBox {text: "Прочее"; checked: true; onCheckedChanged: parent.setBit(0, checked)}
        function setBit(bit, checked) {
            if (checked)
                fieldValue |= 1 << bit
            else
                fieldValue ^= 1 << bit
        }

    }
    ///////////////////////////////////////////
    Text { text: "Начало:";  Layout.alignment: Qt.AlignRight }
    RowLayout {
        Layout.fillWidth: true
        TextField {
            property string name: 'startTime'
            implicitWidth: 60
            placeholderText: "00:00"
            text: placeholderText
            validator: RegExpValidator { regExp: /^[012]?\d:\d\d$/ }
            color: acceptableInput ? palette.text : "red"
        }
        Datepicker {
            property string name: 'startDate'
            //Layout.fillWidth: true
        }
    }
    ///////////////////////////////////////////
    Text { text: "Окончание:";  Layout.alignment: Qt.AlignRight }
    RowLayout {
        Layout.fillWidth: true
        TextField {
            property string name: 'endTime'
            implicitWidth: 60
            placeholderText: "23:59"
            text: placeholderText
            validator: RegExpValidator { regExp: /^[012]?\d:\d\d$/ }
            color: acceptableInput ? palette.text : "red"
        }
        Datepicker {
            property string name: 'endDate'
        }
    }
    ///////////////////////////////////////////
    Text { text: "Число строк:";  Layout.alignment: Qt.AlignRight }
    ComboBox {
        property string name: 'limit'
        property int fieldValue: model[currentIndex]
        //textRole: "label"
        currentIndex: 0
        model: [100, 200, 500, 1000]
        Layout.fillWidth: true
        onCurrentIndexChanged: fieldValue = model[currentIndex]
    }


    RowLayout {
        Layout.columnSpan: 2
        Layout.fillWidth: true
        //Layout.preferredHeight: 30

        Button {
            Layout.fillWidth: true
            text: "Применить"
            // anchors.centerIn: parent
            onClicked: parent.display()

        }
        Button {
            Layout.fillWidth: true
            text: "Печать"
            onClicked: parent.printLog()
        }
        function printLog() {
            var url,
                key, query = [],
                payload = {}
            if (!Helpers.readForm(form, payload))
                return

            payload.userId = userId
            payload.start = makeDate(payload.startDate, payload.startTime + ':00')
            payload.end = makeDate(payload.endDate, payload.endTime + ':59')
            'startDate endDate startTime endTime'.split(' ').forEach(function (v) {delete payload[v]})
            root.log("EventFilter PRINT", JSON.stringify(payload))
            for (key in payload)
                query.push(key + "=" + encodeURIComponent(payload[key]))

            url = "http://" + serverHost + "/0/journal?" + query.join('&')
            //root.log("URL:", url)
            Qt.openUrlExternally(url);
        }

        function display () {
            var payload = {}
            if (Helpers.readForm(form, payload)) {
                payload.userId = userId
                payload.start = makeDate(payload.startDate, payload.startTime + ':00')
                payload.end = makeDate(payload.endDate, payload.endTime + ':59')
                'startDate endDate startTime endTime'.split(' ').forEach(function (v) {delete payload[v]})
                root.log("EventFilter SHOW", JSON.stringify(payload))
                root.newTask('configuration', 'ListEvents', payload, done, function (){root.log('ListEvents failed')})
            }
        }


        function done(msg) {
            var i, d
            //root.log(JSON.stringify(msg))
            if (!msg.data) {
                eventsList.clear()
                return
            }

            Journal.complementEvents(msg.data)
            /*for (i = 0; i < msg.data.length; i++) {
                d = new Date(msg.data[i].time * 1e3)
                msg.data[i].timeString = Utils.formatDate(d) + ' ' + Utils.formatFullTime(d)
                msg.data[i].text = msg.data[i].event + ': ' + msg.data[i].text
                msg.data[i].color = Utils.statesColors[msg.data[i]['class']] || ''
            }*/
            eventsList.clear()
            eventsList.append(msg.data)
        }

        function makeDate(date, time) {
            var d = date.split('.')
            d.reverse()
            return (new Date(d.join('-') + 'T' + time)).toISOString()
        }
    }
    UserSelector {
        id: userSelector
        userTree: root.users
    }
    /*Popup {
        property var callback
        id: userSelector
        x: (parent.width - width) / 2
        width: 300
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        onClosed: if (callback) callback(null)

        MyTree {
            id: userTree
            model: root.users
            anchors.fill: parent
            clip: true
        }
        Component.onCompleted: {
            userTree.selected.connect(function (item) {
                if (item && item.isGroup)
                    return
                if (callback)
                    callback(item)
                callback = null
                close()
            })
        }

        function display(userId, cb) {
            userTree.findItem(userId)
            callback = cb
            open()
        }
    }*/
}
