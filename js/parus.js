.import "utils.js" as Utils
.import "constants.js" as Const
.import "journal.js" as Journal

var stickyStates = [
        Const.EC_LOST,
        Const.EC_UPS_UNPLUGGED
    ]

function Parus(model) {
    this.model = model
    this.cache = {} // for empty tree case
    this.serviceId = this.model.serviceId
    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        UpdateDevice: this.update.bind(this),
        DeleteDevice: this.deleteDev.bind(this),
        Events: this.processEvents.bind(this),
    }
    Utils.setInitialStatus(model, this.statusUpdate.bind(this))
}

Parus.prototype.statusUpdate = function (sid) {
    //console.log("##################### Z5R SUP", JSON.stringify(data))
    if (Const.EC_SERVICE_READY === sid && this.model.status.self !== sid) {
        root.send(this.serviceId, 'ListDevices', '')
        root.send(0, 'LoadJournal', this.serviceId)
    }

    Utils.setServiceStatus(this.model, sid)
}

Parus.prototype.shutdown = function () {
    console.log(this.model.type, this.model.id, 'shutdown')
}

Parus.prototype.reloadTree = function (id) {
    if ('online' === this.model.status.tcp)
        root.send(this.serviceId, 'ListDevices', '')
}


Parus.prototype.rebuildTree = function (data) {
    //console.log("Parus tree:", JSON.stringify(data))
    var i,
        list = [],
        model = this.model.children

    if (this.validateTree()) {
        this.update(data)
    } else {
        console.log('Parus: rebuild whole tree')
        for (i = 0; i < data.length; i++) {
            list.push(this.complement(data[i]))
            setState(data[i], data[i].stateClass, data[i].stateText, 0)
        }
        model.clear()
        model.append(list)
        this.cache = Utils.makeCache(model, {})
    }
}

Parus.prototype.checkSticky = function (event) {
    return stickyStates.indexOf(event.class) >= 0
}

Parus.prototype.processEvents = function (events) {
    //console.log("Parus Events", JSON.stringify(events))
    var i, dev
    Journal.logEvents(events)

    if (!this.cache)
        return // just created, no devices yet

    for (i = 0; i < events.length; i++) {
        dev = this.cache[events[i].deviceId]
        if (dev) {
            if (Const.EC_INFO_ALARM_RESET === events[i].class) {
                resetAlarm(dev)
            } else {
                setState(dev, events[i].class, events[i].text, 1)
            }
        } else this.statusUpdate(events[i].class)
    }
}

Parus.prototype.update = function (dev) {
    //console.log("Parus upd.dev", JSON.stringify(dev))
    var item = this.cache[dev.id],
        model = this.model.children
    if (item) { // update existing
        item.label = item.name = dev.name
        item.ip = dev.ip
    } else { // add new
        model.append(this.complement(dev))
        item = model.get(model.count - 1)
        this.cache[dev.id] = item
        setState(item, item.stateClass, item.stateText, 0)
    }
}

Parus.prototype.deleteDev = function (id) {
    Utils.deleteItem(this.model.children, id)
}


Parus.prototype.validateTree = function (data) {
    console.log('Parus: validateTree stub')
    return false
}

Parus.prototype.complement = function (data) {
    data.serviceId = this.serviceId
    data.label = data.name
    data.icon = 'fa_car_battery'
    data.form = 'parus'
    data.stickyState = false

    /*data.mapState = ''
    data.mapColor = ''
    data.mapTooltip = ''*/

    setState(data, data.stateClass, data.stateText, 0)
    return data
}

/*Parus.prototype.contextMenu = function (id) {
    var i,
        menu = [],
        device = this.cache[id]
    console.log("Parus-CM", JSON.stringify(device))

    menu.push({
          text: "Открыть вход",
          serviceId: this.model.serviceId,
          deviceId: id,
          command: 8
      })
    menu.push({
          text: "Открыть выход",
          serviceId: this.model.serviceId,
          deviceId: id,
          command: 9
      })
    return menu
}*/

/*Parus.prototype.resetAlarm = function () {
    for (var id in this.cache)
        if (this.cache[id].stickyState)
            resetAlarm(this.cache[id])
}*/


// reset sticky device to actual state
function resetAlarm(dev) {
    var className = Utils.className(dev.stateClass)

    dev.mapState = className
    dev.mapColor = dev.color
    dev.mapTooltip = dev.tooltip
    dev.display = 'flash'
    dev.stickyState = false
    Utils.updateMaps(dev)
}


// priority: -1 (reset sticky), 0 (state, e.g. initial), 1 (event)
function setState(dev, classCode, text, priority) {
    if (classCode >= 100 && classCode < 200)
        return// ignore info events
    var animation,
        className = Utils.className(classCode),
        color = Const.classColors[className],
        sticky = stickyStates.indexOf(classCode) >= 0 && Utils.useAlarms()

    // TODO: don't flash for duplicate events?
    if (dev.stateClass !== classCode && sticky && priority > 0)
        animation = 'blink' // continuous
    else
        animation = 'flash' // once

    if (0 === priority || !dev.stickyState && dev.stateClass !== classCode) {
        // update map
        if (sticky && priority > 0) {
            dev.stickyState = true
            root.playAlarm(className)
        }
        dev.mapState = className
        dev.mapColor = color
        dev.mapTooltip = text
        dev.display = animation
        Utils.updateMaps(dev)
    }
    dev.stateClass = classCode
    dev.color = color
    dev.tooltip = text
}
