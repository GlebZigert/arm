.import "utils.js" as Utils
.import "journal.js" as Journal
.import "constants.js" as Constants
function Axxon(model) {
    this.model = model
    this.serviceId = this.model.serviceId
    //this.statusUpdate()

    root.log("[service.type==Axxon.Axxon]")
root.axxon_service_id=this.serviceId

    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        UpdateDevices: this.update.bind(this),
        DateTime: this.receive_strorage_stream.bind(this),
        request_URL: this.receive_URL.bind(this),
        ExecCommand: this.ExecCommand_handler.bind(this),
        request_intervals:  this.request_intervals_handler.bind(this),
        Telemetry_capture_session:  this.handler_for_Telemetry_capture_session.bind(this),
        Telemetry_command:  this.handler_Telemetry_command.bind(this),
        Axxon_Event: this.Axxon_event_handler.bind(this),
        Events: this.processEvents.bind(this)
    }
    Utils.setInitialStatus(model, this.statusUpdate.bind(this))
}

Axxon.prototype.statusUpdate = function (sid) {
    if (Constants.EC_SERVICE_ONLINE === sid && this.model.status.tcp !== sid)
        root.send(this.serviceId, 'ListDevices', '')

    Utils.setServiceStatus(this.model, sid)
}


// all available states for each device type, used for algorithms form
var states = {
    11: [0, 1, 3, 10, 11, 20, 100, 101, 136, 137],
    12: [0, 10, 100, 101, 130, 131],
    10011: [1, 3, 11, 110, 111, 112, 113, 150, 151, 2, 17, 136, 137] // lock, custom type (1e4 + 11)
}

