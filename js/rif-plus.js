.import "utils.js" as Utils
.import "constants.js" as Const
.import "journal.js" as Journal

// command list for each device type, used for algorithms form
var commands = {
    12: {100: 'Выключить', 101: 'Включить'},
    10011: {110: 'Закрыть', 111: 'Открыть'} // lock
}

// all available states for each device type, used for algorithms form
var states = {
    11: [0, 1, 3, 10, 11, 20, 100, 101, 136, 137],
    12: [0, 10, 100, 101, 130, 131],
    111: [0, 1, 3, 10, 11, 12, 20, 22, 25, 100, 101, 136, 137],
    10011: [1, 3, 11, 110, 111, 112, 113, 150, 151, 2, 17, 136, 137] // lock, custom type (1e4 + 11)
}

var stickyStates = [10, 11, 12, 13, 18, 20, 21, 22, 23, 25, 113, 143, 1143, 145]

var stateName = {
    0: 'Неопределенное состояние',
    1: 'Норма',
    3: 'Команда ДК выполнена',
    5: 'Норма по ЧЭ1',
    6: 'Норма по ЧЭ2',
    10: 'Нет связи',
    11: 'Команда ДК не выполнена',
    12: 'Неисправность по ЧЭ1',
    12: 'Неисправность ДД',
    12: 'Неисправность - Уход уровня',
    13: 'Неисправность по ЧЭ2',
    18: 'Неисправность ЧЭ',
    20: 'Тревога - Сработка',
    21: 'Тревога - Вскрытие',
    22: 'Тревога - Сработка по ЧЭ1',
    22: 'Тревога – Конф-ция изменена',
    23: 'Тревога - Сработка по ЧЭ2',
    23: 'Тревога - Сработка по ЧЭ№',
    25: 'Тревога – Синхр-ция изменена',
    25: 'Тревога - Вскрытие',
    100: 'Выключено',
    101: 'Включено',
    110: 'Закрыто',
    111: 'Открыто',
    112: 'Закрыто ключом',
    113: 'Открыто ключом',
    130: 'Послана команда «Вкл»',
    131: 'Послана команда «Выкл»',
    150: 'Послана команда «Открыть»',
    151: 'Послана команда «Закрыть»',
    2: 'Неопр-е состояние УЗ',
    17: 'Нет связи с УЗ',
    143: 'Исходящий вызов ',
    144: 'Вызов завершен по кан.связи',
    145: 'Входящий вызов',
    146: 'Вызов завершен оператором',
    136: 'Контроль выкл',
    137: 'Контроль вкл'}


var transitions = {
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

    /*143: [146, 'Завершить вызов'], // Исходящий вызов
    1143: [146, 'Завершить вызов'], // Удал. ком. исходящий вызов
    144: [143, 'Послать исходящий вызов'], // Вызов завершен по кан. связи
    146: [143, 'Послать исходящий вызов'], // Вызов завершен оператором
    1146: [143, 'Послать исходящий вызов'], // Удал. ком. Вызов завершен оператором
    'com': [143, 'Послать исходящий вызов'],*/
    'dk': [133, 'ДК']
}
var extraTr = {
    10: [133, 'Дистанционный контроль']
}
    //commandCall = [146, 'Завершить исходящий вызов'],
var actuators = [4, 43, 12] // ИУшки;
var noDK = [3, 4, 12, 43, 27, 28, 30, 31]

/*
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

var statesColors = Utils.statesColors

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
    return statesColors[sc] || statesColors.na
}*/

/*function stateType(states) {
    let id = (states instanceof Array) ? states[0].id : states.id
    return sClasses[id]
}*/

function Rif(model) {
    var status = model.status
    this.model = model
    this.model.status = {db: "", tcp: ""}
    this.cache = {}
    this.serviceId = this.model.serviceId

    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        Events: this.processEvents.bind(this),
        StatusUpdate: this.statusUpdate.bind(this),
    }
    this.statusUpdate(status)
}

