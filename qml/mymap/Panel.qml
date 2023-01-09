import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import QtQuick.Dialogs 1.1

import "../../js/upload.js" as Upload
import "../forms" as Forms
import "../../js/utils.js" as Utils

Rectangle {
    property int buttonSize: 48
    property var currentDevice

    id: panel
    visible: true
    color: "lightgray"

    ListModel {
        id: iconsList
    }

    Rectangle {
        width: 1
        height: parent.height
        anchors.left: parent.left
        color: "#80808080"
    }

    ColumnLayout {
        anchors.margins: 5
        anchors.leftMargin: 7
        anchors.fill: parent
        spacing: 6

        Row {
            height: buttonSize
            Layout.fillWidth: true

            spacing: 5
            Repeater {
                model: [
                    {name: "Текст", icon: "text"},
                    {name: "Иконка", icon: "icon"},
                    {name: "Круг", icon: "circle"},
                    {name: "Прямоугольник", icon: "square"},
                    {name: "Многоугольник", icon: "polygon"},
                    {name: "Линия", icon: "polyline"},
                    {name: "Удалить", icon: "trash"},
                ]
                delegate: Button {
                    enabled: !!currentMap && !asyncWait
                    hoverEnabled: true
                    ToolTip.text: modelData.name
                    ToolTip.visible: hovered
                    width: buttonSize
                    height: buttonSize
                    onClicked: panel.btnAction(modelData.icon)

                    Image {
                        opacity: 0.5
                        anchors.margins: 5
                        anchors.fill: parent
                        source: "qrc:/images/map-toolbar/" + modelData.icon + ".svg"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            border.color: "#80808080"
            border.width: 1
            visible: !!currentItem && currentItem.type === 'icon'
            height: childrenRect.height
            Grid {
                id: innerGrid
                padding: 5
                //anchors.fill: parent
                //anchors.margins: 5
                //implicitHeight: 200
                spacing: 7
                columns: 7
                Repeater {
                    model: iconsList
                    delegate: Button {
                        hoverEnabled: true
                        ToolTip.text: model.name
                        ToolTip.visible: hovered
                        width: buttonSize
                        height: buttonSize
                        onClicked: currentItem.data = model.icon

                        Image {
                            anchors.margins: 0
                            anchors.fill: parent
                            source: "qrc:/images/devices/" + model.icon + "/ok.svg"
                        }
                    }
                }
            }
        }

        TextField {
            visible: !!currentItem && currentItem.type === 'text'
            Layout.fillWidth: true
            placeholderText: 'Введите текст'
            text: !!currentItem && currentItem.data || ''
            validator: RegExpValidator { regExp: /\S+.*/ }
            color: acceptableInput ? palette.text : "red"
            onTextChanged: if (visible) {
                currentItem.data = text || ''
                arrangeAnchors()
            }
        }

        Rectangle {
            color: "white"
            border.width: 1
            border.color: "black"
            //Layout.margins: 5
            implicitHeight: 400
            Layout.fillWidth: true
            Layout.fillHeight: true
            Forms.MyTree{
                id: tree
                model: root.devices
                anchors.fill: parent
                clip: true
                getTNID: Utils.getDeviceTNID
            }
        }
        Button {
            enabled: !asyncWait && (!currentMap || currentMap.id > 0)
            Layout.fillWidth: true
            text: "Новый план"
            onClicked: newMap("plan")
        }
        RowLayout {
            visible: !!currentMap
            Layout.fillWidth: true

            TextField {
                //Layout.preferredWidth: parent.width / 2
                id: mapName
                enabled: !asyncWait
                Layout.preferredWidth: parent.width / 2
                placeholderText: 'Название ' + (!!currentMap && currentMap.type === 'map' ? 'карты' : 'плана')
                text: !!currentMap && currentMap.name || ''
                validator: RegExpValidator { regExp: /\S+.*/ }
                color: acceptableInput ? palette.text : "red"
                onTextChanged: if (currentMap) currentMap.name = text || ''
            }
            Button {
                enabled: !asyncWait && !!currentMap && currentMap.type === 'plan'
                Layout.fillWidth: true
                text: !fileDialog.file ? "Выбрать файл" : fileDialog.file.split(/[/\/]/).pop()
                onClicked: fileDialog.open()
            }
        }

        /*RowLayout {
            Layout.fillWidth: true
            Button {
                enabled: !asyncWait && (!currentMap || currentMap.id > 0)
                Layout.preferredWidth: parent.width / 2
                text: "Новая карта"
                onClicked: newMap("map")
            }
            Button {
                enabled: !asyncWait && (!currentMap || currentMap.id > 0)
                Layout.fillWidth: true
                text: "Новый план"
                onClicked: newMap("plan")
            }
        }*/

        RowLayout {
            Layout.fillWidth: true
            Button {
                enabled: !asyncWait
                visible: !!currentMap
                Layout.preferredWidth: parent.width / 2
                //Layout.preferredWidth: parent.width / 2
                text: "Сохранить"
                onClicked: saveMap()
            }
            Button {
                enabled: !asyncWait
                visible: !!currentMap
                Layout.fillWidth: true
                text: "Удалить"
                onClicked: messageBox.ask("Удалить план / карту?", function(){Qt.callLater(deleteMap)})
            }
        }
    }

    Forms.ImageFileDialog {id: fileDialog}
    Forms.MessageBox {id: messageBox}

    Component.onCompleted: {
        root.deviceSelected.connect(deviceSelected)
        tree.selected.connect(selectDevice)
        tree.contextMenu.connect(treeContextMenu)

        var i, icons = [], names = {
                t1: '«Точка», «Гарда», ЧЭ на заграждении',
                t2: '«Точка», «Гарда», ЧЭ на АКЛ',
                t3: '«Точка-М», « Гарда-М», участок',
                t4: '«Сота», участок',
                t5: '«РИФ-РЛМ» (все варианты)',
                t6: '«Точка», «Гарда», ЧЭ ',
                t7: 'Универсальный датчик (ТСО)',
                t8: '«Разряд»',
                t9: '«Гряда» (сейсмика), участок',
                t10: 'Датчик температуры',
                t11: 'Пожарный извещатель',
                t12: 'УЗ «Монолит»',
                t13: 'Датчик вскрытия',
                t14: 'Датчик вскрытия двери',
                t15: 'IP-камера стационарная',
                t16: 'IP-камера купольная',
                t17: 'Радар',
                t18: 'Контактный датчик',
                t19: 'Блок связи',
                t20: 'ИУ световой сигнализации',
                t21: 'ИУ звуковой сигнализации',
                t22: 'ИУ системы освещения',
                //t23: '',
                //t24: '',
                t25: 'ИУ универсальное',
                t26: 'БОД «Точка-М»/«Гарда-М», «Гряда»/«Гряда-М», «Сота»',
                t27: '"Трасса"',
                t28: '«РИФ-КРЛ»',
                t29: '«РИФ-КРЛМ»',
                t30: 'Сетевое устройство',
                t31: 'Устройство Wi-Fi',
                t32: '«Страж-IP»',
                t33: 'IP-тепловизор стационарный',
                t34: 'Камера «Растр-М»'
            }
        for (i in names)
            icons.push({icon: i, name: names[i]})
        iconsList.clear()
        iconsList.append(icons)
    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    function deleteMap() {
        if (0 === currentMap.id) {
            // not saved yet map
            anchorsModel.clear()
            root.maps.remove(mapChooser.currentIndex)
            //mapChooser.currentIndex = root.maps.count - 1
        } else
            root.newTask(0, 'DeleteMap', currentMap.id, delDone, null)
    }

    function delDone() {
        /*for (var i = 0; i < root.maps.count; i++) {
            console.log(root.maps.get(i).id)
            if (0 === root.maps.get(i).id)
                root.maps.remove(i)
        }*/
    }

    function newMap(type) {
        root.maps.append({id: 0, type: type, name: "", shapes: []})
        mapChooser.currentIndex = root.maps.count - 1
        selectItem({})
    }

    function saveMap() {
        var i,
            o,
            payload = {id: currentMap.id, type: currentMap.type, name: currentMap.name, shapes: []}

        if (!mapName.acceptableInput) {
            messageBox.error("Введите название")
            return
        }

        if ('plan' === payload.type && !payload.id && !fileDialog.file) {
            messageBox.error("Необходимо выбрать файл с изображением")
            return
        }

        // TODO: normalize z-order
        for (i = 0; i < currentMap.shapes.count; i++) {
            o = currentMap.shapes.get(i)
            if ('text' === o.type && '' === o.data)
                continue // skip emty text
            payload.shapes.push({type: o.type, x: o.x, y: o.y, z: o.z, w: o.w, h: o.h, r: o.r, data: o.data, sid: o.sid, did: o.did})
        }
        //console.log("Map payload:", JSON.stringify(payload))
        asyncWait = true
        root.newTask('configuration', 'UpdateMap', payload, saveDone, saveFailed)
    }

    function saveFailed() {
        messageBox.error("Сбой во время сохранения. Попробуйте ещё раз.")
        asyncWait = false
    }

    function saveDone(msg) {
        // {"service":0,"action":"UpdateMap","task":2,"data":{"id":26,"type":"map","name":"gfhgfh","cx":0,"cy":0,"zoom":0,"shapes":[],"zoomLevel":3}}
        //console.log("Map saveDone", JSON.stringify(msg))
        var i,
            url = Utils.makeURL("plan", {id: msg.data.id})//"http://" + serverHost + "/0/plan?id=" + msg.data.id;

        if (0 === currentMap.id) // it was a new map, remove draft
            for (i = root.maps.count-1; i >= 0; i--) {
                if (currentMap === root.maps.get(i)) {
                    mapChooser.currentIndex = root.maps.count - 1
                    Qt.callLater(root.maps.remove, i)
                    break
                }
            }

        if ('map' === msg.data.type) {
            asyncWait = false
        } else if (fileDialog.file) { // upload background image
            Upload.readFile(fileDialog.file, function (arrayBuffer) {
                if (arrayBuffer)
                    Upload.postData(url, arrayBuffer, uploadDone)
                else {
                    messageBox.error("Не удаётся прочитать выбранный файл с изображением")
                    asyncWait = false
                }
            })
        } else
             asyncWait = false
    }

    function uploadDone(success) {
        if (success) {
            fileDialog.reset()
            //anticache = Math.round(Math.random() * 2e9)
        } else {
            messageBox.error("Не удаётся загрузить выбранный файл с изображением на сервер")
        }
        asyncWait = false
    }

    /*function savePosition() {
        console.log('save pos')
    }*/

    function deviceSelected(pane, serviceId, deviceId) {
        if (pane !== panePosition)
            return
        //console.log(">> SelDev >>", pane, serviceId, deviceId)
        tree.findItem({serviceId: serviceId, id: deviceId})
    }


    function selectDevice(model) {
        var m, i, shapes = currentMap && currentMap.shapes || {count: -1};

        if (currentItem && currentItem.sid === model.serviceId && currentItem.did === model.id)
            return // already selected
        //console.log(JSON.stringify(currentItem), JSON.stringify(model))

        for (i = 0; i < shapes.count; i++) {
            m = shapes.get(i)
            if (model.id === m.did && model.serviceId === m.sid) {
                //console.log("Selected shape:", model.serviceId, model.id)
                selectItem(m)
                break
            }
        }

        if (i >= shapes.count) {
            //selectItem({})
            anchorsModel.clear()
            currentItem = null
        }

        //console.log("Seeking dev:", JSON.stringify(root.devices.children))
        currentDevice = model.serviceId && model.id && Utils.findItem(
           root.devices, {serviceId: model.serviceId, id: model.id}
        ) || null
        //console.log("Selected dev:", JSON.stringify(currentDevice))
    }

    function treeContextMenu(item, x, y) {
        //console.log(x, y)
    }

    function deleteShape() {
        //console.log('deleting...')
        for (var i = 0; i < currentMap.shapes.count; i++)
            if (equal(currentItem, currentMap.shapes.get(i))) {
                selectItem({})
                currentMap.shapes.remove(i)
                break
            }
    }

    function btnAction(type) {
        if ('trash' === type)
            deleteShape()
        else
            createShape(type)
    }

    function createShape(type, force) {
        var item,
            action = currentMap.type + '.' + type,
            x = 'map' === currentMap.type ? map.center.longitude : (plan.width / 2 + plan.contentX) / currentScale,
            y = 'map' === currentMap.type ? map.center.latitude : (plan.height / 2 + plan.contentY) / currentScale,
            size = ('map' === currentMap.type ? map.width : plan.width) / currentScale / 5

        if (!force && !currentDevice) {
            messageBox.ask('Добавить элемент без привязки к устройству?', createShape.bind(this, type, true))
            return
        }

        if ('text' === type)
            size = fontSize / currentScale

        if (action in handlers) {
            item = handlers[action](x, y, size)
            seed(item, x, y, size)
            //console.log("New shape:", JSON.stringify(item))
            appendFinished = false
            currentMap.shapes.append(item)
            selectItem(currentMap.shapes.get(currentMap.shapes.count - 1))
        } else {
            //console.log('Unknown new shape action')
            //currentMap.shapes.setProperty(5, 'state', 'flash')
        }

    }

    function seed(data, x, y, size) {
        //var colors = 'red green blue orange magenta cyan'.split(' ')
        //console.log(currentDevice.name, currentDevice.color)
        data.x = x
        data.y = y
        data.r = 0
        data.w = data.h = size
        data.z = currentOrder++
        data.color = '#80808080'
        if ('map' === currentMap.type)
            x = y = 0
        // TODO: what if currentDevice was deleted after selection?
        if (currentDevice) {
            data.sid = currentDevice.serviceId || 0
            data.did = currentDevice.id || 0
            Utils.updateShape(data, currentDevice)
            /*data.color = currentDevice.color
            data.state = currentDevice.mapState
            data.display = currentDevice.display || ''*/
        }
        return data
    }

    property var handlers: {
        'map.icon': function () {
            return {type: 'icon', data: 't1'}
        },
        'plan.icon': function () {
            return {type: 'icon', data: 't1'}
        },
        'map.text': function () {
            return {type: 'text', data: currentDevice && currentDevice.name || 'текст'}
        },
        'plan.text': function () {
            return {type: 'text', data: currentDevice && currentDevice.name || 'текст'}
        },
        'map.circle': function () {
            return {type: 'ellipse', data: ''}
        },
        'plan.circle': function () {
            return {type: 'ellipse', data: ''}
        },
        'map.square': function () {
            return {type: 'rectangle', data: ''}
        },
        'plan.square': function () {
            return {type: 'rectangle',  data: ''}
        },
        'map.polygon': function (x, y, size) {
            var w2 = size / 2,
                h2 = size / 2,
                data = [(-w2) + ',' + (-h2),
                        w2 + ',' + (-h2),
                        0 + ',' + h2].join(' ')
            //console.log(data)
            return {type: 'polygon', data: data, color: 'red'}
        },
        'plan.polygon': function (x, y, size) {
            var w2 = size / 2,
                h2 = size / 2,
                data = [(x-w2) + ',' + (y-h2),
                        (x+w2) + ',' + (y-h2),
                        x + ',' + (y+h2)].join(' ')

            return {type: 'polygon', data: data, color: 'gold'}
        },
        'map.polyline': function (x, y, size) {
            var w2 = size / 2,
                h2 = size / 2,
                data = [(-w2) + ',0',
                        w2 + ',0'].join(' ')
            //console.log(data)
            return {type: 'polyline', data: data, color: 'red'}
        },
        'plan.polyline': function (x, y, size) {
            var w2 = size / 2,
                h2 = size / 2,
                data = [(x-w2) + ',' + y,
                        (x+w2) + ',' + y].join(' ')

            return {type: 'polyline', data: data, color: 'gold'}
        },
    }

    function dumpModel(m) {
        for (var i = 0; i < m.count; i++)
            console.log(i, JSON.stringify(m.get(i)))
    }

}
