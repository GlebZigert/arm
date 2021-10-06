.import "utils.js" as Utils

var commands = {
    //  current_state: [new_state, "name"]
        100: [101, 'Включить'], // Выкл
        101: [100, 'Выключить'], // Вкл
        111: [100, 'Закрыть'], // Открыто
        113: [100, 'Закрыть'], // Открыто ключом
        110: [101, 'Открыть'], // Закрыто
        112: [101, 'Открыть'], // Закрыто ключом
        136: [137, 'Контроль вкл.'], // Контроль выкл.
        1136: [137, 'Контроль вкл.'], // Удал.ком. Контроль выкл.
        137: [136, 'Контроль выкл.'], // Контроль вкл.
        1137: [136, 'Контроль выкл.'], // Удал.ком. Контроль вкл.

        143: [146, 'Завершить вызов'], // Исходящий вызов
        1143: [146, 'Завершить вызов'], // Удал. ком. исходящий вызов
        144: [143, 'Послать исходящий вызов'], // Вызов завершен по кан. связи
        146: [143, 'Послать исходящий вызов'], // Вызов завершен оператором
        1146: [143, 'Послать исходящий вызов'], // Удал. ком. Вызов завершен оператором
//        'com': [143, 'Послать исходящий вызов'],
//        'dk': [133, 'ДК']
    }
    //commandCall = [146, 'Завершить исходящий вызов'],
var actuators = [4, 43, 12] // ИУшки;


var sClasses = { // state classes
    0: 'na',
    1: 'ok',
    2: 'na', // lock-na
    10: 'lost',
    11: 'error',
    12: 'error',
    13: 'error',
    14: 'error',
    17: 'lost', // lock-lost
    18: 'error',
    20: 'alarm',
    21: 'alarm',
    22: 'alarm',
    23: 'alarm',
    25: 'alarm',
    100: 'ok',      // Выключено
    101: 'alarm',   // Включено
    110: 'ok',      // Закрыто
    111: 'alarm',   // Открыто
    112: 'ok',      // Закрыто ключом
    113: 'alarm',   // Открыто ключом
    136: 'na',      // Контроль выкл
    1136: 'na',     // Удал.Ком. Контроль выкл
    143: 'alarm',   // Исходящий вызов
    1143: 'alarm',   // Удал. ком. Исходящий вызов
    144: 'ok',     // Вызов завершен по кан. связи
    145: 'alarm',   // Входящий вызов
    //1145: 'alarm',   // Удал. ком. Входящий вызов
    146: 'ok',       // Вызов завершён операторам
    1146: 'ok'       // Удал. ком. Вызов завершён операторам
    //130: //Послана ком. Вкл
    //131: //Послана ком. Выкл
    //137: 'na', // Контроль вкл
    //1137: 'na', // Удал.Ком. Контроль вкл
    //150: 'na', // Послана команда «Открыть» УЗ
    //151: 'na', // Послана команда «Закрыть»
}

var sClassesOverride = {
    1: {100: 'na', 101: 'na'},
    11: {100: 'na', 101: 'na'},
    99: {100: 'na', 101: 'na'}
}

var colors = {
    na: "#a5a5a5",
    ok: "#00db00",
    lost: "#ffc000",
    error: "#0f2dfb",
    alarm: "#ff0000"
}


// event class name (type)
function getClassName(devType, sid) {
    var name;
    if (devType in sClassesOverride)
        name = sClassesOverride[devType][sid]
    if (!name)
        name = sClasses[sid]

    return name || sClasses[0]; // [0] - "na" if not found
}


// cache (plain table) for quick access to the tree by id
// [id] => item{id, ...}

/*function stateColor(states) {
    let id = (states instanceof Array) ? states[0].id : states.id,
        sc = sClasses[id]
    return colors[sc] || colors.na
}*/

/*function stateType(states) {
    let id = (states instanceof Array) ? states[0].id : states.id
    return sClasses[id]
}*/

function Rif(model) {
    this.model = model
    //this.cache = makeCache(model.children, {}) // TODO: maybe just {}?
    this.cache = {}
    this.serviceId = this.model.id
    this.statusUpdate()
    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        Events: this.processEvents.bind(this),
        StatusUpdate: this.statusUpdate.bind(this),
    }
}

