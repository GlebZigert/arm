function postData(url, arrayBuffer, callback) {
    var xhr = new XMLHttpRequest
    xhr.open("POST", url, false)

    xhr.onreadystatechange = function() {
        //root.log(JSON.stringify(xhr.getAllResponseHeaders()))
        if (xhr.readyState === XMLHttpRequest.DONE)
            callback(200 === xhr.status)
    }
    xhr.send(arrayBuffer)
}

function readFile(file, callback) {
    var xhr = new XMLHttpRequest()
        //file = "file:///" + applicationDirPath + "/plan-combo.png";
    xhr.open("GET", file, true)
    xhr.responseType = "arraybuffer"

    xhr.onreadystatechange = function() {
        //root.log("state", xhr.readyState, xhr.status)
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (200 === xhr.status && xhr.response) {
                callback(xhr.response)
            } else {
                //root.log('XMLHttpRequest.status =', xhr.status)
                callback(null)
            }
        }
    }
    xhr.send(null)
}
