WorkerScript.onMessage = function(msg) {
    console.log(msg.index, msg.prstate);
    msg.model.remove(msg.index)
    msg.model.sync();
 }
