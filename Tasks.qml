import QtQuick 2.0

Timer {
    interval: 3000 // wait response for 3s max

    property int taskId: 0
    property var doneHandler
    property var failHandler
    signal result(var data)
    signal newTask(int service, string action, var data, var done, var fail)

    onResult: {
        stop()
        if (doneHandler) {
            // don't use doneHandler(data), give some time for the magic to happen
            //Qt.callLater(doneHandler, data)
            doneHandler(data)
            doneHandler = null
        }
    }

    onNewTask: {
        var payload = JSON.stringify({service: service, action: action, task: ++taskId, data: data})
        //root.log(taskId++)
        if (running) // TODO: can't run multiple tasks in parallel
            fail(false) // not real fail, action in progress
        else if (!socket.active)
            fail(true) // fail - no connection
        else {
            doneHandler = done
            failHandler = fail
            start()
            //root.log("[SEND]", payload)
            socket.sendTextMessage(payload)
        }

    }

    onTriggered: {
        doneHandler = null
        failHandler(true) // timeout
    }
}
