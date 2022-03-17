// https://gist.github.com/pcdummy/c03845aa9449168b7d24c491ad913fce
// https://github.com/arunpkqt/QMLTreeView
// https://github.com/oKcerG/SortFilterProxyModel
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.4
import "../../js/utils.js" as Utils


Item {
    // TODO: remove top-level item?
    // TODO: // TODO: sort (use DelegateModel) https://martin.rpdev.net/2019/01/15/using-delegatemodel-in-qml-for-sorting-and-filtering.html
    //anchors.fill: parent
    id: treeRoot

    //property var itemValues
    property var iconProvider
    //    property alias lastNodeId: model.lastNodeId
    property var scopeFilter

    //!!!!!!!!!!!!!!!
    //!!! WARNING !!!
    //!!!!!!!!!!!!!!!
    // use ID to store current node, not whole object, because "model" inside delegate have type
    // "QQmlDMAbstractItemModelData", which seems non-iteratable {for (k in v) not works}
    property var selectedTNID: -1
    property var path: [0]
    property var expandedItems: []
    property alias model: columnRepeater.model
    //property colors: {'na', 'ok', 'lost', 'error'}
    signal contextMenu(var item, int x, int y)
    signal selected(var item)
    signal selectNode(var item, var tnid) // select on mouse click

    signal findItem(var keys)
    signal clearSelection()

    onClearSelection: selectedTNID = -1

    onFindItem: {
        var i,
            item,
            tnid,
            path = Utils.findPath(model, keys)

        if (path.length) {
            //console.log("PATH:", JSON.stringify(path))
            item = path.pop()
            selectedTNID = getTNID(item)
            for (i = 0; i < path.length; i++) {
                tnid = getTNID(path[i])
                if (expandedItems.indexOf(tnid) < 0)
                    expandedItems.push(tnid)
            }
            selected(item)
        } else
            selectedTNID = -1

        isExpanded = isExpanded // trigger updates
    }


    onSelectNode: {
        selectedTNID = tnid
        selected(item)
    }

    property var getTNID: function(item) {
        return item.id// || 0
    }

    property var isExpanded: function (tnid) {
        return expandedItems.indexOf(tnid) >= 0
    }

    function expand(tnid) {
        var i = expandedItems.indexOf(tnid)
        if (i < 0)
            expandedItems.push(tnid)
        else
            expandedItems.splice(i, 1)

        isExpanded = isExpanded // trigger updates
    }

    function clicked(event) {
        var parent,
            node = model.get(path[0])
        for (var i = 1; i < path.length; i++) {
            parent = node
            node = node.get(path[i])
        }

        if (event.key === Qt.Key_Up)
            console.log("up")
        if (event.key === Qt.Key_Down) {

            console.log("down")
        } if (event.key === Qt.Key_Left)
            console.log("left")
        if (event.key === Qt.Key_Right) {
            console.log("right")
            if (node.children)
                node.expanded = true
        }
        //if (node.count )
    }


    Item {
        focus: true
        Keys.onPressed: clicked(event)
    }
    ListView {
        id: columnRepeater
        //model: ListModel {}
        delegate: accordion
        //model: ListModel {}
        anchors.fill: parent
        anchors.margins: 5
        ScrollBar.vertical: ScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        //clip: true // TODO: possible performance issues
    }

    Component {
        id: accordion
        Column {
            id: column
            //property int treeNodeId: model['tnid'] || 0
            property ListModel emptyModel: ListModel{}
            property /*var*/ ListModel subnodes: model['subnodes'] || model['children'] || emptyModel
            property bool expanded: model['expanded'] || isExpanded(tnid) // TODO: first click bug on model['expanded']
            property var tnid: getTNID(model)
            //x: 15
            width: parent.width
            spacing: 0
            padding: 0
            //visible: model.childrens.count > 0 || label.indexOf("е") > 0

            RowLayout {
                id: infoRow
                width: parent.width
                spacing: 5

                Text {
                    id: carot
                    color: '#333'
                    font.pixelSize: 16
                    font.family: faFont.name
                    text: faFont.fa_angle_right
                    visible: (
                        undefined === scopeFilter
                        //|| model.scopeId === undefined
                        || scopeFilter.indexOf(model.scopeId) >= 0)
                        && subnodes && subnodes.count > 0
                    transform: Rotation {
                        origin.x: 5
                        origin.y: 8
                        angle: expanded ? 90 : 0
                        Behavior on angle { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: expand(tnid)
                        enabled: carot.visible//subnodes && subnodes.count > 0
                    }
                }
                Item { // TODO: replace this placeholder with paddings/margins?
                    width: carot.width
                    height: carot.height
                    visible: !carot.visible
                }
                /*Rectangle {
                    id: rect
                    width: 12
                    height: 12
                    radius: 6
                    visible: 'color' in model && !('icon' in model)
                    color: model.color ? model.color : '#eee'
                    //anchors.verticalCenter: parent.verticalCenter
                    Behavior on color {
                        ColorAnimation {}
                    }
                }*/

                Text {
                    property var icon: iconProvider && iconProvider(model) || undefined
                    property string iconText: 'icon' in model && faFont[model['icon']] || ''
                    property string iconColor: model.color ? model.color : '#999'
                    color: icon && icon.color || iconColor
                    font.pixelSize: 14
                    font.family: faFont.name
                    //visible: text.length
                    text: icon && icon.text || iconText
                    Behavior on color {
                        ColorAnimation {}
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: treeRoot.selectNode(model, tnid)
                    }
                }
                Label {
                    id: lbl
                    padding: 3
                    text: label
                    background: Rectangle {
                       color: /*isHighlighted(model)*/ tnid === selectedTNID ? "#ddd" : "transparent"
                    }
                    ToolTip {
                        id: toolt
                        timeout: 3e3
                        delay: 500
                        text: model.tooltip || ''
                        visible: mousearea.containsMouse && !!model.tooltip
                    }
                    MouseArea {
                        id: mousearea
                        hoverEnabled: true
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        //preventStealing: true
                        onClicked: {
                            treeRoot.selectNode(model, tnid)
                            if (Qt.RightButton === mouse.button) {
                               var p = mapToItem(null, mouse.x, mouse.y)
                               treeRoot.contextMenu(model, p.x, p.y)
                            }

                        }
                        //onHoveredChanged: toolt.visible = hovered
                    }
                }

                Item { // this is flex terminal item
                    Layout.fillWidth: true
                }
            }

            ListView {
                //id: subentryColumn
                x: 15
                clip: true // avoid mouse event intercept by hidden nodes
                width: parent.width - x
                //height: childrenRect.height * opacity
                height: opacity < 1 && childrenRect.height * opacity > 512 ? 512 : childrenRect.height * opacity
                visible: opacity > 0
                opacity: expanded ? 1 : 0
                delegate: accordion
                model: subnodes
                interactive: false
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
}

