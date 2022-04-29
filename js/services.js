.import "arm-config.js" as ARM
.import "constants.js" as Const
.import "utils.js" as Utils
.import "journal.js" as Journal
.import "locations.js" as Locations

.import "users.js" as Users
.import "rules.js" as Rules
.import "maps.js" as Maps
.import "zones.js" as Zones
.import "algorithms.js" as Algorithms

.import "rif-plus.js" as RifPlus
.import "axxon.js" as Axxon
.import "z5rweb.js" as Z5RWeb
.import "parus.js" as Parus

var factory = {
    rif: RifPlus.Rif,
    axxon: Axxon.Axxon,
    z5rweb: Z5RWeb.Z5RWeb,
    parus: Parus.Parus,
}


var qml,
    services = {}

function init() {
    qml = {
        devices: root.devices.get(0).children,
        users: root.users.get(0).children}

    root.getService.connect(getService)
    root.services = services
}

function getService(id) {
    console.log('GET SERVICE:', id, services[id])
    return services[id]
}

function message(msg) {
    if (!qml) init()

    if (0 === msg.service && msg.action in handlers) {
        console.log('Running CORE action:', msg.action)
        if ("function" === typeof handlers[msg.action])
            handlers[msg.action](msg)
        else if (msg.action in handlers[msg.action].handlers)
            handlers[msg.action].handlers[msg.action](msg) // WTF?
        else
            console.log('Handler not found:', msg.action)
        console.log('Done action:', msg.action)
    } else if (msg.service in services && msg.action in services[msg.service].handlers) {
        console.log('Running action', msg.action, 'on', msg.service)
        services[msg.service].handlers[msg.action](msg.data, !msg.task)
        console.log('Done action', msg.action)
     } else if (0 !== msg.service && !(msg.service in services)) {
        console.log('Unknown service:', msg.service, " => reload services list")
        root.send(0, "ListServices", "")
     } else
        console.log('Unknown action:', msg.action, 'on', msg.service)
    if ("Events" === msg.action)
        scanEvents(msg.data)
}

// handlers for "configuration" adaper on server, singletones
var handlers = {
    ListLocations: Locations.listLocations,
    LoadJournal: Journal.loadJournal,
    DescribeEvent: Journal.describeEvent,
    ////////////////////////////////////////////////////////
    ////////////////////// A L G O S ///////////////////////
    ////////////////////////////////////////////////////////
    ListAlgorithms: Algorithms,
    UpdateAlgorithm: Algorithms,
    DeleteAlgorithm: Algorithms,
    ////////////////////////////////////////////////////////
    ////////////////////// Z O N E S ///////////////////////
    ////////////////////////////////////////////////////////
    ListZones: Zones,
    UpdateZone: Zones,
    DeleteZone: Zones,
    EnterZone: Zones,
    //////////////////////////////////////////////////////
    ////////////////////// M A P S ///////////////////////
    //////////////////////////////////////////////////////
    PlanUpload: Maps,
    ListMaps: Maps,
    UpdateMap: Maps,
    DeleteMap: Maps,
    //////////////////////////////////////////////////////
    ///////////////////// R U L E S //////////////////////
    //////////////////////////////////////////////////////
    ListRules: Rules,
    UpdateRule: Rules,
    DeleteRule: Rules,
    //////////////////////////////////////////////////////
    ///////////////////// U S E R S //////////////////////
    //////////////////////////////////////////////////////
    UserUpload: Users,
    ListUsers: Users,
    UpdateUser: Users,
    DeleteUser: Users,
    UserInfo: Users,
    AffectedUsers: reconnectUser,
    //////////////////////////////////////////////////////
    /////////////////// S E R V I C E S //////////////////
    //////////////////////////////////////////////////////
    ListServices: listServices,

    UpdateService: function (msg) {
        if (msg.data.id in services)
            updateService(services[msg.data.id], msg.data)
        else
            newService(msg.data)
    },

    DeleteService: function (msg) {
        console.log('[DeleteService]', JSON.stringify(msg))
        if (msg.data in services) {
            deleteService(msg.data)
        } else
            console.log('[DeleteService] unknown service', msg.data)
    },
    //////////////////////////////////////////////////////
    ////////////////////// E X T R A /////////////////////
    //////////////////////////////////////////////////////
    Error: function (msg) {
        //console.log('LF', JSON.stringify(msg))
        //if ([2, 3].indexOf(msg.data.class) >= 0)
        messageBox.error(msg.data.text)
        socket.stopped = true
    },


    ListBackups: function (msg) {
        var list = (msg.data || []).map(function (v) {
            return {file: v}
        })
        root.databaseBackups.clear()
        root.databaseBackups.append(list)
    },


    // INFO: using event
    //RunAlarm: function() {playAlarm("alarm")},

    CompleteShift: function (msg) {
        root.currentUser = undefined
        root.userToken = root.userLogin = ''
        socket.stopped = true
    },

    ChangeUser: function (msg) {
        var i, cleanup = ['devices', 'users', 'rules', 'events', 'maps', 'zones', 'algorithms']
        if (msg.data.error) {
            if (0 === root.armRole)
                socket.stopped = true
            messageBox.error(msg.data.error)
            return
        }

        root.currentUser = msg.data

        if (0 === root.armRole) {
            root.armRole = msg.data.role
            root.armConfig = ARM.config[root.armRole]
            root.panes = ARM.layouts[root.armRole]
        } else { // cleaning up models
            root.events.clear()
            /*for (i = 0; i < cleanup.length; i++) {
                console.log("Cleaning", cleanup[i])
                root[cleanup[i]].clear()
            }*/
        }

        armCommands()
    },
}

