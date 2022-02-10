import QtQuick 2.0

Timer {
    interval: 200 // failed tasks scan interval
    repeat: true
    running: true

    property int timeout: 3000 // wait response for 3s max

    property int nextId: 1
    property var tasks: ({})

    signal result(var reply)
    signal newTask(int service, string action, var data, var done, var fail)

    onResult: {
        var task = tasks[reply.task]
        if (!task)
            return

        if (task.done)
            task.done(reply) // use Qt.callLater(), give some time for the magic to happen

        delete tasks[reply.task]
    }

    onNewTask: {
        var payload = JSON.stringify({service: service, action: action, task: nextId, data: data}),
            len = encodeURI(payload).split(/%..|./).length - 1 // UTF-8 string length in bytes

        if (socket.active && socket.sendTextMessage(payload) === len)
            tasks[nextId] = {done: done, fail: fail, time: Date.now()}
        else
            fail(true) // fail - no connection

        nextId++
    }

    onTriggered: {
        var i,
            now = Date.now()

        for (i in tasks)
            if (now - tasks[i].time > timeout) {
                if (tasks[i].fail)
                    tasks[i].fail(true)
                delete tasks[i]
            }
    }
}
