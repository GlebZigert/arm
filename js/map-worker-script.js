WorkerScript.onMessage = function(msg) {
    root.log(msg.index, msg.prstate);
    msg.model.remove(msg.index)
    msg.model.sync();
 }
