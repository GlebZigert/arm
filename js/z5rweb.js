.import "utils.js" as Utils
.import "constants.js" as Const
.import "journal.js" as Journal

const passageEvents = [16, 17, 4, 55, 54, 41, 32] // TODO: change to classes!
const stickyStates = [102, 103, 12, 13, 14, 15/*, 8, 9*/]

const   EID_DEVICE_ONLINE = 101,
        EID_DEVICE_OFFLINE = 102,
        EID_DEVICE_ERROR = 103,
        EID_EVENTS_LOADED = 104

function Z5RWeb(model) {
    this.model = model
    this.serviceId = this.model.serviceId
    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        UpdateDevice: this.update.bind(this),
        DeleteDevice: this.deleteDev.bind(this),
        Events: this.processEvents.bind(this),
    }

    Utils.setInitialStatus(model, this.statusUpdate.bind(this))
}

Z5RWeb.prototype.shutdown = function () {
    console.log(this.model.type, this.model.id, 'shutdown')
}

Z5RWeb.prototype.statusUpdate = function (sid) {
    if (Const.EC_SERVICE_READY === sid /*&& this.model.status.self !== sid*/) {
        root.send(this.serviceId, 'ListDevices', '')
        root.send(0, 'LoadJournal', this.serviceId)
    }

    Utils.setServiceStatus(this.model, sid)
}

Z5RWeb.prototype.rebuildTree = function (data) {
    //console.log("Z5RWeb tree:", JSON.stringify(data))
    var i,
        list = [],
        model = this.model.children

    if (this.validateTree()) {
        this.update(data)
    } else if (data) {
        //console.log('Z5RWeb: rebuild whole tree')
        for (i = 0; i < data.length; i++) {
            list.push(this.complement(data[i]))
        }

        //console.log("Z5RWeb list:", JSON.stringify(list))
        model.clear()
        model.append(list)
        this.cache = Utils.makeCache(model, {})
        for (i = 0; i < model.count; i++)
            Utils.updateMaps(model.get(i))
    }
}

Z5RWeb.prototype.processEvents = function (events) {
    //console.log("Z5R Events", JSON.stringify(events))
    // [{"fromState":0,"state":2,"data":"","text":"ключ не найден в банке ключей (вход), #000000929F4C","deviceId":1,"userId":0,"time":"2021-04-22T16:35:20Z"}]
    var i,
        item,
        reloadJournal

    Journal.logEvents(events)

    for (i = 0; i < events.length; i++) {
        item = this.cache && this.cache[events[i].deviceId]
        if (item) {
            //events[i].class >= 200 ? data.states[0].class : data.states[1].class
            if (Const.EC_INFO_ALARM_RESET === events[i].class) {
                resetAlarm(item)
            } else {
                setState(item, events[i], 1)
            }
            //if (passageEvents.indexOf(events[i].event) >= 0)
            if (events[i].userId > 0)
                root.userIdentified(events[i])
            if (EID_EVENTS_LOADED === events[i].event)
                reloadJournal = true
        } else this.statusUpdate(events[i].class)
    }
    if (reloadJournal)
        root.send(0, 'LoadJournal', this.serviceId)
}

Z5RWeb.prototype.update = function (dev) {
    Utils.replaceDevice(this.model.children, this.serviceId, this.complement(dev))
}

Z5RWeb.prototype.deleteDev = function (id) {
    Utils.deleteItem(this.model.children, id)
}

Z5RWeb.prototype.checkSticky = function (event) {
    return stickyStates.indexOf(event.event) >= 0
}

Z5RWeb.prototype.validateTree = function (data) {
    //console.log('Z5RWeb: validateTree stub')
    return false
}

Z5RWeb.prototype.complement = function (data) {
    data.serviceId = this.serviceId
    data.label = data.name
    data.zones = linksMap(data.zones)
    //data.state = data.state
    //data.stateType = 'na'
    data.icon = 'fa_shield_alt'
    data.form = 'z5rweb'
    data.stickyState = false
    data.state = 0

    setState(data, data.states[0].class >= 200 ? data.states[0] : data.states[1], 0)
    return data
}

