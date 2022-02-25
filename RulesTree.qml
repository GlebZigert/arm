import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import "qml/forms" as Forms
import "js/utils.js" as Utils

RowLayout {
    property ListModel treeModel: root.rules
    property bool adminMode: false
    property var forms: ({
        //'basic-rule': Qt.createComponent('qml/forms/BasicRuleForm.qml'),
        'rule': Qt.createComponent('qml/forms/RuleForm.qml'),
        /*'service': Qt.createComponent('qml/forms/ServiceForm.qml'),
        'newServiceForm': Qt.createComponent('qml/forms/ServiceForm.qml')*/

    })

    anchors.fill: parent
    Forms.MyTree {
        id: tree
        model: treeModel
        anchors.margins: 10
        //anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
    }
    // right panel
    Rectangle {
        visible: adminMode
        color: "lightgray"
        Layout.fillHeight: true
        //width: 400
        implicitWidth: 400
        //Layout.minimumWidth: 500
        //Layout.maximumWidth: 500
        ListModel {
            id: dummyMonth
            function seed() {
                clear()
                for (var i = 1; i <= 31; i++)
                    append({id: 1e9 + i, label: i, form: 'time', icon: 'fa_circle', children: []})
            }
        }
        ListModel {
            id: dummyWeek
            function seed() {
                var list = "Понедельник Вторник Среда Четверг Пятница Суббота Воскресенье".split(' ')
                clear()
                for (var i = 0; i < list.length; i++)
                    append({id: 2e9 + i, label: list[i], form: 'time', icon: 'fa_circle', children: []})
            }
        }
        ListModel {id: dummySpec}
        ListModel {id: timeRanges}

        Loader {
            id: loader
            anchors.fill: parent
            anchors.margins: 5
            property int itemId: model && model.id > 0 ? model.id : 0 // TODO: use onModelChanged?
            //property int priority
            property var model: ({})
            sourceComponent: model && 'form' in model ? forms[model.form] : undefined
            onModelChanged: {
                //itemId = model && model['id'] || 0
                //priority = model && model.priority || 0
                timeRanges.clear()
                dummySpec.clear()
                dummyWeek.seed()
                dummyMonth.seed()
                timeRanges.append([
                    {id: -10, label: "Специальные дни", form: "specialDays", icon: 'fa_calendar_check', expanded: true, children: model && model.specialDays || dummySpec},
                    {id: -11, label: "Дни недели", form: "", icon: 'fa_calendar_week', expanded: true, children: model && model.weekDays || dummyWeek},
                    {id: -12, label: "Числа месяца", form: "", icon: 'fa_calendar_alt', expanded: true, children: model && model.monthDays || dummyMonth},
                ])
            }
        }

    }

    Component.onCompleted: {
        //this.send.connect(Lib.onSend)
        //Lib.init({tree: tree, send: root.send, model: root.devList})
        //tree.model = root.devices
        tree.selected.connect(selected)
        treeModel.updated.connect(reloadForm)
    }

    function reloadForm(id) {
        if (loader.model && loader.model.id > 0)
            loader.model = loader.model
    }

    function selected(item) {
        // TODO: QT BUG? item <> node from model
        /*try {
            console.log(JSON.stringify(item))
        } catch (e) {
            console.log(item)
        }*/

        if (item && item.id)
            loader.model = Utils.findItem(treeModel.get(0).children, item.id)
        else
            loader.model = item
    }
}
