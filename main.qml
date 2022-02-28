import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.5
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtWebSockets 1.0
//import QtQuick.Controls.Material 2.11
import QtGraphicalEffects 1.0

import "js/object-factory.js" as ObjectFactory
import "js/services.js" as Services
import "js/utils.js" as Utils

import "qml/forms" as Forms

ApplicationWindow {
    id: root
    property string version: "1.03"
    title: qsTr("Риф-7 (АРМ версии " + version + ")")
    y: 50
    x: 400
    width: 1366
    height: 1024
    visible: true

    //https://stackoverflow.com/questions/47175409/qml-asking-confirmation-before-closing-application
    onClosing: checkClosing(close)

    property string authSalt: "iATdT7R4JKGg1h1YeDPp:Zl6fyUw10sgh1EGxnyKQ"
    property string serverHost: ""
    property int serverPort: 2973
    property int keepAliveInterval: 10 // seconds

    property int armRole
    property var armConfig
    property string userLogin: ""
    property string userToken: ""
    property var currentUser

    property alias activePane: menu.activePane
    property var panes
    property var services
    signal getService(int id)
    signal send(int service, string action, var data)
    signal newTask(int service, string action, var data, var done, var fail)
    signal playAlarm(string name)
    signal deviceSelected(int pane, int serviceId, int deviceId)
    signal eventSelected(var event)
    signal newEvents(var events)
    signal newPassage(var event)
    signal planUpload(int id)
    signal userUpload(int id)

    onNewTask: tasks.newTask(service, action, data, done, fail)
    onPlayAlarm: if (Utils.useAlarms()) alarmPlayer.playAlarm(name)
    onActivePaneChanged: layout.currentIndex = activePane

    onEventSelected: {
        //console.log('Event selected', JSON.stringify(event))
    }

    onPanesChanged: initPanes()

    /*signal setPane(int n)
    onSetPane: {
        //layout.children[layout.currentIndex].visible = false
        layout.currentIndex = n
        //layout.children[n].visible = true
    }*/

    property ListModel devices: ListModel {
        signal updated(int serviceId, int deviceId)
        ListElement{label: "Подсистемы"; form: "service"; expanded: true; children: []}
    }
    property ListModel users: ListModel {
        signal updated(int id)
        ListElement{label: "Пользователи"; form: "user"; expanded: true; children: []; accessRules: []; devices: []}
    }
    property ListModel rules: ListModel {
        signal updated(int id)
        ListElement{label: "Режимы доступа"; form: "rule"; expanded: true; children: []}
    }
    property ListModel events: ListModel{}

    property ListModel maps: ListModel{}

    property ListModel zones: ListModel {
        signal updated(int id)
        ListElement{label: "Контролируемые зоны"; form: "zone"; expanded: true; children: []}
    }

    property ListModel algorithms: ListModel {
        signal updated(int id)
        ListElement{label: "Алгоритмы"; form: "algo"; /*serviceId: 0; deviceId: 0; targetServiceId: 0; targetDeviceId: 0;*/ expanded: true; children: []}
    }

    //property ListModel panes: ListModel {}

    /********************** V I D E O ***********************/
    property ListModel cameraList: ListModel{signal updated();signal current_update()}
    property ListModel stream_from_storage: ListModel{signal updated()}
    property ListModel camera_presets: ListModel {signal updated()}



    property ListModel current_intervals: ListModel {signal updated()}


    property ListModel another_user: ListModel {signal updated()}

    property int  telemetryId
    property string  telemetryPoint

    property string pause_play
    property string storage_live

    property int videoPane
    property int  axxon_service_id

    signal frash_URL()
    signal update_intervals(var x)
    signal event_on_camera(var x)

     signal restored(int id)

    FontAwesome {
        id: faFont
    }

    menuBar: MyToolBar {
        id: menu
        height: 50
    }

    DropShadow {
        anchors.fill: menu
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8
        samples: 16
        color: "#80000000"
        source: menu
        z: 1000
    }

    StackLayout {
      id: layout
      currentIndex: 0
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.left: parent.left
      anchors.top: menu.bottom
      /*Repeater { // repeat panes
          id: rep1
          model: panes
          //Component.onCompleted: console.log("REP-1", count)
          delegate: SplitView { // create pane split
              Component.onCompleted: console.log("INS-1", panes.count, mL.count)
              property int panePosition
              property ListModel mL: model.layout
              orientation: Qt.Horizontal
              Layout.minimumWidth: 300
              Repeater { // repeat left & right
                  model: mL
                  Component.onCompleted: console.log("REP-2", count)
                  delegate: SplitView {
                      Component.onCompleted: console.log("INS-2", model.index)
                      property int panePosition
                      property ListModel lst: model.list
                      orientation: Qt.Vertical
                      Layout.minimumHeight: 250
                      Repeater { // horizontal splitters
                          model: lst
                          delegate: Loader {
                              //anchors.fill: parent
                              source: model.component + ".qml"
                              Component.onCompleted: console.log("INS-3", model.component)
                          }
                      }

                  }
              }

          }
        }*/
    }

    Tasks {id: tasks}

    AlarmPlayer {id: alarmPlayer}

    Timer {
        repeat: true
        running: socket.active
        interval: keepAliveInterval * 1000 // wait response for 3s max
        onTriggered: socket.sendTextMessage('{"service": 0, "action": "KeepAlive", "data": null}')
    }

    WebSocket {
         id: socket
         property var stopped: true
         onStoppedChanged: if (stopped) active = false

         url: "ws://" + serverHost + "/echo" // "?login=" + userLogin + "&token=" + userToken

         onTextMessageReceived: {
             //console.log("[RECV]", message)
             var msg = JSON.parse(message)
             Services.message(msg) // regular action first
             if (msg.task) {
                 // don't call immediately, give some time for the magic to happen
                 Qt.callLater(tasks.result, msg) // personal action after
             }
             //newMessage(msg)
         }
         onStatusChanged: if (socket.status === WebSocket.Error) {
                              //console.log("Error: " + socket.errorString)
                              goOffline()
                              socket.active = false
                          } else if (socket.status === WebSocket.Open) {
                              menu.linkStatus = 'online'
                              console.log("Socket ready, sending credentials")
                              sendTextMessage('{"login": "' + userLogin + '", "token": "' + userToken + '"}')
                          } else if (socket.status === WebSocket.Closed) {
                              if (menu.linkStatus != 'offline')
                                console.log("Socket closed")
                              menu.linkStatus = 'offline'
                              socket.active = false
                          }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: if (!socket.active && !socket.stopped) socket.active = true
    }

    Component {
        id: hLayout
        SplitView {
            property int panePosition
            orientation: Qt.Horizontal
        }
    }

    Component {
        id: vLayout
        SplitView {
            property int panePosition
            orientation: Qt.Vertical
        }
    }

    Forms.MessageBox {id: messageBox}

    Component.onCompleted: {
        makePane([["MyLogin"]], 0)
        Services.init()
        activePane = 0
        root.send.connect(sendMessage)
    }

    function initPanes() {
        console.log('INIT PANES!')
        var i
        for (i = 0; i < panes.length; i++)
            makePane(panes[i].views, 1 + i)
        //layout.children[0].destroy()

        /*var panes = [
            [['MyLogin']],
            [['MyConfig']],
            [['DevicesTree'], ['MyMap', 'MyJournal']],
//            [['Test']],
            [['MyMap', 'PassageView'], ['MyJournal', 'ZonesTree']],
            [['DevicesTree'], ['MyJournal']],
        ]
        for (var i = 0; i < panes.length; i++)
            makePane(panes[i], i)
        */
        /*var panesList = [
            {
                layout: [
                  {list: [{component: "MyJournal"}, {component: "MyMap"}, {component: "PassageView"}]},
                  //{list: [{component: "MyJournal"}, {component: "MyMap"}]},
                  //{list: [{component: "DevicesTree"}, {component: "PassageView"}]},
                ]
            }
        ]
        panes.append(panesList)
        console.log('DUMP')
        Utils.dumpModel(panes)
        console.log('DUMP')
        Utils.dumpModel(panes.get(0).layout)
        console.log('DUMP')
        Utils.dumpModel(panes.get(0).layout.get(0).list)*/
    }

    function sendMessage(service, action, data) {
        //console.log("DATA:", arguments.length, data)
        var message = {service: service, action: action, data: data},
            payload = JSON.stringify(message)
        //console.log("[SEND]", payload)
        socket.sendTextMessage(payload)
        return false
    }

    /*function itemAdded(obj, source) {
        obj.Layout.minimumHeight = Qt.binding(function() { return obj.parent.height / 4 })
        viewA.addItem(obj)
    }*/

    function setMinWH(obj) {
        obj.Layout.minimumHeight = Qt.binding(function() { return obj.parent.height / 8 })
        obj.Layout.minimumWidth = Qt.binding(function() { return obj.parent.width / 8 })
    }

    function makePane(a, pos) {
        var i
        var view,
            pane = hLayout.createObject(layout)
//        pane.visible = false
        //pane.id = "pane"
        pane.panePosition = pos
        for (var j = 0; j < a.length; j++) {
            view = vLayout.createObject(pane)
            setMinWH(view)
            pane.addItem(view)
            for (i = 0; i < a[j].length; i++) {
                ObjectFactory.create(a[j][i], view, function (obj, source) {
                    setMinWH(obj)
                    //console.log("INIT:", source)
                    obj.panePosition = pos
                    view.addItem(obj)
                    //socket.newMessage.connect(obj.send)
                });
            }
        }
    }
    function resetAlarm() {
        playAlarm("")
        for (var i in services)
            if ('resetAlarm' in services[i])
                services[i].resetAlarm()
    }

    function alarma() {
//        playAlarm("alarm")
        newTask(0, "RunAlarm", "", function (){}, function(){
            messageBox.error("Операция не выполнена")
        })
    }


    function goOffline() {
        menu.linkStatus = 'offline'
    }

    function checkClosing(close) {
        if (currentUser && Utils.useAlarms()) {
            close.accepted = false
            messageBox.error("Смена не завершена")
        }
    }

    function log(str){
 //   console.log(str)
    }
}
