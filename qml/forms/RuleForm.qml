import QtQuick 2.0
import QtQuick.Layouts 1.5
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.1
import "helpers.js" as Helpers

ColumnLayout {
    property int id: model['id'] || 0 // TODO: delete it
    property bool changeable: adminMode && armConfig[activeComponent] > 0
    property bool asyncWait
    anchors.fill: parent
    spacing: 5

    RowLayout {
        Layout.fillWidth: true
        Repeater {
            model: ['Режим', 'График'/*, 'Дополнительно'*/]
            delegate: Button {
                Layout.fillWidth: true
                text: modelData
                palette {
                    button: index === stack.currentIndex ? "transparent" : undefined
                }
                onClicked: stack.currentIndex = index
            }
        }
    }

    StackLayout {
        id: stack
        currentIndex: 0
        Layout.fillHeight: true

        RuleFormPage1 {id: form1} // rule data
        RuleFormPage2 {id: form2} // rule days & time
    }
    //////////////////////////////////////////////////////////////////////
    ////////////////////// A C T I O N   B U T T O N S ///////////////////
    //////////////////////////////////////////////////////////////////////
    RowLayout {
        spacing: 5
        Layout.fillWidth: true

        Button {
            text: itemId ? "Обновить" : "Создать"
            Layout.fillWidth: true
            enabled: changeable && !asyncWait
            onClicked: saveMode()
        }
        Button {
            visible: itemId
            text: "Удалить"
            enabled: changeable && !asyncWait
            //Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            onClicked: messageBox.ask("Удалить режим?", function () {
                asyncWait = true
                root.newTask('configuration', 'DeleteRule', itemId, done, fail)
            })
        }
    }

    MessageBox {id: messageBox}

    function fail(errText) {
        asyncWait = false
        messageBox.error("Операция не выполнена: " + errText)
    }

    function done(msg) {
        asyncWait = false
        if (0 === itemId)
            tree.findItem(msg.data.id)
    }

    function saveMode() {
        /*var regDays = unwrapTree(form2.tree.model.get(0).children, []),
            specDays = unwrapTree(form2.tree.model.get(1).children, [])*/

        var payload = {priority: 110, timeRanges: []}, // default "normal priority"
            ok = Helpers.readForm(form1, payload)
        if (!ok)
            return

        Helpers.readForm(form2, payload)
        payload.startDate = dateString(parseDate(payload.startDate))
        payload.endDate = dateString(parseDate(payload.endDate))
        payload.id = itemId

        //payload.rules.regularDays = reModel(form2.model.get(0).children, [])
        //payload.rules.specialDays = reModel(form2.model.get(1).children, [])
        payload.timeRanges = payload.timeRanges.concat(getRanges(timeRanges.get(0).children, 0)) // spec days
        payload.timeRanges = payload.timeRanges.concat(getRanges(timeRanges.get(1).children, 2)) // week day
        payload.timeRanges = payload.timeRanges.concat(getRanges(timeRanges.get(2).children, 1)) // month's day
        //root.send('configuration', 'UpdateRule', payload)
        asyncWait = true
        root.newTask('configuration', 'UpdateRule', payload, done, fail)
        //console.log("RULES==>", JSON.stringify(payload))

    }

    function parseDate(str) {
        var a = str.split('.')
        return new Date(a[2], a[1]-1, a[0])
    }

    // @type = 0: spec date, 1: day of month, 2: weekday, 3: day number from the beginning of rule
    function getRanges(model, type) {
        var i, j,
            date,
            r, ranges,
            list = [];

        for (i = 0; i < model.count; i++) {
            ranges = model.get(i).children
            date = model.get(i).date
            if (date) { // it's a special date
                date = parseDate(date)
            } else // it's a day in a month or a weekday
                date = new Date(1970, type-1, i+1)

            for (j = 0; j < ranges.count; j++) {
                r = ranges.get(j)
                list.push({
                    from: addTime(date, r.timeStart),
                    to: addTime(date, r.timeEnd),
                    direction: r.direction})
            }

            // TODO: days = {}, days[date] = list ?
            /*if (date)
                days.push({date: date, timeRanges: list})
            else
                days.push({dayNumber: i + 1, timeRanges: list})
            */
        }
        return list
    }

    // timestamp + "02:10" = timestamp + 2 * 60 + 10
    function addTime(date, str) {
        var d = new Date()
        d.setTime(date.getTime() + 6e4 * str.split(':').reduce(function(acc, v) {return acc * 60 + 1 * v}, 0))
        return dateString(d)
    }

    function dateString(d) {
        return (new Date(d.getTime() - d.getTimezoneOffset() * 60 * 1000)).toISOString()
    }

    /*
    function reModel(model, a) {
        var i, k,
            src, dst;

        for (i = 0; i < model.count; i++) {
            src = model.get(i)
            dst = {}
            for (k in src)
                if ('children' === k)
                    dst.children = reModel(src.children, [])
                else if ('label' !== k && 'tid' !== k && 'icon' !== k)
                    dst[k] = src[k]
            if ('children' in dst && Object.keys(dst).length === 1)
                a.push(dst.children)
            else
                a.push(dst)
        }
        return a
    }*/


    function unwrapTree(items, data) {
        var i, j,
            tmp,
            item,
            keys = ['index', 'date', 'timeStart', 'timeEnd', 'direction']

        for (i = 0; i < items.count; i++) {
            item = items.get(i)
            tmp = {}
            data.push(tmp)
            for (j = 0; j < keys.length; j++)
                if (keys[j] in item)
                    tmp[keys[j]] = item[keys[j]]
            if (item.children) {
                tmp.children = []
                unwrapTree(item.children, tmp.children)
            }
        }
        return data
    }

}