Rif.prototype.listStates = function (deviceId) {
    var i,
        item,
        name, state,
        list = {},
        device = this.cache[deviceId]
    if (device && device.type in states)
        for (i = 0; i < states[device.type].length; i++) {
            state = states[device.type][i]
            //console.log(typeof state)
            name = stateName[state]
            if (name)
                list[state] = name
        }

    return list
}


Rif.prototype.listCommands = function (deviceId) {
    var device = this.cache[deviceId] || {type: 0}
    return commands[device.type]
}

Rif.prototype.reloadTree = function (id) {
    if ('online' === this.model.status.tcp)
        root.send(this.serviceId, 'ListDevices', '')
}

Rif.prototype.contextMenu = function (id) {
    var i,
        sid,
        menu = [],
        trans = [], // combined transitions
        device = this.cache[id]
    console.log("Rif-CM", JSON.stringify(device))
    if (!device) {
        menu.push({
              text: "Общий ДК",
              serviceId: this.model.serviceId,
              deviceId: 0,
              command: 133
          })
    } else if (2 === device.accessMode && !device.isGroup) {
        sid = device.state
        if (sid in transitions)
            trans.push(device.state)

        // add "control-off"
        if (136 !== sid && 1136 !== sid
            && 'lock' !== device.option
            && actuators.indexOf(device.type) < 0 // not actuator
           ) {
            trans.push(137)
        }

        if (11 === device.type && 100 !== sid)
            trans.push(101)

        if (1 === device.dk && noDK.indexOf(device.type) < 0)
            trans.push('dk')

        trans = trans.filter(function(v, i, a) {return a.indexOf(v) === i})
        for (i = 0; i < trans.length; i++)
            menu.push({
                  text: transitions[trans[i]][1],
                  serviceId: device.serviceId,
                  deviceId: device.id,
                  command: transitions[trans[i]][0]
              })
    } /*else {
        menu.push({
              text: "Сброс тревог",
              serviceId: this.model.serviceId,
              deviceId: 0,
              command: 903
          })
    }*/

    return menu
    //return [{text: "1. item one"}, {text: "2. item two"}]
}


Rif.prototype.shutdown = function () {
    console.log(this.model.type, this.model.id, 'shutdown')
}

Rif.prototype.statusUpdate = function (data) {
    console.log("==============1 STATUS", JSON.stringify(this.model.status), JSON.stringify(data))
    if (data.tcp !== this.model.status.tcp && data.tcp === "online")
        root.send(this.serviceId, 'ListDevices', '')
    if (data.db !== this.model.status.db && data.db === "online")
        root.send(0, 'LoadJournal', this.serviceId)

    this.model.status = data
    this.model.color = Utils.serviceColor(this.model.status)
    //console.log("==============2 STATUS", JSON.stringify(this.model.status), JSON.stringify(data))
}

Rif.prototype.rebuildTree = function (data0) {
    //console.log("Rif Tree:", JSON.stringify(data0))
    if (!data0)
        return
    //console.log("MODEL:", this.serviceId, JSON.stringify(this.model))
    var i,
        item,
        state,
        data = [],
        list = [], // devices
        root = list,
        path = [list],
        model = this.model.children;
    if (this.validateTree(data0)) {
        console.log('Update RIF tree')
        this.update(data0)
    } else {
        this.nextGroupId = 9e15 // ~Number.MAX_SAFE_INTEGER
        console.log("Rebuild RIF tree")
        for (i = 0; i < data0.length; i++)
            data.push(data0[i])
        data.sort(function(a, b) {
            return a.order - b.order;
        })
        //console.log("Rif Tree:", JSON.stringify(data))
        for (i = 0; i < data.length; i++) {
            //sType = getClassName(data[i].type, data[i].states[0].id)
            //console.log(data[i].id, ":", typeof data[i].id)
            item = {
                id: data[i].id, // || this.nextGroupId--,
                accessMode: data[i].accessMode,
                serviceId: this.serviceId,
                name: data[i].name,
                dk: data[i].dk,
                option: data[i].option === 1 ? 'lock' : '',
                label: data[i].name,
                icon: 'fa_circle',
                stickyState: false,

                children: [],
                num: data[i].num,
                type: (data[i].option === 1 ? 1e4 : 0) + data[i].type,
                isGroup: data[i].type === 0,
                form: 'rif'
            }
            if (0 !== item.type) {
                state = data[i].states[0]
                setState(item, state['class'], state.id, state.name, 0)
            }
            while (data[i].level > path.length - 1)
                path.push(list[list.length-1].children)
            while (data[i].level < path.length - 1)
                path.pop()
            list = path[path.length-1]
            list.push(item)
        }
        model.clear()
        model.append(root)
        this.cache = Utils.makeCache(model, {})
        //Journal.colorizeEvents(this.serviceId)
        /*for (i in this.cache) {
            //Utils.updateMaps(this.cache[i])
        }*/
        //console.log(Object.keys(this.cache))
    }
}

