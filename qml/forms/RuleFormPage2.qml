import QtQuick 2.0
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1

ColumnLayout {
    id: form2
//    Layout.fillWidth: true
//    Layout.fillHeight: true
    property int tid: 2e9
    readonly property int maxDays: 32
    //property alias tree: tree
    //property alias mdl: tree.model
    //property var ranges: timeRanges

    ///////////////////////////////////////////
    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        implicitHeight: 400
        color: "white"
        MyTree {
            id: tree
            property var current: null
            clip: true
            anchors.fill: parent
            //model: ListModel{}
            model: timeRanges

            Component.onCompleted: {
                selected.connect(function (v) {current = v; /*console.log(JSON.stringify(v))*/})
                timeRanges.countChanged.connect(function (v) {
                    if (timeRanges && 0 === timeRanges.count) {
                        tree.clearSelection();
                        tree.current = null
                    }
                })
            }
        }
    }
    /////////////////////////////////////////// SPECIAL DAYS
    RowLayout {
        visible: !!(tree.current && (tree.current.form === 'specialDays' || tree.current.date))
        Layout.fillWidth: true
        Datepicker {
            id: specDate
            upside: true
            enabled: changeable
            text: tree.current && tree.current.date || ''
        }
        Button {
            enabled: changeable
            implicitWidth: height
            font.family: faFont.name
            font.pixelSize: 18
            text: faFont.fa_check
            ToolTip.text: "Сохранить день"
            ToolTip.visible: hovered
            onClicked: updateSpecDay(specDate.text) || newSpecDay(specDate.text)
        }
        Button {
            enabled: changeable
            visible: !!(tree.current && tree.current.date)
            ToolTip.text: "Удалить день"
            ToolTip.visible: hovered
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_trash
            onClicked: deleteNode(tree.model)
        }
    }
    /////////////////////////////////////////// TIME RANGE
    RowLayout {
        visible: tree.current && (tree.current.form === 'time' || 'timeStart' in tree.current)
        Layout.fillWidth: true
        TextField {
            id: timeStart
            enabled: changeable
            //inputMask: "99:99"
            text: tree.current && tree.current.timeStart || ''
            placeholderText: "Начало (ЧЧ:ММ)"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):(([0-5\s][0-9\s])|\d)$/ }
            color: acceptableInput ? palette.text : "red"
            Layout.fillWidth: true
        }

        TextField {
            id: timeEnd
            enabled: changeable
            //inputMask: "99:99"
            text: tree.current && tree.current.timeEnd || ''
            placeholderText: "Конец (ЧЧ:ММ)"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([01\s]?[0-9\s]|2[0-3\s]):(([0-5\s][0-9\s])|\d)$/ }
            color: acceptableInput ? palette.text : "red"
            Layout.fillWidth: true
        }
        /*ComboBox {
            id: direction
            //textRole: "text"
            implicitWidth: 90
            model: ["Вход", "Выход", "Открыто"]
            currentIndex: tree.current ? (tree.current.direction || 1) - 1 : 0
        }*/

        Button {
            enabled: changeable
            implicitWidth: height
            font.family: faFont.name
            font.pixelSize: 18
            text: faFont.fa_check
            ToolTip.text: "Сохранить интервал"
            ToolTip.visible: hovered
            onClicked: checkTimerange() && (updateTimerange() || newTimerange())
        }

        Button {
            enabled: changeable
            visible: tree.current && ('timeEnd' in tree.current)
            ToolTip.text: "Удалить интервал"
            ToolTip.visible: hovered
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_trash
            onClicked: deleteNode(tree.model)
        }
        /*
        Button {
            ToolTip.text: "время на вход"
            ToolTip.visible: hovered
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_sign_in_alt
            onClicked: newTimerange(true)
        }
        Button {
            ToolTip.text: "время на выход"
            ToolTip.visible: hovered
            implicitWidth: height
            font.family: faFont.name
            text: faFont.fa_sign_out_alt
            onClicked: newTimerange(false)
        }*/
    }

    MessageDialog {
        id: popup
        title: "Ошибка"
        icon: StandardIcon.Critical
        text: "Форма заполнена неправильно."
        //onAccepted: console.log("OK")
    }

    //
    // TODO: handle overlapping time ranges
    // TODO: handle date in the past
    // TODO: handle empty reg days

    /*function directionIcons(i) {
        var a = ['fa_sign_in_alt', 'fa_sign_out_alt', 'fa_people_arrows']
        return a[i % a.length]
    }*/

    function checkTimerange() {
        var t1, t2, n1, n2
        if (!timeStart.acceptableInput || !timeEnd.acceptableInput)
            return false
        t1 = timeStart.text.split(':')
        t2 = timeEnd.text.split(':')
        if (t1.length !== 2 || t2.length !== 2)
            return
        n1 = parseInt(t1[0]) * 60 + parseInt(t1[1])
        n2 = parseInt(t2[0]) * 60 + parseInt(t2[1])
        return n1 < n2
    }

    function updateTimerange() {
        var obj = tree.current
        if (obj && obj.timeEnd) {
            obj.timeStart = timeStart.text
            obj.timeEnd = timeEnd.text
            obj.label = obj.timeStart + ' - ' + obj.timeEnd
            //obj.direction = direction.currentIndex + 1
            obj.icon = 'fa_walking' //directionIcons(direction.currentIndex)
            return true
        }
        return false
    }

    function newTimerange() {
        var icon = 'fa_walking', //directionIcons(direction.currentIndex),
            label = timeStart.text + ' - ' + timeEnd.text,
            model = tree.current ? tree.current.children : undefined

        if (model && timeStart.acceptableInput && timeEnd.acceptableInput)
            model.append({
                 label: label, id: tid++, icon: icon,
                 timeStart: timeStart.text, timeEnd: timeEnd.text,
                 //direction: direction.currentIndex + 1
            })
        else
            popup.open()
    }

    // delete tree.current node
    function deleteNode(nodes) {
        var i,
            item

        for (i = 0; i < nodes.count && tree.current !== null; i++) {
            item = nodes.get(i)
            if (item.id === tree.current.id) {
                tree.current = null
                nodes.remove(i, 1)
                return
            } else if (item.children)
                deleteNode(item.children)
        }
    }

    function updateSpecDay(date) {
        var obj = tree.current
        if (obj && obj.date) {
            obj.label = date
            obj.date = date
            return true
        }
        return false
    }

    function newSpecDay(date) {
        var model = tree.model.get(0).children
        if (model.count <= maxDays)
            model.append({label: date, id: tid++, date: date, form: 'time', icon: 'fa_circle', children: []})
    }
}
