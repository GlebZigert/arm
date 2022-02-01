// guide1: https://martin.rpdev.net/2019/01/15/using-delegatemodel-in-qml-for-sorting-and-filtering.html
// guide2: http://imaginativethinking.ca/use-qt-quicks-delegatemodelgroup/

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import QtQml.Models 2.4
import "../../js/utils.js" as Utils

ColumnLayout {
    id: pageRoot
    spacing: 5
    property int currentRule
    property int currentZone
    property bool changeable: adminMode && armConfig[activeComponent] & 2
    property var icons: ({
        check: {text: faFont.fa_check, color: 'green'},
        times: {text: faFont.fa_times, color: 'orange'},
        walking: {text: faFont.fa_walking, color: 'green'},
        ban: {text: faFont.fa_ban, color: 'orange'}})

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        clip: true
        MyTree {
            id: zTree
            iconProvider: getZoneIcon
            model: root.zones
            anchors.fill: parent
            Component.onCompleted: selected.connect(selectZone)

            function resetIcons() {
                iconProvider = getZoneIcon
            }

            function selectZone(item) {
                currentZone = !item.children ? item.id : 0
                rTree.resetIcons()
            }
        }
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        clip: true
        MyTree {
            id: rTree
            //itemValues: ({serviceId: 1, id: 2, switchValue: 1})
            //itemValues: values
            iconProvider: getRuleIcon
            model: root.rules
            anchors.fill: parent
            Component.onCompleted: if (changeable) selected.connect(markRule)

            function resetIcons() {
                iconProvider = getRuleIcon
            }

            function markRule(item) {
                if (item.children) {
                    currentRule = 0
                    return
                }
                if (currentRule === item.id)
                    useRule()
                else
                    currentRule = item.id
            }
        }
    }

    function useRule() {
        //root.log(currentZone, currentRule)
        if (currentZone === 0 || currentRule === 0)
            return
        // 1. find rule
        if (!removeZR(currentZone, currentRule)) {
            model.zones.append({scope: 0, id: currentZone, flags: currentRule})
            root.log('ADDED')
        } else root.log('REMOVED')
        zTree.resetIcons()
    }

    function removeZR(zoneId, ruleId) { // find & remove zone-rule pair
        var i, item
        for (i = 0; i < model.zones.count; i++) {
            item = model.zones.get(i)
            if (item.id === zoneId && item.flags === ruleId) {
                model.zones.remove(i)
                return true
            }
        }
        return false
    }

    function getZoneIcon(item) {
        var icon = Utils.findItem(model.zones, item.id) ? icons.walking : icons.ban
        return item.children ? null : icon
    }
    function getRuleIcon(item) {
        var icon = Utils.findItem(model.zones, {id: currentZone, flags: item.id}) ? icons.check : icons.times
        return item.children ? null : icon
    }
}
