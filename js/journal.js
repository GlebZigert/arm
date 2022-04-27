.import "utils.js" as Utils
.import "constants.js" as Const
//.import "zones.js" as Zones

var oddOrEven = 0, // fluctuations for ListView(s) update
    maxJournalSize = 3e3, // max events count
    alarmNames = ["alarm", "error", "lost"]

// returns devices list with active alarms [device_id, device_id, ...] for service
function pendingAlarms(serviceId) {
    var i, ev,
        events = {},
        devices = []

    for (i = root.events.count - 1; i >= 0 ; i--) {
        ev = root.events.get(i)
        if (ev.serviceId === serviceId) {
            if (Const.EC_INFO_ALARM_RESET === ev.class || events[ev.deviceId] !== Const.EC_INFO_ALARM_RESET && ev.sticky)
                events[ev.deviceId] = ev.class
        }
    }
    //console.log("PeAl-1:", serviceId, JSON.stringify(events))
    for (i in events)
        if (Const.EC_INFO_ALARM_RESET !== events[i])
            devices.push(parseInt(i))

    return devices
}

function describeEvent(msg) {
    //console.log("DE", JSON.stringify(msg))
    var i,
        item,
        event = msg.data
    if (!event)
        return

    for (i = 0; i < root.events.count; i++) {
        item = root.events.get(i)
        if (item.id === event.id) {
            item.reason = event.reason
            item.reaction = event.reaction
            break
        }
    }
}

function isAlarm(eventClass) {
    var className = Utils.className(eventClass)
    return alarmNames.indexOf(className) >= 0
}

// -1 event is not sticky alarm or no alarms after reset
// 0 all events are described
// > 0 count of not described events
function activeAlarms(event) {
    //{"id":48113,"externalId":0,"fromState":0,"event":0,"class":202,"data":"","text":"202: Связь установлена","serviceId":49,"deviceId":1343,"userId":0,"zoneId":0,"reason":"","reaction":"","commands":"","time":1631260390,"serviceName":"Пингатор","deviceName":"ip-dev-2","userName":"","zoneName":"","timeString":"10.09.2021 10:53:10","color":"#00db00"}
    var i,
        item,
        alarmCount = -1 // no active alarms

    if (!event.sticky)
        return alarmCount // not alarm at all

    // find opened alarms for this device from the end of journal
    for (i = root.events.count - 1; i >= 0 ; i--) {
        item = root.events.get(i)
        if (item.deviceId === event.deviceId && item.serviceId === event.serviceId) {
            if (Const.EC_INFO_ALARM_RESET === item.class) {
                break
            } else if (item.sticky) {
                if (alarmCount < 0)
                    alarmCount = 0
                if ("" === item.reason.trim() || "" === item.reaction.trim())
                    alarmCount++ // not-described alarms
            }
        }
    }
    return alarmCount
}

function loadJournal(msg) {
    //console.log("JRN:", JSON.stringify(msg.data))
    if (!msg.data)
        return
    var i,
        item,
        event,
        events,
        known = {}

    console.log("LoadJournal:", msg.data.length, "events")
    if (msg.data.length > maxJournalSize) {
        msg.data = msg.data.slice(-maxJournalSize)
        console.log("... truncate to last", msg.data.length, "events")
    }

    for (i = 0; i < root.events.count; i++)
        known[root.events.get(i).id] = true

    events = complementEvents(msg.data.filter(function (v) {return !(v.id in known)}))

    if (root.events.count) {
        for (i = root.events.count - 1; i >= 0 ; i--) {
            item = root.events.get(i)
            // TODO: preserve ID order for the same time
            while (events.length > 0) {
                if (events[events.length - 1].time < item.time)
                    break
                else if (events[events.length - 1].time === item.time && events[events.length - 1].id < item.id)
                    root.events.insert(i, events.pop())
                else
                    root.events.insert(i+1, events.pop())
            }
        }
        while (events.length > 0)
            root.events.insert(0, events.pop())
    } else
        root.events.append(events)
    shrinkOldEvents()
}

function logEvents(events, silent) {
    //if (!silent)
        //console.log("EvLog:", JSON.stringify(events))
    complementEvents(events)
    root.events.append(events)
    if (!silent)
        root.newEvents(events)
    shrinkOldEvents()
}

function complementEvents(events) {
    if (!events)
        return
    var i, d,
        checkSticky

    for (i = 0; i < events.length; i++) {
        d = new Date(events[i].time * 1e3)

        if (Utils.useAlarms()) {
            if (0 === events[i].serviceId)
                checkSticky = Utils.checkSticky
            else
                checkSticky = root.services[events[i].serviceId] && root.services[events[i].serviceId].checkSticky
        }
        events[i].timeString = Utils.formatDate(d) + ' ' + Utils.formatFullTime(d)
        events[i].text = (events[i].class + '.' + events[i].event) + ': ' + events[i].text
        events[i].color = Utils.stateColor(events[i].class)
        events[i].sticky = checkSticky ? checkSticky(events[i]) : false
    }
//console.log(":", JSON.stringify(events))
    return events
}


function shrinkOldEvents() {
    oddOrEven = (oddOrEven + 1) % 2
    if (root.events.count > maxJournalSize)
        root.events.remove(0, root.events.count - maxJournalSize + oddOrEven)
}

/*
function colorizeEvents(serviceId) {
    var i, event,
        svc = root.services[serviceId]
    console.log("COLORIZE", serviceId)
    for (i = 0; i < root.events.count; i++) {
        event = root.events.get(i)
        if (event.serviceId === serviceId && '' === event.color) {

            if (svc.getEventColor)
                event.color = svc.getEventColor(event.deviceId, event.event)
        }
    }
}*/
