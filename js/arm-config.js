.import "constants.js" as Const

var layouts = {},
    commands = {},
    config = {}

// who can control zones
var zoneOperators = [Const.ARM_ADMIN, Const.ARM_UNIT, Const.ARM_GUARD]

///////////////////////////////////
//{id: 1, text: "Администратор"},
layouts[Const.ARM_ADMIN] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]},
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '2', views: [['MyMap', 'PassageView'], ['MyJournal', 'ZonesTree']]},
    {symbol: '3', views: [['DevicesTree'], ['MyJournal']]},
    {symbol: '4', views: [['EventLog']]},
    {symbol: '5', views: [['MyVideo']]},
    {symbol: '6', views: [['VideoRB']]},

]
commands[Const.ARM_ADMIN] = ["ListServices", "ListMaps", "ListUsers", "ListRules", "ListZones", "ListAlgorithms", "LoadJournal", "ListBackups", "ListSettings"]
config[Const.ARM_ADMIN] = {
    DevicesTree: 1,
    UserTree: 7, // GOD mode
    RulesTree: 1, // GOD mode
    ZonesTree: 1,
    MyMap: 1,
    Algorithms: 1,
    EventLog: 1,
    MySettings: 1}


/////////////////////////////////// read-only?
//{id: 2, text: "Дежурный по ВЧ"},
///////////////////////////////////
layouts[Const.ARM_UNIT] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '2', views: [['MyVideo']]},
    {symbol: '3', views: [['ZonesTree'], ['MyJournal']]},
    {symbol: '4', views: [['EventLog']]},
]
commands[Const.ARM_UNIT] = ["ListServices", "ListMaps", "ListZones", "LoadJournal", "ListSettings"]
config[Const.ARM_UNIT] = {}

/////////////////////////////////////////
//{id: 3, text: "Дежурный по КПП и КТП"},
/////////////////////////////////////////
layouts[Const.ARM_CHECKPOINT] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '2', views: [['MyVideo']]},
    {symbol: '3', views: [['DevicesTree', 'PassageView'], ['MyJournal']]},
]
commands[Const.ARM_CHECKPOINT] = ["ListServices", "ListMaps", "LoadJournal", "ListSettings"]
config[Const.ARM_CHECKPOINT] = {}

/////////////////////////////////////
//{id: 4, text: "Начальник Караула"},
///////////////////////////////////
layouts[Const.ARM_GUARD] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '3', views: [['MyVideo']]},
    {symbol: '2', views: [['ZonesTree'], ['MyJournal']]},
]
commands[Const.ARM_GUARD] = ["ListServices", "ListMaps", "ListZones", "LoadJournal", "ListSettings"]
config[Const.ARM_GUARD] = {}

//////////////////////////////////// read-only?
//{id: 5, text: "Оператор ТСО"},
layouts[Const.ARM_OPERATOR] = [
    {symbol: '1', views: [['DevicesTree'], ['MyJournal', 'MyMap']]},
    {symbol: '2', views: [['MyVideo']]},
]
commands[Const.ARM_OPERATOR] = ["ListServices", "ListMaps", "LoadJournal", "ListSettings"]
config[Const.ARM_OPERATOR] = {}

///////////////////////////////////
//{id: 6, text: "Защита ГосТайны"},
///////////////////////////////////
layouts[Const.ARM_SECRET] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]},
    {symbol: '1', views: [['DevicesTree'], ['MyJournal']]},
    {symbol: '2', views: [['EventLog']]}
]
commands[Const.ARM_SECRET] = ["ListServices", "ListUsers", "ListRules", "ListZones", "LoadJournal", "ListSettings"]
config[Const.ARM_SECRET] = {
    UserTree: 2, // bit mask for tab's #
    RulesTree: 1,
    ZonesTree: 0,
    EventLog: 0
}

///////////////////////////////////
//{id: 7, text: "Бюро Пропусков"}])
///////////////////////////////////
layouts[Const.ARM_BUREAU] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]}
]
commands[Const.ARM_BUREAU] = ["ListUsers", "ListRules", "ListZones", "ListSettings"]
config[Const.ARM_BUREAU] = {
    UserTree: 3, // bit mask for tab's #
    RulesTree: 1,
    ZonesTree: 0,
}
