.import "utils.js" as Utils
.import "constants.js" as Const
.import "journal.js" as Journal

// command list for each device type, used for algorithms form
/*var commands = {
    12: {100: 'Выключить', 101: 'Включить'},
    10011: {110: 'Закрыть', 111: 'Открыть'}, // lock
    10044: {110: 'Закрыть', 111: 'Открыть'}, // ССОИ-IP lock
}*/
var commands = {
    1: [100, 101, 136, 137], // РИФ-РЛМ, Трасса
    2: [100, 101, 136, 137], // СД КЛ1
    44: [136, 137], // СД ССОИ-IP
    45: [100, 101], // ИУ ССОИ-IP
    10: [136, 137], // Точка/Гарда
    11: [100, 101, 136, 137], // СД БЛ-IP
    12: [100, 101], // ИУ БЛ-IP
    26: [136, 137], // БОД Точка-М / Гарда-М
    27: [136, 137], // Участок Точка-М / Гарда-М
    28: [136, 137], // ДД Точка-М / Гарда-М
    29: [136, 137], // БОД Сота / Сота-М
    30: [136, 137], // Участок Сота / Сота-М
    31: [136, 137], // ДД Сота / Сота-М
    99: [100, 101, 136, 137],
    7: [100, 101], // ИУ Адам-4ххх

    10011: [110, 111], // lock, custom type (1e4 + 11)
    10044: [0, 1, 21], // БЛ ССОИ-IP, custom type (1e4 + 44)
}

var commandName = {
    100: 'Выключить',
    101: 'Включить',
    110: 'Закрыть',
    111: 'Открыть',
    136: 'Снять с контроля',
    137: 'Включить контроль'
}

// ССОИ     type="3" num3="9"
// ССОИ-М   type="33" num3="9"
// ССОИ-IP  type="44" num2="9"
// all available states for each device type, used for algorithms form
var states = {
    1: [0, 1, 3, 10, 11, 12, 20, 21, 22, 100, 101, 136, 137], // РИФ-РЛМ, Трасса
    2: [0, 1, 3, 10, 11, 20, 21, 100, 101, 136, 137], // СД КЛ1
    44: [0, 1, 3, 10, 11, 20, 21, 136, 137], // СД ССОИ-IP
    45: [0, 10, 100, 101], // ИУ ССОИ-IP
    10: [0, 1, 3, 10, 11, 18, 20, 21, 23, 136, 137], // Точка/Гарда
    11: [0, 1, 3, 10, 11, 20, 100, 101, 136, 137], // СД БЛ-IP
    12: [0, 10, 100, 101, 130, 131], // ИУ БЛ-IP
    26: [0, 1, 3, 10, 11, 20, 21, 136, 137], // БОД Точка-М / Гарда-М
    27: [0, 136, 137], // Участок Точка-М / Гарда-М
    28: [0, 1, 10, 12, 13, 22, 23, 136, 137], // ДД Точка-М / Гарда-М !!!PDF.Mismatch!!!
    29: [0, 1, 3, 10, 11, 12, 20, 21, 136, 137], // БОД Сота / Сота-М
    30: [0, 136, 137], // Участок Сота / Сота-М
    31: [0, 1, 10, 12, 20, 136, 137], // ДД Сота / Сота-М
    99: [0, 1, 3, 10, 11, 12, 20, 22, 25, 100, 101, 136, 137],
    7: [0, 10, 100, 101], // ИУ Адам-4ххх

    10011: [0, 1, 3, 11, 110, 111, 112, 113, 150, 151, 2, 17], // lock, custom type (1e4 + 11)
    10044: [0, 1, 21], // БЛ ССОИ-IP, custom type (1e4 + 44)
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
    '12_28': 'Неисправность по ЧЭ1',
    '12_29': 'Неисправность ДД',
    '12_31': 'Неисправность ДД',
    12: 'Неисправность - Уход уровня',
    13: 'Неисправность по ЧЭ2',
    18: 'Неисправность ЧЭ',
    20: 'Тревога - Сработка',
    21: 'Тревога - Вскрытие',
    22: 'Тревога – Конф-ция изменена',
    '22_28': 'Тревога - Сработка по ЧЭ1',
    23: 'Тревога - Сработка по ЧЭ',
    '23_28': 'Тревога - Сработка по ЧЭ2',
    '25_99': 'Тревога – Синхр-ция изменена',
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
    this.model = model
    this.cache = {}
    this.parents = {}
    this.serviceId = this.model.serviceId

    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        Events: this.processEvents.bind(this),
    }
    Utils.setInitialStatus(this.model, this.statusUpdate.bind(this))
}

Rif.prototype.statusUpdate = function (sid) {
    //console.log("==============1 RIF-STATUS", sid, "=>", this.model.color, JSON.stringify(this.model.status))
    if (Const.EC_SERVICE_ONLINE === sid && this.model.status.tcp !== sid)
        root.send(this.serviceId, 'ListDevices', '')
    if (Const.EC_DATABASE_READY === sid && this.model.status.db !== sid)
        root.send(0, 'LoadJournal', this.serviceId)

    Utils.setServiceStatus(this.model, sid)
    //console.log("==============2 RIF-STATUS", "=>", this.model.color, JSON.stringify(this.model.status))
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
            name = stateName[state + '_' +device.type]
            if (!name)
                name = stateName[state]
            if (name)
                list[state] = name
        }

    return list
}