Rif.prototype.contextMenu = function (id) {
    var menu = [],
        device = this.cache[id]
    //console.log("CM", JSON.stringify(device))
    if (device) {
        for (var i in commands) {
            if (device.state.toString() === i)
                menu.push({
                      text: commands[i][1],
                      serviceId: device.serviceId,
                      deviceId: device.id,
                      command: commands[i][0]
                  })
        }
    } else {
        menu.push({
              text: "Сброс тревог",
              serviceId: this.model.id,
              deviceId: 0,
              command: 903
          })
    }

    return menu
    //return [{text: "1. item one"}, {text: "2. item two"}]
}

Rif.prototype.shutdown = function () {
    console.log(this.model.type, this.model.id, 'shutdown')
}

Rif.prototype.statusUpdate = function (data) {
    this.model.status = data || this.model.status
    this.model.color = Utils.serviceColor(this.model.status)
    if ('online' === this.model.status.tcp)
        root.send(this.serviceId, 'ListDevices', '')
}

Rif.prototype.rebuildTree = function (data) {
    //console.log("AAAAAAAAAAAAAAAAAA", JSON.stringify(data))
    //console.log("MODEL:", this.serviceId, JSON.stringify(this.model))
    let i,
        item,
        sType,
        list = [], // devices
        root = list,
        path = [list],
        model = this.model.children;
    if (this.validateTree(data)) {
        console.log('Update RIF tree')
        this.update(data)
    } else {
        for (i in data) {
            sType = getClassName(data[i].type, data[i].states[0].id)
            //console.log(data[i].id, ":", typeof data[i].id)
            item = {
                id: data[i].id,
                serviceId: this.serviceId,
                name: data[i].name,
                state: data[i].states[0].id,
                label: data[i].name,
                icon: 'fa_circle',
                color: colors[sType] || '',
                stateType: sType,
                display: '',
                children: [],
                num: data[i].num,
                type: data[i].type,
                form: "rif"
            }
            while (data[i].level > path.length - 1)
                path.push(list[list.length-1].children)
            while (data[i].level < path.length - 1)
                path.pop()
            list = path[path.length-1]
            list.push(item)
        }
        model.clear()
        console.log('Rebuild RIF tree')
        model.append(root)
        this.cache = makeCache(model, {})
        for (i in this.cache)
            Utils.updateMaps(this.cache[i])
        console.log(Object.keys(this.cache))
    }
}

Rif.prototype.processEvents = function (events) {
    console.log("RIF Events", JSON.stringify(events))
    // [{"fromState":0,"state":1004,"data":"","text":"Удал.ком. Открыть","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"},{"fromState":0,"state":111,"data":"","text":"Открыто","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"}]
    var item,
        name,
        sType,
        color
    for (var i = 0; i < events.length; i++) {
        item = this.cache[events[i].deviceId]
        if (item) {
            console.log(item.type, events[i].state)
            sType = getClassName(item.type, events[i].state)
            color = colors[sType] || ''
            item.state = events[i].state
            item.stateType = sType
            item.color = color
            item.display = 'flash'
            Utils.updateMaps(item)
            name = ' - ' + item.name
        } else {
            color = colors.na
            name = ''
        }
        Utils.logEvent(color, '[' + this.model.title + name + '] ' + events[i].text, events[i].time)
    }

}

//
Rif.prototype.update = function (data) {
    console.log("UPD:", JSON.stringify(data))
    var color, state, text,
        sType,
        updates = {}
    for (var i in data)
        sType = getClassName(data[i].type, data[i].states[0].id)//stateType(data[i].states)
        color = colors[sType] || ''
        state = data[i].states[0]

        // update tree
        if (i in this.cache) {
            this.cache[i].name = this.cache[i].title = data[i].name
            this.cache[i].state = state.id
            this.cache[i].stateType = sType
            this.cache[i].color = color
            this.cache[i].display = 'flash'
            Utils.updateMaps(this.cache[i])
            text = '[' + this.model.title + ' - ' + this.cache[i].name + '] ' + state.name
        } else {
            // TODO: unknown device, rebuild tree?
            text = '[' + data[i].name + '] ' + state.name
        }
        // update events

        Utils.logEvent(color, text, state.datetime * 1e3)
}

// validate new data against existing tree
Rif.prototype.validateTree = function (data) {
    console.log('validateTree')
    var id,
        ok = true
    for (var i in data) {
        id = data[i].id
        ok = id in this.cache
        if (!ok
            || this.cache[id].name !== data[i].name
            || this.cache[id].type !== data[i].type
        ) {
            ok = false
            break
        }
        if (!ok)
            break
    }
    return ok
}

function makeCache(model, cache) {
    for (var i = 0; i < model.count; i++) {
        var item = model.get(i)
        cache[item.id] = item
        if (item.children.count > 0)
            makeCache(item.children, cache)
    }
    return cache
}
