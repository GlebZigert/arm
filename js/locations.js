.import "utils.js" as Utils
.import "constants.js" as Const


function listLocations(msg) {
    console.log("LOC:", JSON.stringify(msg.data))
    var i, list = []
    for (i in msg.data)
        list.push()

    root.locations.clear()
}