Rif.prototype.listCommands = function (deviceId) {
    var i,
        list = {},
        type = this.cache[deviceId] && this.cache[deviceId].type
    if (!type)
        return

    for (i = 0; i < commands[type].length; i++)
        list[commands[type][i]] = commandName[commands[type][i]]

    return list
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
    //console.log("Rif-CM", JSON.stringify(device))
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
    //console.log(this.model.type, this.model.id, 'shutdown')
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
        //console.log('Update RIF tree')
        this.update(data0)
    } else {
        this.nextGroupId = 9e15 // ~Number.MAX_SAFE_INTEGER
        //console.log("Rebuild RIF tree")
        for (i = 0; i < data0.length; i++)
            data.push(data0[i])
        data.sort(function(a, b) {
            return a.order - b.order;
        })
        //console.log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
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
                type: customType(data[i]),
                isGroup: data[i].type === 0,
                form: 'rif'
            }
            if (0 !== item.type) {
                state = data[i].states[0]
                //states[data[i].id] = state
                setState(item, {class: state['class'], event: state.id, text: state.name}, 0)
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
        this.parents = Utils.mapParents(0, model, {})
        //console.log("Rif parents map:", JSON.stringify(this.parents))

        // colorize sites
        for (i in this.cache) {
            this.siteLogic(this.cache[i])
        }

        // colorize units
        for (i in this.cache) {
            this.unitLogic(this.cache[i])
        }
    }
}

function customType(dev) {
    var custom = 1 === dev.option
             || 44 === dev.type && 9 === dev.num[1]

    return (custom ? 1e4 : 0) + dev.type
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
                this.resetUnit(dev)
            } else {
                setState(dev, events[i], 1)
            }
            // extra logic
            this.sensorLogic(dev)
            this.unitLogic(dev, Const.EC_INFO_ALARM_RESET === events[i].class)
        } else this.statusUpdate(events[i].class) // service status event
    }
    Journal.logEvents(events)

}

// check dev is sensor and run site's logic if needed
Rif.prototype.sensorLogic = function (dev) {
    if ([28, 31].indexOf(dev.type) < 0)
        return

    var parentId = this.parents[dev.id]

    if (parentId && this.cache[parentId])
        this.siteLogic(this.cache[parentId])
}

// colorize site depending on it's sensors
Rif.prototype.siteLogic = function(site) {
    if ([27, 30].indexOf(site.type) < 0)
        return

    // 1. propagate event to site respecting it's current state
    var i,
        ref, item,
        sensors = site.children

    //console.log("SITE:", JSON.stringify(parent))
    // check all sensor's state
    for (i = 0; i < sensors.count; i++) {
        item = sensors.get(i)
        if (!ref) {
            ref = item
            continue
        }

        if (!ref.stickyState && item.stickyState) {
            ref = item
        } else if (ref.stickyState && item.stickyState) {
            // compare sticky
            ref = Const.classNames[ref.mapClass] > Const.classNames[item.mapClass] ? ref : item
        } else if (!ref.stickyState && !item.stickyState) {
            // compare current
            ref = ref.stateClass > item.stateClass ? ref : item
        }
    }
    //console.log("REF:", JSON.stringify(ref))
    // clone ref to site
    var props = 'mapState mapColor mapTooltip display stateClass state color tooltip'.split(' ')
    if (ref)
        for (i in props)
            site[props[i]] = ref[props[i]]

    Utils.updateMaps(site)
}

Rif.prototype.unitLogic = function (dev) {
    if ([26, 29].indexOf(dev.type) < 0)
        return

    // TODO: 'error' too?
    if ('lost' !== Utils.className(dev.stateClass))
        return

    // 1. broadcast "lost" event to sites and sensors
    var i,
        children = Utils.makeCache(dev.children, {}),
        event = {class: dev.stateClass, event: dev.state, text: dev.tooltip}

    //console.log("CHLD:", JSON.stringify(children))

    for (i in children)
        setState(children[i], event, 1)
}

Rif.prototype.resetUnit = function (dev) {
    if ([26, 29].indexOf(dev.type) < 0)
        return

    // broadcast "reset" event to sites and sensors
    var i,
        children = Utils.makeCache(dev.children, {})

    //console.log("CHLD:", JSON.stringify(children))

    for (i in children)
        resetAlarm(children[i])
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
    //console.log('RifValidateTreeStub')
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
            color = Const.classColors[dev.stateClass]*/

    dev.mapState = className + dev.lastAction
    dev.mapColor = dev.color
    dev.mapTooltip = dev.tooltip
    dev.display = 'flash'
    dev.stickyState = false
    Utils.updateMaps(dev)
}

//////////////////////////////////////////////////////////////////////////

// priority: -1 (reset sticky), 0 (state), 1 (event)
function setState(dev, event, priority) {
    var classCode = event['class'],
        sid = event.event,
        text = event.text
    var i,
        color,
        animation = '',
        className = Utils.className(classCode),
        sticky = stickyStates.indexOf(sid) >= 0 && Utils.useAlarms();

    if (!className) return false

    //color = Const.classColors[className]
    color = Const.classColors[classCode]

    if (undefined !== dev.state && dev.state !== sid)
        animation = 'flash'; // once

    if (sticky && priority > 0)
        animation = 'blink'; // continuous

    dev.lastAction = sid >= 100 && sid <= 113 ? sid.toString() : '' // store actions: lock, unlock, on, off...

    if (priority < 0 || !dev.stickyState && dev.state !== sid) {
        // update map
        if (sticky && priority > 0)
            dev.stickyState = true

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
