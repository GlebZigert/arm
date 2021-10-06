.import "utils.js" as Utils
.import "constants.js" as Const
.import "journal.js" as Journal

var stickyStates = [
        Const.EC_CONNECTION_LOST
    ]

function IPMon(model) {
    var status = model.status
    model.status = {db: "", tcp: ""}

    this.model = model
    this.cache = {} // for empty tree case
    this.serviceId = this.model.serviceId
    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        UpdateDevice: this.update.bind(this),
        DeleteDevice: this.deleteDev.bind(this),
        StatusUpdate: this.statusUpdate.bind(this),
        Events: this.processEvents.bind(this),
    }
    this.statusUpdate(status)
}

IPMon.prototype.shutdown = function () {
    console.log(this.model.type, this.model.id, 'shutdown')
}

IPMon.prototype.statusUpdate = function (data) {
    //console.log("##################### Z5R SUP", JSON.stringify(data))
    if (data.tcp !== this.model.status.tcp && data.tcp === "online") {
        root.send(this.serviceId, 'ListDevices', '')
        root.send(0, 'LoadJournal', this.serviceId)
    }

    this.model.status = data
    this.model.color = Utils.serviceColor(this.model.status)
}

IPMon.prototype.reloadTree = function (id) {
    if ('online' === this.model.status.tcp)
        root.send(this.serviceId, 'ListDevices', '')
}


IPMon.prototype.rebuildTree = function (data) {
    //console.log("IPMon tree:", JSON.stringify(data))
    var i,
        list = [],
        model = this.model.children

    if (this.validateTree()) {
        this.update(data)
    } else {
        console.log('IPMon: rebuild whole tree')
        for (i = 0; i < data.length; i++) {
            list.push(this.complement(data[i]))
            setState(data[i], data[i].stateClass, data[i].stateText, 0)
        }
        model.clear()
        model.append(list)
        this.cache = Utils.makeCache(model, {})
    }
}

IPMon.prototype.checkSticky = function (event) {
    return stickyStates.indexOf(event.class) >= 0
}

IPMon.prototype.processEvents = function (events) {
    //console.log("IPMon Events", JSON.stringify(events))
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
        }
    }
}

IPMon.prototype.update = function (dev) {
    //console.log("IPMon upd.dev", JSON.stringify(dev))
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

IPMon.prototype.deleteDev = function (id) {
    Utils.deleteItem(this.model.children, id)
}


IPMon.prototype.validateTree = function (data) {
    console.log('IPMon: validateTree stub')
    return false
}

IPMon.prototype.complement = function (data) {
    data.serviceId = this.serviceId
    data.label = data.name
    data.icon = 'fa_wifi'
    data.form = 'ipmon'
    data.stickyState = false

    /*data.mapState = ''
    data.mapColor = ''
    data.mapTooltip = ''*/

    setState(data, data.stateClass, data.stateText, 0)
    return data
}

/*IPMon.prototype.contextMenu = function (id) {
    var i,
        menu = [],
        device = this.cache[id]
    console.log("IPMon-CM", JSON.stringify(device))

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

/*IPMon.prototype.resetAlarm = function () {
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
        color = Const.statesColors[className],
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