Z5RWeb.prototype.reloadTree = function (id) {
    if ('online' === this.model.status.tcp)
        root.send(this.serviceId, 'ListDevices', '')
}

Z5RWeb.prototype.contextMenu = function (id) {
    var i,
        menu = [],
        serviceId = this.model.serviceId,
        device = this.cache[id]
    //console.log("z5rweb-CM", JSON.stringify(device))

    if (device && 2 === device.accessMode && 'lost' !== Utils.className(device.stateClass)) {
        menu.push({text: "Открыть вход", command: 8})
        menu.push({text: "Открыть выход", command: 9})
        if (0 !== device.mode)
            menu.push({text: "Нормальный режим", command: 370}) // 370+0
        if (1 !== device.mode)
            menu.push({text: "Заблокировать", command: 371}) // 370+1
        if (2 !== device.mode)
            menu.push({text: "Свободный проход", command: 372}) // 370+2
    }
    //console.log(JSON.stringify(menu))

    return menu.map(function (v) {
        v.serviceId = serviceId
        v.deviceId = id
        return v
    })
}

// list of all states per each device for algorithms form
/*Z5RWeb.prototype.listStates = function (deviceId) {
    return {

    }
}*/

// list of available commands per each device for algorithms form
Z5RWeb.prototype.listCommands = function (deviceId) {
    return {
            8: "Открыть вход",
            9: "Открыть выход",
            370: "Нормальный режим", // 370+0
            371: "Заблокировать", // 370+1
            372: "Свободный проход", // 370+2
    }
}

// priority: 0 - state, 1 - event
function setState(dev, event, priority) {
    //console.log("Z5R SetState", JSON.stringify(event))
    var mode,
        text,
        animation,
        sticky = stickyStates.indexOf(event.event) >= 0 && Utils.useAlarms(),
        classCode = event.class,
        sid = event.event || classCode, // TODO: check this!
        className = Utils.className(classCode),
        color = Const.classColors[className],
        modes = ['Норм. режим', 'Свободный проход', 'Блокировка', 'Неизв. режим']
        // sticky = Utils.useAlarms()
    switch (classCode) {
        case Const.EC_NORMAL_ACCESS: dev.mode = 0; break
        case Const.EC_POINT_BLOCKED: dev.mode = 1; break
        case Const.EC_FREE_PASS: dev.mode = 2; break
    }

    if (classCode >= 200) {// ignore info events
        mode = modes[dev.mode % modes.length]
        text = event.text //+ ' (' + mode + ')'

        if (undefined !== dev.state && dev.state !== sid)
            animation = 'flash'; // once

        if (sticky && priority > 0)
            animation = 'blink'; // continuous

        //console.log('Z5R check-3', dev.stickyState, dev.state, sid)
        if (priority < 0 || !dev.stickyState && dev.state !== sid) {
            //console.log('Z5R check-1')
            // update map
            if (sticky && priority > 0)
                dev.stickyState = true

            dev.mapState = className
            dev.mapColor = color
            dev.mapTooltip = text
            dev.display = animation
            Utils.updateMaps(dev)
        }
        dev.stateClass = classCode
        dev.state = sid
        dev.color = color
        dev.tooltip = text
        /*if (sticky && priority > 0 && !dev.stickyState) {
            dev.mapColor = dev.color = Const.classColors[className]
        }

        dev.mapColor = dev.color = Const.classColors[className]
        dev.tooltip = dev.mapTooltip = event.text + ' (' + mode + ')'*/
    }
}

function linksMap(arr) {
    return (arr || []).map(function (v){return {scope: v[0], id: v[1], flags: v[2]}})
}

function resetAlarm(dev) {
    var className = Utils.className(dev.stateClass)

    dev.mapState = className
    dev.mapColor = dev.color
    dev.mapTooltip = dev.tooltip
    dev.display = 'flash'
    dev.stickyState = false
    Utils.updateMaps(dev)
}