var stickyStates = [10, 2, 12, 13, 18, 20, 21, 22, 23, 25, 113, 143, 1143, 145]
//
var stateName = {
    0: 'Неопределенное состояние',
    1: 'Норма',
    3: 'Команда ДК выполнена',
    5: 'Норма по ЧЭ1',
    6: 'Норма по ЧЭ2',
    10: 'Нет связи',
    11: 'Команда ДК не выполнена',
    12: 'Неисправность по ЧЭ1',
    12: 'Неисправность ДД',
    12: 'Неисправность - Уход уровня',
    13: 'Неисправность по ЧЭ2',
    18: 'Неисправность ЧЭ',
    20: 'Тревога - Сработка',
    21: 'Тревога - Вскрытие',
    22: 'Тревога - Сработка по ЧЭ1',
    22: 'Тревога – Конф-ция изменена',
    23: 'Тревога - Сработка по ЧЭ2',
    23: 'Тревога - Сработка по ЧЭ№',
    25: 'Тревога – Синхр-ция изменена',
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




Axxon.prototype.processEvents = function (events) {

var className

root.playAlarm(className)

root.log("Axxon Events", JSON.stringify(events))
    // [{"fromState":0,"state":1004,"data":"","text":"Удал.ком. Открыть","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"},{"fromState":0,"state":111,"data":"","text":"Открыто","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"}]
var item,
sType

for (var i = 0; i < events.length; i++) {

    className = Utils.className(events[i].class)
    root.log("className: ",className)

    if(className==='alarm'){


        var str=events[i].commands
        root.log('event.commands', str)
        str=str.replace(/(\[)/g, "")
        root.log('event.commands', str)
        str=str.replace(/(\])/g,"")
        root.log('event.commands', str)
        var arr=str.split(",",4)
        var serviceId=arr[0]
        var globalDeviceId=events[i].deviceId
        var cameraId="";



        root.log("DeviceId: ",globalDeviceId)

        for(var j=0;j<root.cameraList.count;j++){

            root.log("DeviceId: ",globalDeviceId," root.cameraList[i].: ",root.cameraList.get(j).id)
            if(globalDeviceId==root.cameraList.get(j).id){

                root.log("[PROFIT]")
                root.cameraList.get(j).mapState="alarm"
                root.cameraList.get(j).color="red"
                root.cameraList.get(j).display="blink"
                             //   root.cameraList.get(j).stickyState = true
                root.cameraList.get(j).stickyState=true

                var x=root.cameraList.get(j)


                Utils.updateMaps(x)


            }
        }

        root.playAlarm(className)


    }

     if((className==='ok')||(className==='lost')){

         var str=events[i].commands
         root.log('event.commands', str)
         str=str.replace(/(\[)/g, "")
         root.log('event.commands', str)
         str=str.replace(/(\])/g,"")
         root.log('event.commands', str)
         var arr=str.split(",",4)
         var serviceId=arr[0]
         var globalDeviceId=events[i].deviceId
         var cameraId="";

         root.restored(globalDeviceId)


         root.log("DeviceId: ",globalDeviceId)

         for(var j=0;j<root.cameraList.count;j++){

             root.log("DeviceId: ",globalDeviceId," root.cameraList[i].axxon_id: ",root.cameraList.get(j).id)
             if(globalDeviceId==root.cameraList.get(j).id){

                 root.log("[PROFIT !!!]")

            //     root.cameraList.get(j).stickyState=false
                 root.cameraList.get(j).mapState=data[i].state
                 root.cameraList.get(j).display="flash"
                 var x=root.cameraList.get(j)

                 if(x.stickyState==false)
                 Utils.updateMaps(x)


             }
         }

     }

    if(className==='info'){

        if(events[i].text==='Сброс тревог'){

            var str=events[i].commands
            root.log('event.commands', str)
            str=str.replace(/(\[)/g, "")
            root.log('event.commands', str)
            str=str.replace(/(\])/g,"")
            root.log('event.commands', str)
            var arr=str.split(",",4)
            var serviceId=arr[0]
            var globalDeviceId=events[i].deviceId
            var cameraId="";


            root.log("DeviceId: ",globalDeviceId)

            for(var j=0;j<root.cameraList.count;j++){

                root.log("DeviceId: ",globalDeviceId," root.cameraList[i].: ",root.cameraList.get(j).id)
                if(globalDeviceId==root.cameraList.get(j).id){

                    root.log("[PROFIT !!!]")

                    root.cameraList.get(j).stickyState=false

                    root.cameraList.get(j).display=""
                    var x=root.cameraList.get(j)


                    Utils.updateMaps(x)


                }
            }



        }



    }else{
        var globalDeviceId=events[i].deviceId

        if(globalDeviceId==0){
            root.log("globalDeviceId==0")
        this.statusUpdate(events[i].class)
        }
    }


}

Journal.logEvents(events)

}
//Axxon.prototype.get_service_id = function(){
function get_service_id() {
root.log("[get_service_id()] ",Axxon.serviceId)
 root.log("[get_service_id()] ",this.serviceId)
}

Axxon.prototype.Axxon_event_handler = function (data)
{
    root.log("[Axxon_event_handler]")
 //   root.log(data)
 //   root.log(data.objects)
 //   root.log(data.objects[0])
 //   root.log(data.objects[0].name)
 //   root.log(data.objects[0].state)
    root.log(JSON.stringify(data))
 //   root.log(root.devices)

    for (var i in data.objects) {
     root.log('---')
root.log(data.objects[i])
     root.log(data.objects[i].name," ",data.objects[i].state)

        var point=data.objects[i].name.replace("hosts/","")
        var state=data.objects[i].state
        if(data.objects[i].type=="devicestatechanged")
        for(var j=0;j<root.cameraList.count;j++)
        {
          var x=root.cameraList.get(j)
            root.log(x.point)
            if(x.point==point)
            {
            root.log("PROFIT !!!")
                var id=x.id
            root.log("x.id: ",id)
            root.log("this.serviceId: ",this.serviceId)
                var device=Utils.findItem(root.devices,id)
            root.log("device.name: ",device.name)

                var color="gray"
                if(state=="signal lost")
                    color="red"
                if(state=="signal restored"){
                    color="green"
                    root.restored(id)
                }
              Utils.replaceItem(root.devices, {
                                                id: device.id,
                                                serviceId: device.serviceId,
                                                label: device.name,
                                                name: device.name,
                                                color: color,
                                                icon: device.icon,
                                                children: [],
                                                form: device.icon
                                    })

                root.devices.updated()
            }

        }






    }



//    var device=Utils.findDevice(root.devices,)
}

Axxon.prototype.shutdown = function () {
    root.log(this.model.type, this.model.id, 'shutdown')
}

Axxon.prototype.datetime = function()
{

      root.send(this.serviceId, 'DateTime', '12345')
}


function dt(value)
{
    root.log(slider.value)
    value=slider.value
     var hours=Math.floor(value/3600)
     var min=Math.floor((value-hours*3600)/60)
     var sec=((value-hours*3600)-min*60)
     root.log("часы ",hours)
     root.log("мин ",min)
     root.log("сек ",sec)

    var str_hour
    if(hours<10)
    str_hour="0"+hours.toString()
    else
    str_hour=hours.toString()



    var str_min
    if(min<10)
    str_min="0"+min.toString()
    else
    str_min=min.toString()

    var str_sec
    if(sec<10)
    str_sec="0"+sec.toString()
    else
    str_sec=sec.toString()



    return str_hour+":"+str_min+":"+str_sec+
    "   "+"T"+str_hour+str_min+str_sec




   //   root.send(2, 'DateTime', '12345')
}



function send_dt(value)
{

      root.send(2, 'DateTime', value)
}

function  get_rtsp_streams_url() {
    var url_array=new Array()






    url_array[0]="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:0"
    url_array[1]="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.1/SourceEndpoint.video:0:1"
    url_array[2]="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:0"
    url_array[3]="rtsp://root:root@192.168.0.187:50554/hosts/ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:1"


   // root.log('hello_world')
    return url_array//"hosts/ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:1"

}

function  get_wigth(len, size, count) {

     root.log("len: ",len)
     root.log("size: ",size)
         root.log("count: ",count)
    root.log("Math.floor(len/size) ",Math.floor(len/size))


    if(Math.floor(len/size)<count)
    return size*Math.floor(len/size);
    else
    return count*size

}

Axxon.prototype.handler_Telemetry_command = function (data) {

    root.log("[handler_Telemetry_command]")
    root.log(data)
    root.log(JSON.stringify(data))
    root.log("data.Name: ",data.name)

    var str=""
    switch (data.name){

    case "preset_info":
        receive_preset_info(data.data)
    break

    case "No_access":


     //    root.another_user.clear()

     //     str="У вас нет доступа."
    //    root.another_user.append({message: str})

    //   root.another_user.updated()
    break

    case "Another_user":

    root.log("data.data: ",data.data)
    root.log("data.data.name: ",data.data.name)
    root.log("data.data.surename: ",data.data.surename)

     root.another_user.clear()

      str="Управление забрал "+data.data.name+" "+data.data.surename
    root.another_user.append({message: str})

   root.another_user.updated()

    break


    }

}





function getListDevices()
{
    root.log("")
    root.log("[getListDevices]")
    root.log("")
  root.send(this.serviceId, 'ListDevices', '')
}

Axxon.prototype.request_intervals_handler = function (data) {

    console.log("")
    console.log("[request_intervals_handler]")
    console.log("",Date())
    console.log(JSON.stringify(data))
    console.log("")

    var id = data[0].Id
    for(var i=0;i<root.cameraList.count;i++){


        if(root.cameraList.get(i).id===id){

            root.cameraList.get(i).intervals=data[0].intervals

        }

    }


   root.update_intervals(data[0].intervals)

}

Axxon.prototype.ExecCommand_handler = function (data) {

     //console.log("")
     //console.log("[ExecCommand_handler]")
     //console.log("")



    //взять id и сделать эту камеру текущей и перейтив  режим прямой трансляции.

    //console.log(data)
    //console.log(JSON.stringify(data))
    var id=data.id
    //console.log("id: ",id)
    root.event_on_camera(id)
root.activePane=root.videoPane
/*

    root.log("id",data[0].id)
    root.log("telemetryControlID",data[0].telemetryControlID)
    root.camera_to_livestream.append({id: data[0].id})

     root.log("camera_to_livestream.count: ",camera_to_livestream.count)
    if(camera_to_livestream.count>0)
     root.log("id",camera_to_livestream.get(0).id)



    root.log("------------------------------------")
    root.log("")

    root.log("data[0].intervals ",data[0].intervals)
    root.log("")
    root.log("------------------------------------")

    root.current_camera.clear()
   root.current_camera.append({
                                id: data[0].id ,
                                liveStream : data[0].liveStream ,
                              storageStream : data[0].storageStream,
                             snapshot  : data[0].snapshot,
                             telemetryControlID : data[0].telemetryControlID,
                             intervals: data[0].intervals

               })





    root.camera_to_livestream.updated()




    if(root.armRole!=Constants.ARM_ADMIN){
    root.activePane=root.videoPane
    }
*/
}


Axxon.prototype.receive_URL = function (data) {

     console.log("")
         console.log("[receive_URL]")
     console.log("",Date())

         console.log(data)
         console.log(JSON.stringify(data))
          console.log(JSON.stringify(data))
      console.log("")
     var i
     for (i in data.data) {
      //console.log("id: ", data.data[i].id)
      //console.log("liveStream: ", data.data[i].liveStream)
      //console.log("storageStream: ", data.data[i].storageStream)
      root.log("snapshot: ", data.data[i].snapshot)
      root.log("интервалы: ", JSON.stringify(data.data[i].intervals))


     var cl = root.cameraList
     for(var j=0;j< root.cameraList.count;j++){

var lcl = root.cameraList.get(j)
 var lcld = data.data[i]
         if( data.data[i].id===root.cameraList.get(j).id){

             //console.log("[PROFIT]")



            root.cameraList.get(j).liveStream=data.data[i].liveStream
            root.cameraList.get(j).storageStream=data.data[i].storageStream
            root.cameraList.get(j).snapshot=data.data[i].snapshot
            root.cameraList.get(j).intervals=data.data[i].intervals

         }

 }
}
 //root.update_intervals.updated()

     //console.log("videowall: ",data.videowall)
 root.frash_URL(data.videowall)

 root.update_intervals(data.data[i].intervals)

}



Axxon.prototype.receive_strorage_stream = function (data) {
root.log('[receive_strorage_stream]')
    root.log(data)
    root.log(JSON.stringify(data))

    root.stream_from_storage.clear()
      var i
      for (i in data) {
          root.log("------------------------------")
          root.log("id: ", data[i].id)
          root.log("Camera: ", data[i].name)
          root.log("URL: ",data[i].stream)
          root.log("telemetryControlID: ",data[i].telemetryControlID)
          root.log("serviceId: ",this.serviceId)
          root.stream_from_storage.append({
                                           id: data[i].id ,
                                           name: data[i].name ,
                                           point: data[i].point,
                                           telemetryControlID: data[i].telemetryControlID,
                                           serviceId: 666

                                          }
                                          )


      }




       root.stream_from_storage.updated()
}

function receive_preset_info(data) {

    root.log("receive_preset_info")
    root.log(data)

var i
     root.camera_presets.clear()
      for (i in data) {
  //  root.log(data[i].Id," ",data[i].Name)

    root.camera_presets.append({index: data[i].Id ,
                                name: data[i].Name,
                                }
                              )
      }

      root.camera_presets.updated()
}

Axxon.prototype.rebuildTree = function (data) {



    var i,
    list = [],
    model = this.model.children
    if (this.validateTree()) {
        this.update(data)
    }else{
              //console.log('Axxon',this.serviceId,': rebuild whole tree')
              //console.log(JSON.stringify(data))

              var current_sid=data[0].sid
        for(var j=0;j< root.cameraList.count;j++){

      //      //console.log("dev: ",root.cameraList.get(j).sid )

            if(root.cameraList.get(j).sid==current_sid)
            root.cameraList.get(j).actual=false



            //список айдишников сервисов
            var res=false
            for(var i=0;i<root.devices.get(0).children.count;i++){
              var scopeId=root.devices.get(0).children.get(i).scopeId
            ////console.log("i: ",scopeId)
                if(root.cameraList.get(j).sid==scopeId)
                    res=true

            }
            if(res==false)
              root.cameraList.get(j).actual=false

            //если айди сервиса устройства нет среди имеющихся
            //то оно не актуально. гони его насмехайся над ним.

        }

        for (i in data) {

          //  //console.log("У наc здесь пришла камера ",data[i].id," ",data[i].name," ",data[i].ipadress," от сервера ",data[i].sid)

            var state =data[i].state
            var color="gray"
            if(state=="lost")
                color="gold"
            if(state=="ok")
                color="green"
            if(state=="alarm")
                color="red"

            list.push({

                id: data[i].id,
                serviceId: this.serviceId,
                label: data[i].name,
                name: data[i].name,
                color: color,
                icon: 'fa_video',
                children: [],
                form: "axxon"

            })

            var mapState=data[i].state

            var res=true
            for(var j=0;j< root.cameraList.count;j++){


                if( data[i].id==root.cameraList.get(j).id)

                {

                 //   root.log("[УЖЕ ЕСТЬ]")
                    res=false

                    root.cameraList.get(j).actual=true
                    root.cameraList.get(j).name =data[i].name
                    root.cameraList.get(j).mapState =data[i].state
                    root.cameraList.get(j).color =data[i].color

                }

            }
            if(res){
           //     //console.log("ДОБАВЛЯЮ ", data[i].id)

                root.cameraList.append(    {
                    sid: data[i].sid ,
                    id: data[i].id ,
                    name: data[i].name ,
                    //     telemetryControlID: data[i].telemetryControlID,
                    serviceId: this.serviceId,
                    frash_snapshot:data[i].frash_snapshot,
                    color:color,
                    display:"",
                    tooltip:"",
                    mapState:mapState,
                    stickyState:false,
                    actual:true,

                    telemetryControlID: data[i].telemetryControlID,

                    liveStream:"",
                    storageStream: "",
                    snapshot: "",

                    intervals: data[i].Intervals,
                    ipadress: data[i].ipadress




                })
            }

        }

        for(j=0;j< root.cameraList.count;j++){

            root.log(j,".....",root.cameraList.get(j).name,"....",root.cameraList.get(j).actual)
            if(root.cameraList.get(j).actual==false){
              //console.log("УДАЛЯЮ ", root.cameraList.get(j).id)
            root.cameraList.remove(j)
            }
        }

        for(i=0;i<root.cameraList.count;i++){


            var x=root.cameraList.get(i)
            //    root.log(x.name,": stickyState: ",x.stickyState," mapState:",x.mapState)
            if(x.stickyState===false){
            //    root.log("Utils.updateMaps(x) ")
            Utils.updateMaps(x)
            }
        }

        root.log(" ")
        root.log("cameraList:")
        for(j=0;j< cameraList.count;j++){

           root.log(j," ",root.cameraList.get(j).id," ",root.cameraList.get(j).name)
        }
        root.log(" ")



        model.clear()
        model.append(list)
        //      root.devices.updated()
        root.cameraList.updated()
    }
}

Axxon.prototype.update = function (data) {
    root.log('Axxon: UPDATE')
    var maxRecords = 200
    for (var i in data) {
        var color = "gray"
    }
}

Axxon.prototype.validateTree = function (data) {
    root.log('Axxon: validateTree stub')
    return false
}

Axxon.prototype.listStates = function (deviceId) {



    return {1: "Покой", 2: "тревога"}

}

Axxon.prototype.listCommands = function (deviceId) {
    //очистить комбобокс
    //запрос списка команд у гланг сервера
    return {100: 'Пресет и отобразить', 101: 'Отобразить'}
}


Axxon.prototype.handler_for_Telemetry_capture_session = function (data) {

   // root.log("")
  //      root.log("[handler_for_Telemetry_capture_session]")
  //  root.log("")
 //   root.log(data)
 //   root.log(JSON.stringify(data))
    if(data>0)
    root.telemetryId=data
//     root.log(root.telemetryId)
//    root.log("")

}

function request_URL(videowall, cameraId, serviceId, dt, format_dt)
{


    var data={
        videowall: videowall,
    cameraId: cameraId,
    serviceId:serviceId ,
        dt:dt,
        format_dt:format_dt


        }

 console.log(" ")
     console.log("request_URL ")
     console.log(" ")
            cameraId+";"+dt+" "+format_dt
    console.log("data.videowall : ",data.videowall)
    console.log("data.cameraId : ",data.cameraId)
    console.log("data.serviceId : ",data.serviceId)
    console.log("data.dt       : ",data.dt)
    console.log("data.format_dt: ",data.format_dt)
 console.log(" ")
      root.send(serviceId, 'request_URL', data)

}

function tlmtr_cmd(data)
{
   //console.log("tlmtr_cmd: [",root.axxon_service_id,"] ",data)

     root.log("...this.serviceId ",root.axxon_service_id)
    root.send(root.axxon_service_id, 'Telemetry_command', data)
      root.log("...send")



}

function request_URL_for_globalDeviceId(cameraId, serviceId, dt)
{


    var data=cameraId+" "+dt
    root.log("data: ",data)
      root.send(serviceId, 'request_URL_for_globalDeviceId', data)

}

function request_intervals(cameraId,serviceId)
{
//root.log("request intrevals for camera id:",current_cameraId,"; service id: ",current_serviceId)
      root.send(serviceId, 'request_intervals', cameraId)
}

Axxon.prototype.checkSticky = function (event) {

root.log("event.event: ",event.event)
    root.log("stickyStates.indexOf(event.event): ",stickyStates.indexOf(event.event))
    return stickyStates.indexOf(event.event) >= 0


}

function check_id(id){

    for(var i=0;i<root.cameraList.count;i++){


        if(root.cameraList.get(i).id===id){
        return true
        }

    }
    return false

}

function get_cids(){
    var cids=[]
    for(var i=0;i<root.cameraList.count;i++){



     cids.push(root.cameraList.get(i).id)

    }
    return cids

}

function camera(id){
 //   root.log("...find camera... ",id)
    for(var i=0;i<root.cameraList.count;i++){
 //    root.log(root.cameraList.get(i).id)
    if(root.cameraList.get(i).id===id){
 //     root.log("PROFIT")
    return root.cameraList.get(i)
    }
    }
    return -1

}

function get_intervals(id){
 //   root.log("...find camera... ",id)
    for(var i=0;i<root.cameraList.count;i++){
 //    root.log(root.cameraList.get(i).id)
    if(root.cameraList.get(i).id===id){
      root.log("PROFIT")
        var lcl = root.cameraList.get(i)
    return root.cameraList.get(i).intervals
    }
    }
    return -1

}



function get_serviceId(){
return this.serviceId
}




