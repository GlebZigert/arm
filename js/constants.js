var classNames = {
    0: 'na',
    100: 'info',
    200: 'ok',
    300: 'error',
    400: 'lost',
    500: 'alarm',
    na: 0,
    info: 100,
    ok: 200,
    error: 300,
    lost: 400,
    alarm: 500
}

var classColors = {
    0: "#a5a5a5",
    na: "#a5a5a5",

    100: "#a5a5a5",
    info: "#a5a5a5",

    200: "#00db00",
    ok: "#00db00",

    300: "#0f2dfb",
    error: "#0f2dfb",

    400: "#ffc000",
    lost: "#ffc000",

    500: "#ff0000",
    alarm: "#ff0000"
}

// constants from api/types.go

const   ARM_ADMIN       = 1, // админ
        ARM_UNIT        = 2, // начальник ВЧ
        ARM_CHECKPOINT  = 3, // начальник КПП
        ARM_GUARD       = 4, // начальник караула
        ARM_OPERATOR    = 5, // оператор
        ARM_SECRET      = 6, // гостайна
        ARM_BUREAU      = 7 // бюро пропусков

const armNames = {
    [ARM_ADMIN]: "Администратор",
    [ARM_UNIT]: "Дежурный по ВЧ",
    [ARM_CHECKPOINT]: "Дежурный по КПП и КТП",
    [ARM_GUARD]: "Начальник Караула",
    [ARM_OPERATOR]: "Оператор ТСО",
    [ARM_SECRET]: "Защита ГосТайны",
    [ARM_BUREAU]: "Бюро Пропусков"
}

const   EC_NA = 0,  //iota
        // INFO
        EC_INFO                 = 100,
        EC_ENTER_ZONE           = 101,
        EC_EXIT_ZONE            = 102,         // virtual code
        EC_INFO_ALARM_RESET     = 103,
        EC_USER_LOGGED_IN       = 104,
        EC_USER_LOGGED_OUT      = 105,
        EC_ARM_TYPE_MISMATCH    = 106,
        EC_LOGIN_TIMEOUT        = 107,
        EC_USER_SHIFT_STARTED   = 108,
        EC_USER_SHIFT_COMPLETED = 109,
        EC_TIME_MISMATCH        = 110,
        EC_SERVICE_SHUTDOWN     = 111,
        EC_ARMED                = 112,
        EC_DISARMED             = 113,
        EC_POINT_BLOCKED        = 114,
        EC_FREE_PASS            = 115,
        EC_NORMAL_ACCESS        = 116,
        EC_ALGO_STARTED         = 117,
        EC_CONTROL_FORBIDDEN    = 118,
        EC_DB_BACKED_UP         = 119,

        // OK
        EC_OK                     = 200,
        EC_ACCESS_VIOLATION_ENDED = 201,
        EC_CONNECTION_OK          = 202,
        EC_SERVICE_ONLINE         = 203,
        EC_DATABASE_READY         = 204,
        EC_ONLINE                 = 205,
        EC_UPS_PLUGGED            = 206,
        EC_SERVICE_READY          = 207,

        // ERROR
        EC_ERROR                = 300,
        EC_USERS_LIMIT_EXCEED   = 301,
        EC_SERVICE_FAILURE      = 302,  // internal error
        EC_SERVICE_ERROR        = 303,  // remote service error
        EC_DATABASE_ERROR       = 304,
        EC_USE_DB_BACKUP        = 305, // primary db failure, use backup
        EC_DB_BACKUP_FAILED     = 306,
        EC_FREQUENT_BACKUPS     = 307,

        // LOST (no link)
        EC_LOST                 = 400,
        EC_CONNECTION_LOST      = 401,
        EC_SERVICE_OFFLINE      = 402,
        EC_DATABASE_UNAVAILABLE = 403,

        // ALARM
        EC_ALARM                = 500,
        EC_GLOBAL_ALARM         = 501,
        EC_ACCESS_VIOLATION     = 502,
        EC_ALREADY_LOGGED_IN    = 503,
        EC_LOGIN_FAILED         = 504,
        EC_UPS_UNPLUGGED        = 505


var serviceStatuses = {}
serviceStatuses[EC_SERVICE_READY] = "self"
serviceStatuses[EC_SERVICE_SHUTDOWN] = "self"
serviceStatuses[EC_SERVICE_FAILURE] = "self"
serviceStatuses[EC_SERVICE_ONLINE] = "tcp"
serviceStatuses[EC_SERVICE_OFFLINE] = "tcp"
serviceStatuses[EC_SERVICE_ERROR] = "tcp"
serviceStatuses[EC_DATABASE_READY] = "db"
serviceStatuses[EC_DATABASE_UNAVAILABLE] = "db"
serviceStatuses[EC_DATABASE_ERROR] = "db"

var useAlarms = [ARM_UNIT, ARM_CHECKPOINT, ARM_GUARD, ARM_OPERATOR]
