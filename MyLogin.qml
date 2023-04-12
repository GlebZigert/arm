// https://stackoverflow.com/questions/45168702/canonical-way-to-make-custom-tableview-from-listview-in-qt-quick
// printing: https://evileg.com/en/forum/topic/745/
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.5
import Qt.labs.settings 1.0

import "qml/forms" as Forms
import "js/utils.js" as Utils
import "js/journal.js" as Journal
import "qml/forms/helpers.js" as Helpers
import "js/crypto.js" as Crypto

Item {
    property int panePosition
    anchors.fill: parent

    Settings {
        property alias serverIp: serverIp.text
    }

    GridLayout {
        id: form
        anchors.centerIn: parent
        columns: 2
        /////////////////////////////////////////// LOGO
        Image {
            Layout.columnSpan: 2
            //clip: true
            source: "qrc:/images/s7-logo.png"
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.bottomMargin: 20
        }
        ///////////////////////////////////////////
        Text { text: "Вы:"; Layout.alignment: Qt.AlignRight}
        Text {
            property string login: currentUser && currentUser.login || '---'
            property string username: currentUser && currentUser.name || '---'
            property string surename: currentUser && currentUser.surename || ''
            text: username + ' ' + surename + ' (' + login + ')'
            Layout.alignment: Qt.AlignLeft
        }
        ///////////////////////////////////////////
        Text { text: "Сервер:"; Layout.alignment: Qt.AlignRight}
        TextField {
            id: serverIp
            property string name: 'server'
            enabled: !root.currentUser;
            Layout.fillWidth: true
            placeholderText: "IP сервера"
            validator: RegExpValidator { regExp: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d{2,5})?/ }
            color: acceptableInput ? palette.text : "red"
            //text: "192.168.1.188"
            text: "127.0.0.1"
        }
        ///////////////////////////////////////////
        Text { text: ""; visible: !!root.currentUser; Layout.alignment: Qt.AlignLeft }
        Button {
            Layout.fillWidth: true
            visible: !!root.currentUser
            text: "Завершить смену"
            onClicked: logout()
        }
        ///////////////////////////////////////////
        Text { text: "Логин:"; Layout.alignment: Qt.AlignRight}
        TextField {
            property string name: 'login'
            Layout.fillWidth: true
            focus: true
            placeholderText: "Введите логин"
            validator: RegExpValidator { regExp: /\S{2,}/ }
            color: acceptableInput ? palette.text : "red"
        //    text: "Администратор"
            text:"33333"
        //   text:"ИвановИИ"
            //text: "unit"
        }
        ///////////////////////////////////////////
        Text { text: "Пароль"; Layout.alignment: Qt.AlignRight}
        TextField {
            id: password
            property string name: 'password'
            Layout.fillWidth: true
            placeholderText: 'Введите пароль'
            echoMode: TextInput.Password
            validator: RegExpValidator { regExp: /.{4,20}/ }
            color: acceptableInput ? palette.text : "red"
        //    text: "Start7"
              text:"33333"
        //               text:"q1w2e3"
        }
        ///////////////////////////////////////////
        Text { text: ""; Layout.alignment: Qt.AlignLeft }
        Button {
            id: loginBtn
            Layout.fillWidth: true
            text: root.currentUser ? "Сменить" : "Войти"
            onClicked: root.currentUser ? change() : login()
        }
        Keys.onReturnPressed: if (loginBtn.enabled) {
            loginBtn.clicked()
            event.accepted = true
        }
    }

    // TODO: remove next line in production
    //Component.onCompleted: login()

    function logout() {
        var i,
            svc,
            msg,
            alarms,
            pending = [],
            services = root.devices.get(0).children
        for (i = 0; i < services.count; i++) {
            svc = services.get(i)
            alarms = Journal.pendingAlarms(svc.serviceId)
            //console.log("Alarms:", svc.title, JSON.stringify(alarms))
            if (alarms.length > 0)
                pending.push(svc.title)
        }
        alarms = Journal.pendingAlarms(0)
        if (alarms.length > 0)
            pending.push("Система")

        console.log("Pending:", JSON.stringify(pending))
        if (pending.length > 0) {
            msg = "Есть необработанные тревоги в следующих подсистемах:\n• "
                    + pending.join('\n• ')
                    + '\nПродолжить закрытие смены?'
            messageBox.ask(msg, doLogout)
        } else
            doLogout()
    }

    function doLogout() {
        root.newTask(0, "CompleteShift", "", function(){loginBtn.enabled = false}, failed)

    }

    function done(msg) {
        //console.log("MyLogin:", JSON.stringify(msg))
    }

    function failed(msg) {
        console.log("Сбой при выполнении команды")
    }

    function change() {
        var payload = {},
            ok = Helpers.readForm(form, payload)
        if (ok) {
            //console.log(JSON.stringify(payload))
            password.text = ''
            payload.token = Crypto.md5(root.authSalt + payload.password)
            delete payload.password
            root.userLogin = payload.login
            root.userToken = payload.token
            payload.timestamp = Date.now()
            root.newTask(0, "ChangeUser", payload, done, failed)
        }
    }

    function login() {
        var payload = {},
            ok = Helpers.readForm(form, payload)
        if (ok) {
            //console.log(JSON.stringify(payload))
            password.text = ''
            if (payload.server.indexOf(':') > 0)
                root.serverHost = payload.server
            else
                root.serverHost = payload.server + ':' + root.serverPort
            root.userLogin = payload.login
            root.userToken = Crypto.md5(root.authSalt + payload.password)
            socket.stopped = false
        }
    }
}
