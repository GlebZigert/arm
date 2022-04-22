import QtQuick 2.11
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
   background: Rectangle {
       implicitHeight: buttonSize
       color: "#225"
    }
    RowLayout {
        id: buttons
        spacing: 0
        implicitHeight: parent.height
    }
    RowLayout {
        id: info
        anchors.right: parent.right
        implicitHeight: parent.height
        spacing: 0
        Button {
            visible: Utils.useAlarms()
            clip: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            width: buttonSize
            height: width
            font.family: faFont.name
            text: faFont.fa_skull_crossbones
            font.pixelSize: 24
            onClicked: messageBox.ask("Включить тревогу?", function(){Qt.callLater(root.alarma)})
            hoverEnabled: true
            ToolTip {
                visible: parent.hovered
                text: "Тревога!"
            }
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
        }
        Button {
            visible: Utils.useAlarms()
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize
            font.family: faFont.name
            text: alarmPlayer.playbackState === MediaPlayer.PlayingState ? faFont.fa_volume_up : faFont.fa_volume_mute
            font.pixelSize: 24
            onClicked: root.playAlarm("")
            hoverEnabled: true
            ToolTip {
                visible: parent.hovered
                text: "Сброс звука"
            }
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

            /*ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: "Button description"*/

            onClicked: toolbar.activePane = bindPane
        }
    }

    Component.onCompleted: {
        oneButton.createObject(buttons, {symbol: 'fa_key', bindPane: 0})
        root.onPanesChanged.connect(populateToolbar)
    }

    Forms.MessageBox{}

    function populateToolbar() {
        for (var i = 0; i < panes.length; i++)
            oneButton.createObject(buttons, {symbol: panes[i].symbol, bindPane: i+1})
        toolbar.activePane = 1
    }
}
