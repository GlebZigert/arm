import QtQuick 2.13
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4
import QtMultimedia 5.11
import "qml/forms" as Forms
import "js/utils.js" as Utils

ToolBar {
   id: toolbar
   property string linkStatus: "offline"
   readonly property int buttonSize: 50
   property int activePane: 0
   property bool useAlarmShortcuts: root.settings && root.settings.useAlarmShortcuts || false

   function setAlarm(n, msg) {
       lastAlarm.text = msg
       alarmsCount.text = n < 100 ? n : '∞'
       if (0 === n)
           root.playAlarm("")
   }

   background: Rectangle {
       implicitHeight: buttonSize
       color: "#225"
    }

    RowLayout {
        id: buttons
        spacing: 0
        implicitHeight: parent.height
    }
    Text {
        id: lastAlarm
        visible: Utils.useAlarms()
        anchors.right: info.left
        anchors.verticalCenter: parent.verticalCenter
        color: "#BBFFFFFF"
        //font.bold: true
        font.pixelSize: 18
        //width: 80
        clip: true
        Behavior on text {
            id: msgBehaviour
            SequentialAnimation {
                NumberAnimation {
                    target: lastAlarm
                    properties: 'scale,opacity'
                    easing.type: Easing.InQuad
                    duration: 100
                    to: 0
                }
                PropertyAction {}
                NumberAnimation {
                    target: lastAlarm
                    properties: 'scale,opacity'
                    easing.type: Easing.OutQuad
                    duration: 100
                    to: 1
                }
            }
        }
        /*Shortcut {
            enabled: useAlarmShortcuts
            sequence: 'F9'
            autoRepeat: false
            context: Qt.ApplicationShortcut
            onActivated: alarmsList.resetLastAlarm()
        }*/

    }
    RowLayout {
        id: info
        anchors.right: parent.right
        implicitHeight: parent.height
        spacing: 0
        Item {
            visible: Utils.useAlarms()
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            Button {
                id: alarmCounterBtn
                anchors.fill: parent
                font.family: faFont.name
                text: faFont.fa_message
                font.pixelSize: 24
                onClicked: alarmsList.open()
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Активные тревоги"
                palette {
                    mid: "#338"
                    button: "transparent"
                    buttonText: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse.accepted = false
                }
                Shortcut {
                    enabled: useAlarmShortcuts
                    sequence: 'F10'
                    autoRepeat: false
                    context: Qt.ApplicationShortcut
                    onActivated: alarmCounterBtn.clicked()
                }

            }
            Text {
                id: alarmsCount
                anchors.centerIn: parent
                font.pixelSize: 15
                font.bold: true
                text: "0"
                color: "crimson"
                bottomPadding: 5
            }
        }
        Button {
            id: globalAlarmBtn
            visible: Utils.useAlarms()
            clip: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            width: buttonSize
            height: width
            font.family: faFont.name
            text: faFont.fa_bullhorn
            font.pixelSize: 24
            onClicked: messageBox.ask("Включить тревогу?", function(){Qt.callLater(root.alarma)})
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: "Тревога!"

            palette {
                mid: "#338"
                button: "transparent"
                buttonText: "white"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse.accepted = false
            }
            Shortcut {
                enabled: useAlarmShortcuts
                sequence: 'F11'
                autoRepeat: false
                context: Qt.ApplicationShortcut
                onActivated: globalAlarmBtn.clicked()
            }

        }
        Button {
            id: alarmSoundBtn
            visible: Utils.useAlarms()
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            font.family: faFont.name
            text: alarmPlayer.playbackState === MediaPlayer.PlayingState ? faFont.fa_volume_up : faFont.fa_volume_mute
            font.pixelSize: 24
            onClicked: root.playAlarm("")
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: "Сброс звука"

            palette {
                mid: "#338"
                button: "transparent"
                buttonText: "white"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse.accepted = false
            }
            Shortcut {
                enabled: useAlarmShortcuts
                sequence: 'F12'
                autoRepeat: false
                context: Qt.ApplicationShortcut
                onActivated: alarmSoundBtn.clicked()
            }
        }
        Text {
            leftPadding: 15
            rightPadding: leftPadding
            color: {
                if ('online' == linkStatus)
                    "#00e2ff"
                else if ('offline' == linkStatus)
                    'crimson'
                else
                    'orange'
            }
            font.family: faFont.name
            text: faFont.fa_wifi
            font.pixelSize: 24

            MouseArea {
                anchors.fill: parent
                pressAndHoldInterval: 10e3
                onPressAndHold: messageBox.ask("Желаете переподключиться к серверу?", root.forceReconnect)
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: 'online' != linkStatus
                alwaysRunToEnd: true
                NumberAnimation {
                    id: flashAnimation
                    loops: 3
                    from: 0.1
                    to: 1
                    duration: 250
                    //onStopped: if ('flash' === model.display) model.display = ''
                }
                PauseAnimation { duration: 1000 }
            }

        }
        Column {
            topPadding: 5
            bottomPadding: 5
            rightPadding: 5
            Text {
                id: time
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                text: "--:--"
                font.pixelSize: 16
            }
            Text {
                id: date
                color: "white"
                text: "--.--.----"
                font.pixelSize: 16
            }
            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: {
                    time.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
                    date.text = new Date().toLocaleDateString(Qt.locale(), "dd.MM.yyyy")
                }
            }
        }
    }
    /*onActivePaneChanged: {
        root.setPane(activePane)
    }*/

    Component {
        id: oneButton
        Button {
            property int bindPane: 0
            property string symbol
            text: symbol.indexOf('fa_') < 0 ? symbol : faFont[symbol]
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            palette {
                mid: "#338"
                button: hovered && !down || bindPane == toolbar.activePane ? "#22ffffff" : "transparent"
                buttonText: "white"
            }
            font.family: faFont.name
            font.pixelSize: 28
            font.bold: true
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse.accepted = false
            }

            Rectangle {
                height: 2
                //anchors.top: parent.bottom
                width: parent.width
                color: bindPane == toolbar.activePane ? "orange" : "transparent"
            }

            onClicked: toolbar.activePane = bindPane

            Shortcut {
                property int n: parseInt(symbol)
                enabled: sequence.length > 0
                autoRepeat: false
                context: Qt.ApplicationShortcut
                sequence: n > 0 && n <= 8 ? ('F'+n) : ''
                onActivated: toolbar.activePane = bindPane
            }
        }
    }

    Component.onCompleted: {
        oneButton.createObject(buttons, {symbol: 'fa_key', bindPane: 0})
        root.onPanesChanged.connect(populateToolbar)
    }

    function populateToolbar() {
        for (var i = 0; i < panes.length; i++)
            oneButton.createObject(buttons, {symbol: panes[i].symbol, bindPane: i+1})
        toolbar.activePane = 1
    }
}
