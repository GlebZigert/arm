import QtQuick 2.0

Timer {
    interval: 200 // failed tasks scan interval
    repeat: true
    running: true

    property int timeout: 3000 // wait response for 3s max

    property int nextId: 1
    property var tasks: ({})
    property int total: 0

    signal finished(int taskId)
    signal result(var reply, bool isErr)
    signal newTask(int service, string action, var data, var done, var fail)

    onFinished: {
        var task = tasks[taskId]
        if (!task)
            return

        task.waiting = false
        let dur = Date.now() - task.time
        total += dur
        //console.log("<-> " + task.service, task.action, 'roundtrip time', dur / 1000, 'sec / of', total / 1000)
    }

    onResult: {
        var task = tasks[reply.task]
        if (!task)
            return

        if (isErr) {
            if (task.fail)
                task.fail(reply.data.errText, reply.data.errCode)
        } else if (task.done)
            task.done(reply) // use Qt.callLater(), give some time for the magic to happen

        delete tasks[reply.task]
    }

    onNewTask: {
        var payload = JSON.stringify({service: service, action: action, task: nextId, data: data}),
            len = encodeURI(payload).split(/%..|./).length - 1 // UTF-8 string length in bytes

        if (socket.active && socket.sendTextMessage(payload) === len) {
            tasks[nextId] = {done: done, fail: fail, time: Date.now(), service: service, action: action, waiting: true}
        } else if (fail)
            fail("Связь с сервером отсутствует") // fail - no connection

        nextId++
    }

    onTriggered: {
        var i,
            now = Date.now()

        for (i in tasks)
            if (tasks[i].waiting && now - tasks[i].time > timeout) {
                if (tasks[i].fail)
                    Qt.callLater(tasks[i].fail, "Истекло время ожидания ответа") // call async
                delete tasks[i]
            }
    }
}