function armCommands() {
    var i,
        commands = ARM.commands[root.armRole]
    for (i = 0; i < commands.length; i++)
        socket.sendTextMessage('{"Service": 0, "Action": "' + commands[i] + '"}')
}

function newService(service) {
    //{"id":2,"type":"rif","title":"Риф ДЕМО","host":"127.0.0.1:1978","login":"","password":"","keepAlive":5,"dbHost":"192.168.0.1:3306","dbName":"","dbLogin":"","dbPassword":"","status":{"tcp":"online","db":""}}
    //console.log("newService():", JSON.stringify(service))
    var item
    if (service.type in factory) {
        service.serviceId = service.id
        service.id = 0
        service.scopeId = service.serviceId // used for ACS filtering in UserFormPage3.qml
        service.form = 'service'
        service.icon = 'fa_cog'
        service.label = service.title
        service.children = []
        service.isGroup = true
        //service.expanded = false
        service.color = ''// placeholder Utils.serviceColor(service.status)
        service.api = {contextMenu: '111'} // placeholder
        qml.devices.append(service)

        item = qml.devices.get(qml.devices.count - 1)
        services[service.serviceId] = new factory[service.type](item)
/*
        if(service.type=="axxon"){
            console.log("[service.type==Axxon.Axxon]")
        root.axxon_service_id=service.serviceId
        }
        */
    }
}

function updateService(service, data) {
    var key,
        exclude = ['id', 'type']

    for (key in data)
        if (exclude.indexOf(key) < 0)
            service.model[key] = data[key]

    service.model.label = data.title
    Utils.setInitialStatus(service.model, service.statusUpdate.bind(service))
}

function deleteService(id) {
    for (var i = 0; i < qml.devices.count; i++) {
        //console.log(JSON.stringify(qml.devices.get(i)))
        if (qml.devices.get(i).serviceId === id) {
            if (id in services && ('shutdown' in services[id]))
                services[id].shutdown()
            qml.devices.remove(i)
            break
        }
    }
    delete services[id]
}

function reconnectUser(msg) {
    var i;
    if (!msg.data)
        return
    for (i = 0; i < msg.data.length && msg.data[i] !== currentUser.id; i++);
    if (i >= msg.data.length)
        return


    console.log("Reload user-affected data")
    var reload = ["ListServices", "ListMaps", "ListZones"]
    for (i = 0; i < reload.length; i++)
        if (ARM.commands[root.armRole].indexOf(reload[i]) >= 0)
            root.send(0, reload[i], "")

    /*for (i in services)
        if ('reloadTree' in services[i])
            services[i].reloadTree()*/
}

function listServices(msg) {
    //console.log("LIST SVC:", JSON.stringify(msg))
    if (null === msg.data)
        return

    var i,
        id,
        service,
        all = Object.keys(services).map(function (v){return parseInt(v)})

        for (i = 0; i < msg.data.length; i++) {
            id = msg.data[i].id
            if (id in services) {
                updateService(services[id], msg.data[i])
                all.splice(all.indexOf(id), 1)
            } else
                newService(msg.data[i])
        }

        // delete unlisted services
        for (i = 0; i < all.length; i++)
            deleteService(all[i])
    }

function scanEvents(events) {
    var eventList = []
    //console.log("ScanEvents", JSON.stringify(events))
    if (!events)
        return
    for (var i = 0; i < events.length; i++) {
        switch (events[i].class) {
            // EC_CONTROL_FORBIDDEN is emitted by core, but serviceId corresponds to deviceId
            case Const.EC_DB_BACKED_UP:
                if (Const.ARM_ADMIN === root.armRole)
                    root.send(0, "ListBackups", "")
                break
            case Const.EC_CONTROL_FORBIDDEN: eventList.push(events[i]); break
            case Const.EC_ENTER_ZONE: Zones.enterZone(events[i]); break
            case Const.EC_GLOBAL_ALARM: playAlarm("alarm"); break
            case Const.EC_ACCESS_VIOLATION: playAlarm("alarm"); break
        }
        if (0 === events[i].serviceId)
            eventList.push(events[i])
    }
    if (eventList.length > 0) {
        Journal.logEvents(eventList)
    }
}
