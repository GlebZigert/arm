.import "utils.js" as Utils

var rules
var tid = 1e9

var handlers = {
    ListRules: function (msg) {
        var id

        if (!rules)
            rules = new Rules(root.rules.get(0).children)
        rules.updateTree(msg.data || [])
    },

    UpdateRule: function (msg) {
        //root.log(JSON.stringify(msg))
        if (rules) // check rules are used by operator
            rules.update(msg.data)
    },
    DeleteRule: function (msg) {
        //root.log("DEL:", JSON.stringify(msg))
        if (rules) // check rules are used by operator
            rules.delete(msg.data)
    }
}

//////////////////////////////////////////////////////////////

function Rules(model) {
   /* model.append([{
        id: -2, // -1 is reserved
        label: 'Базовые режимы',
        form: 'basic-rule',
        icon: 'fa_microchip',
        color: '#666',
        children: []
    }, {
        id: -3,
        label: 'Расширенные режимы',
        form: 'rule',
        icon: 'fa_database',
        color: '#666',
        children: []
    }])*/

    this.model = model
}

Rules.prototype.updateTree = function (data) {
    var i
    //root.log("Rules.updateTree", JSON.stringify(data))

    // TODO: update tree only if required
    this.model.clear()

    for (i = 0; i < data.length; i++) {
        this.model.append(newItem(data[i]))
        /*if (data[i].priority < 100)
            this.model.get(0).children.append(newItem(data[i]))
        else
            this.model.get(1).children.append(newItem(data[i]))*/

    }
}

function getRanges(list) {
    //root.log("RANGES:", JSON.stringify(list))
    var i, n,
        from, to, label,
        timeStart, timeEnd,
        days,
        monthDays = {},
        weekDays = {},
        specDays = {},
        res = {specialDays: [], weekDays: [], monthDays: []},
        //icons = ['fa_circle', 'fa_sign_in_alt', 'fa_sign_out_alt', 'fa_people_arrows'],
        dayNames = "Понедельник Вторник Среда Четверг Пятница Суббота Воскресенье".split(' ')

    if (list)
        for (i = 0; i < list.length; i++) {
            from = Utils.readDate(list[i].from)
            to = Utils.readDate(list[i].to)
            if (1970 === from.getFullYear()) {
                label = from.getDate()
                days = 0 === from.getMonth() ? monthDays : weekDays
            } else {
                // special days
                label = Utils.formatDate(from)
                days = specDays
            }
            if (!(label in days))
                days[label] = []


            timeStart = Utils.formatTime(from)
            timeEnd = Utils.formatTime(to)
            days[label].push({
                id: tid++,
                label: timeStart + " - " + timeEnd,
                icon: 'fa_walking',// icons[list[i].direction % icons.length],
                timeStart: timeStart,
                timeEnd: timeEnd,
                direction: list[i].direction})
        }
//root.log("REG:", JSON.stringify(regDays))
//root.log("SPEC:", JSON.stringify(specDays))
    // TODO: check for stdWeek - 7 days max!
    //n = Math.max.apply(null, Object.keys(regDays))
    for (i = 1; i <= 31; i++)
        res.monthDays.push({id: tid++, label: i, form: 'time', icon: 'fa_circle', children: monthDays[i] || []})

    for (i = 1; i <= 7; i++)
        res.weekDays.push({id: tid++, label: dayNames[i-1], form: 'time', icon: 'fa_circle', children: weekDays[i] || []})

    for (label in specDays)
        res.specialDays.push({id: tid++, label: label, form: 'time', date: label, icon: 'fa_circle', children: specDays[label]})
    //root.log("RES:", JSON.stringify(res))
    return res
    /*return [
            {label: '02.12.2020', date: '02.12.2020', icon: 'fa_circle', tid: tid++, children: []},
            {label: '31.12.2020', date: '31.12.2020', icon: 'fa_circle', tid: tid++, children: []}
    ]*/
}

Rules.prototype.delete = function (id) {
    Utils.deleteItem(this.model, id)
}

Rules.prototype.update = function (data) {
    //root.log("RulesJS:UPD", JSON.stringify(data))
    // {"name":"sdfsdf","description":"23423rsdvw","startDate":"2021-01-29T00:00:00.000Z","endDate":"2021-01-30T00:00:00.000Z","stdWeek":false,"priority":20,"id":-20,"timeRanges":[]}
    if (data.id === 0)
        return
    var i,
        item = newItem(data),
        rule = Utils.findItem(this.model, item.id)
    //root.log("RulesJS:ITEM", JSON.stringify(item))
    //if (Utils.replaceItem(this.model, item)) {
    if (rule) {
        // UPDATE
        for (i in item)
            if (!(item[i] instanceof Array))
                rule[i] = item[i]
        rule.specialDays.clear()
        rule.specialDays.append(item.specialDays)
        rule.weekDays.clear()
        rule.weekDays.append(item.weekDays)
        rule.monthDays.clear()
        rule.monthDays.append(item.monthDays)
        //this.model.update(rule.id)
        root.rules.updated(rule.id)
    } else {
        // CREATE
        this.model.append(item)
    }

    // TODO: sort (use DelegateModel? https://martin.rpdev.net/2019/01/15/using-delegatemodel-in-qml-for-sorting-and-filtering.html)
}

function formatDate(date) {
    var d = date.getDate(),
        m = 1 + date.getMonth()
    return [d < 10 ? '0' + d : d, m < 10 ? '0' + m : m, date.getFullYear()].join('.')
}

function newItem(data) {
    var ranges = getRanges(data.timeRanges)
    return {
        label: data.name,
        id: data.id, // real rule id here
        priority: data.priority,
        name: data.name,
        description: data.description,
        startDate: formatDate(new Date(data.startDate)),
        endDate: formatDate(new Date(data.endDate)),
        specialDays: data.priority < 100 ? null : ranges.specialDays,
        weekDays: ranges.weekDays,
        monthDays: data.priority < 100 ? null : ranges.monthDays,
        icon: 'fa_circle',
        form: /*data.priority < 100 ? 'basic-rule' :*/ 'rule'
    }
}