Rif.prototype.checkSticky = function (event) {
    return stickyStates.indexOf(event.event) >= 0
}

Rif.prototype.processEvents = function (events) {
    //console.log("RIF Events", JSON.stringify(events))
    // [{"fromState":0,"state":1004,"data":"","text":"Удал.ком. Открыть","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"},{"fromState":0,"state":111,"data":"","text":"Открыто","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"}]
    var dev,
        sType
    for (var i = 0; i < events.length; i++) {
        dev = this.cache[events[i].deviceId]
        if (dev) {
            if (Const.EC_INFO_ALARM_RESET === events[i].class) {
                resetAlarm(dev)
            } else {
                setState(dev, events[i]['class'], events[i].event, events[i].text, 1)
            }
        }
    }
    Journal.logEvents(events)

}

/*
Rif.prototype.update = function (data) {
    console.log("UPD:", JSON.stringify(data))
    var color, state, text,
        sType,
        updates = {}
    for (var i in data)
        sType = getClassName(data[i].type, data[i].states[0].id)//stateType(data[i].states)
        color = statesColors[sType] || ''
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
*/
// validate new data against existing tree
Rif.prototype.validateTree = function (data) {
    console.log('RifValidateTreeStub')
    return false
    /*var id,
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
    return ok*/
}

/*Rif.prototype.resetAlarm = function () {
    for (var id in this.cache)
        if (this.cache[id].stickyState)
            resetAlarm(this.cache[id])
}*/


// reset sticky device to actual state
function resetAlarm(dev) {
    /*var className = getClassName(dev.type, dev.state),
        color = statesColors[className]*/

    var className = Utils.className(dev.stateClass)/*,
            color = Const.statesColors[dev.stateClass]*/

    dev.mapState = className + dev.lastAction
    dev.mapColor = dev.color
    dev.mapTooltip = dev.tooltip
    dev.display = 'flash'
    dev.stickyState = false
    Utils.updateMaps(dev)
}

//////////////////////////////////////////////////////////////////////////

// priority: -1 (reset sticky), 0 (state), 1 (event)
function setState(dev, classCode, sid, text, priority) {
    var i,
        color,
        animation = '',
        className = Utils.className(classCode),
        sticky = stickyStates.indexOf(sid) >= 0 && Utils.useAlarms();

    if (!className) return false

    //color = Const.statesColors[className]
    color = Const.statesColors[classCode]

    if (undefined !== dev.state && dev.state !== sid)
        animation = 'flash'; // once

    if (sticky && priority > 0)
        animation = 'blink'; // continuous

    dev.lastAction = sid >= 100 && sid <= 113 ? sid.toString() : '' // store actions: lock, unlock, on, off...

    if (priority < 0 || !dev.stickyState && dev.state !== sid) {
        // update map
        if (sticky && priority > 0) {
            dev.stickyState = true
            //event.sticky = true
            root.playAlarm(className)
        }
        dev.mapState = className + dev.lastAction
        dev.mapColor = color
        dev.mapTooltip = text
        dev.display = animation
        Utils.updateMaps(dev)
    }
    dev.stateClass = classCode
    dev.state = sid
    dev.color = color
    dev.tooltip = text
}
