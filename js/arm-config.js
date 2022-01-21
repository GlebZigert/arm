var layouts = {},
    commands = {},
    config = {}

///////////////////////////////////
//{id: 1, text: "Администратор"},
layouts[1] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]},
    //{symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    //{symbol: '2', views: [['MyMap', 'PassageView'], ['MyJournal', 'ZonesTree']]},
    {symbol: '3', views: [['DevicesTree'], ['MyJournal']]},
    {symbol: '4', views: [['EventLog']]},
    {symbol: '5', views: [['Video']]},
]
commands[1] = ["ListServices", "ListMaps", "ListUsers", "ListRules", "ListZones", "ListAlgorithms", "LoadJournal"]
config[1] = {
    DevicesTree: 1,
    //UserTree: 7, // FOR TEST ONLY
    UserTree: 4, // bit mask for tab's #
    //RulesTree: 1, // FOR TEST ONLY
    RulesTree: 0, // view only
    ZonesTree: 1,
    MyMap: 1,
    Algorithms: 1,
    EventLog: 1}


/////////////////////////////////// read-only?
//{id: 2, text: "Дежурный по ВЧ"},
///////////////////////////////////
layouts[2] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
//    {symbol: '2', views: [['Test']]},
    {symbol: '3', views: [['ZonesTree'], ['MyJournal']]},
]
commands[2] = ["ListServices", "ListMaps", "ListZones", "LoadJournal"]
config[2] = {}

/////////////////////////////////////////
//{id: 3, text: "Дежурный по КПП и КТП"},
/////////////////////////////////////////
layouts[3] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '2', views: [['Test']]},
    {symbol: '3', views: [['DevicesTree', 'PassageView'], ['MyJournal']]},
]
commands[3] = ["ListServices", "ListMaps", "LoadJournal"]
config[3] = {}

/////////////////////////////////////
//{id: 4, text: "Начальник Караула"},
///////////////////////////////////
layouts[4] = [
    {symbol: '1', views: [['DevicesTree'], ['MyMap', 'MyJournal']]},
    {symbol: '3', views: [['Test']]},
    {symbol: '2', views: [['ZonesTree'], ['MyJournal']]},
]
commands[4] = ["ListServices", "ListMaps", "ListZones", "LoadJournal"]
config[4] = {}

//////////////////////////////////// read-only?
//{id: 5, text: "Оператор ТСО"},
layouts[5] = [
    {symbol: '1', views: [['DevicesTree'], ['MyJournal', 'MyMap']]},
    {symbol: '2', views: [['Test']]},
]
commands[5] = ["ListServices", "ListMaps", "LoadJournal"]
config[5] = {}

///////////////////////////////////
//{id: 6, text: "Защита ГосТайны"},
///////////////////////////////////
layouts[6] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]},
    {symbol: '1', views: [['DevicesTree'], ['MyJournal']]},
    {symbol: '2', views: [['EventLog']]}
]
commands[6] = ["ListServices", "ListUsers", "ListRules", "ListZones", "LoadJournal"]
config[6] = {
    UserTree: 2, // bit mask for tab's #
    RulesTree: 1,
    ZonesTree: 0,
    EventLog: 0
}

///////////////////////////////////
//{id: 7, text: "Бюро Пропусков"}])
///////////////////////////////////
layouts[7] = [
    {symbol: 'fa_users_cog', views: [['MyConfig']]}
]
commands[7] = ["ListUsers", "ListRules", "ListZones"]
config[7] = {
    UserTree: 3, // bit mask for tab's #
    RulesTree: 1,
    ZonesTree: 0,
}
