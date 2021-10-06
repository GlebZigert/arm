.import "utils.js" as Utils
.import "journal.js" as Journal
.import "constants.js" as Constants
function Axxon(model) {
    this.model = model
    this.serviceId = this.model.serviceId
    this.statusUpdate()

    this.handlers = {
        ListDevices: this.rebuildTree.bind(this),
        UpdateDevices: this.update.bind(this),
        StatusUpdate: this.statusUpdate.bind(this),
        DateTime: this.receive_strorage_stream.bind(this),
   //     Telemetry_preset_info: this.receive_preset_info.bind(this),
   //     Telemetry_edit_preset: this.receive_preset_info.bind(this),
   //     Telemetry_remove_preset: this.receive_preset_info.bind(this),
   //     Telemetry_add_preset: this.receive_preset_info.bind(this),
        request_URL: this.receive_URL.bind(this),
        ExecCommand: this.Broadcast.bind(this),
        request_intervals:  this.request_intervals_handler.bind(this),
        Telemetry_capture_session:  this.handler_for_Telemetry_capture_session.bind(this),
        Telemetry_command:  this.handler_Telemetry_command.bind(this),
        Axxon_Event: this.Axxon_event_handler.bind(this),
        Events: this.processEvents.bind(this)
    }
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

console.log("Axxon Events", JSON.stringify(events))
    // [{"fromState":0,"state":1004,"data":"","text":"Удал.ком. Открыть","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"},{"fromState":0,"state":111,"data":"","text":"Открыто","deviceId":1,"userId":0,"time":"2021-05-25T10:08:05Z"}]
var item,
sType

for (var i = 0; i < events.length; i++) {

    className = Utils.className(events[i].class)
    console.log("className: ",className)

    if(className==='alarm'){


        var str=events[i].commands
        console.log('event.commands', str)
        str=str.replace(/(\[)/g, "")
        console.log('event.commands', str)
        str=str.replace(/(\])/g,"")
        console.log('event.commands', str)
        var arr=str.split(",",4)
        var serviceId=arr[0]
        var globalDeviceId=events[i].deviceId
        var cameraId="";


        console.log("DeviceId: ",globalDeviceId)

        for(var j=0;j<root.rtsp_stream_url.count;j++){

            console.log("DeviceId: ",globalDeviceId," root.rtsp_stream_url[i].axxon_id: ",root.rtsp_stream_url.get(j).id)
            if(globalDeviceId==root.rtsp_stream_url.get(j).id){

                console.log("[PROFIT]")
                root.rtsp_stream_url.get(j).mapState="alarm"
                root.rtsp_stream_url.get(j).color="red"
                root.rtsp_stream_url.get(j).display="blink"
                             //   root.rtsp_stream_url.get(j).stickyState = true
                root.rtsp_stream_url.get(j).stickyState=true

                var x=root.rtsp_stream_url.get(j)


                Utils.updateMaps(x)


            }
        }

        root.playAlarm(className)


    }

     if((className==='ok')||(className==='lost')){

         var str=events[i].commands
         console.log('event.commands', str)
         str=str.replace(/(\[)/g, "")
         console.log('event.commands', str)
         str=str.replace(/(\])/g,"")
         console.log('event.commands', str)
         var arr=str.split(",",4)
         var serviceId=arr[0]
         var globalDeviceId=events[i].deviceId
         var cameraId="";


         console.log("DeviceId: ",globalDeviceId)

         for(var j=0;j<root.rtsp_stream_url.count;j++){

             console.log("DeviceId: ",globalDeviceId," root.rtsp_stream_url[i].axxon_id: ",root.rtsp_stream_url.get(j).id)
             if(globalDeviceId==root.rtsp_stream_url.get(j).id){

                 console.log("[PROFIT !!!]")

            //     root.rtsp_stream_url.get(j).stickyState=false
                 root.rtsp_stream_url.get(j).mapState=data[i].State
                 root.rtsp_stream_url.get(j).display="flash"
                 var x=root.rtsp_stream_url.get(j)

                 if(x.stickyState==false)
                 Utils.updateMaps(x)


             }
         }

     }

    if(className==='info'){

        if(events[i].text==='Сброс тревог'){

            var str=events[i].commands
            console.log('event.commands', str)
            str=str.replace(/(\[)/g, "")
            console.log('event.commands', str)
            str=str.replace(/(\])/g,"")
            console.log('event.commands', str)
            var arr=str.split(",",4)
            var serviceId=arr[0]
            var globalDeviceId=events[i].deviceId
            var cameraId="";


            console.log("DeviceId: ",globalDeviceId)

            for(var j=0;j<root.rtsp_stream_url.count;j++){

                console.log("DeviceId: ",globalDeviceId," root.rtsp_stream_url[i].axxon_id: ",root.rtsp_stream_url.get(j).id)
                if(globalDeviceId==root.rtsp_stream_url.get(j).id){

                    console.log("[PROFIT !!!]")

                    root.rtsp_stream_url.get(j).stickyState=false

                    root.rtsp_stream_url.get(j).display=""
                    var x=root.rtsp_stream_url.get(j)


                    Utils.updateMaps(x)


                }
            }



        }



    }


}

Journal.logEvents(events)

}
//Axxon.prototype.get_service_id = function(){
function get_service_id() {
console.log("[get_service_id()] ",Axxon.serviceId)
 console.log("[get_service_id()] ",this.serviceId)
}

Axxon.prototype.Axxon_event_handler = function (data)
{
    console.log("[Axxon_event_handler]")
 //   console.log(data)
 //   console.log(data.objects)
 //   console.log(data.objects[0])
 //   console.log(data.objects[0].name)
 //   console.log(data.objects[0].state)
    console.log(JSON.stringify(data))
 //   console.log(root.devices)

    for (var i in data.objects) {
     console.log('---')
console.log(data.objects[i])
     console.log(data.objects[i].name," ",data.objects[i].state)

        var point=data.objects[i].name.replace("hosts/","")
        var state=data.objects[i].state
        if(data.objects[i].type=="devicestatechanged")
        for(var j=0;j<root.rtsp_stream_url.count;j++)
        {
          var x=root.rtsp_stream_url.get(j)
            console.log(x.point)
            if(x.point==point)
            {
            console.log("PROFIT !!!")
                var id=x.id
            console.log("x.id: ",id)
            console.log("this.serviceId: ",this.serviceId)
                var device=Utils.findItem(root.devices,id)
            console.log("device.name: ",device.name)

                var color="gray"
                if(state=="signal lost")
                    color="red"
                if(state=="signal restored")
                    color="green"
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
    console.log(this.model.type, this.model.id, 'shutdown')
}

Axxon.prototype.datetime = function()
{

      root.send(this.serviceId, 'DateTime', '12345')
}


function dt(value)
{
    console.log(slider.value)
    value=slider.value
     var hours=Math.floor(value/3600)
     var min=Math.floor((value-hours*3600)/60)
     var sec=((value-hours*3600)-min*60)
     console.log("часы ",hours)
     console.log("мин ",min)
     console.log("сек ",sec)

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


   // console.log('hello_world')
    return url_array//"hosts/ASTRAAXXON/DeviceIpint.2/SourceEndpoint.video:0:1"

}

function  get_wigth(len, size, count) {

     console.log("len: ",len)
     console.log("size: ",size)
         console.log("count: ",count)
    console.log("Math.floor(len/size) ",Math.floor(len/size))


    if(Math.floor(len/size)<count)
    return size*Math.floor(len/size);
    else
    return count*size

}

Axxon.prototype.handler_Telemetry_command = function (data) {

    console.log("[handler_Telemetry_command]")
    console.log(data)
    console.log(JSON.stringify(data))
    console.log("data.Name: ",data.name)

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

    console.log("data.data: ",data.data)
    console.log("data.data.name: ",data.data.name)
    console.log("data.data.surename: ",data.data.surename)

     root.another_user.clear()

      str="Управление забрал "+data.data.name+" "+data.data.surename
    root.another_user.append({message: str})

   root.another_user.updated()

    break


    }

}



Axxon.prototype.statusUpdate = function (data) {
    this.model.status = data || this.model.status
    this.model.color = Utils.serviceColor(this.model.status)
    root.send(this.serviceId, 'ListDevices', '')
}

function getListDevices()
{
    console.log("")
    console.log("[getListDevices]")
    console.log("")
  root.send(this.serviceId, 'ListDevices', '')
}

Axxon.prototype.request_intervals_handler = function (data) {

    /*
    console.log("")
    console.log("[request_intervals_handler]")
    console.log("")
 //  console.log(data)
 //  console.log(JSON.stringify(data))
*/
    var i
    for (i in data) {
//     console.log("id: ", data[i].id)
//     console.log("liveStream: ", data[i].liveStream)
//     console.log("storageStream: ", data[i].storageStream)
//     console.log("snapshot: ", data[i].snapshot)
    //    console.log("intervals: ", data[i].intervals.intervals[0].begin)


        root.update_intervals.clear()
         //              console.log("root.current_camera.length ",root.current_camera.count)
       root.update_intervals.append({

                                 m_intervals: data[i].intervals

                   })

}

root.update_intervals.updated()

    //---------



}

Axxon.prototype.Broadcast = function (data) {
root.camera_to_livestream.clear()
     console.log("")
     console.log("[BROADCAST]")
     console.log("")
    console.log(data)
    console.log(JSON.stringify(data))

    console.log("id",data[0].id)
    console.log("telemetryControlID",data[0].telemetryControlID)
    root.camera_to_livestream.append({id: data[0].id})

     console.log("camera_to_livestream.count: ",camera_to_livestream.count)
    if(camera_to_livestream.count>0)
     console.log("id",camera_to_livestream.get(0).id)



    console.log("------------------------------------")
    console.log("")

    console.log("data[0].intervals ",data[0].intervals)
    console.log("")
    console.log("------------------------------------")

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

}


Axxon.prototype.receive_URL = function (data) {

     console.log("")
         console.log("[receive_URL]")
     console.log("")

         console.log(data)
         console.log(JSON.stringify(data))
          console.log(JSON.stringify(data))
     var i
     for (i in data) {
      console.log("id: ", data[i].id)
      console.log("liveStream: ", data[i].liveStream)
      console.log("storageStream: ", data[i].storageStream)
      console.log("snapshot: ", data[i].snapshot)
    //  console.log("intervals: ", data[i].intervals.intervals[0].begin)


         root.current_camera.clear()
                        console.log("root.current_camera.length ",root.current_camera.count)
        root.current_camera.append({
                                     id: data[i].id ,
                                     liveStream : data[i].liveStream ,
                                   storageStream : data[i].storageStream,
                                  snapshot  : data[i].snapshot,
                                  intervals: data[i].intervals

                    })

 /*
              console.log("id: ", data[i].id," ... ",root.current_camera[i].id)
              console.log("liveStream: ", data[i].liveStream," ... ",root.current_camera[i].liveStream)
              console.log("storageStream: ", data[i].storageStream," ... ",root.current_camera[i].storageStream)
              console.log("snapshot: ", data[i].snapshot," ... ",root.current_camera[i].snapshot)
                 console.log("intervals: ", data[i].intervals.intervals[0].begin," ... ",root.current_camera[i].intervals.intervals[0].begin)

 */

          //      console.log("root.current_camera.length ",root.current_camera.count)

    //   console.log("data[0].intervals ",data[0].intervals.intervals)

    //     console.log("кол-во интервалов: ",data[0].intervals.intervals.length)
/*
         var i
         for(i in data[0].intervals.intervals)
         {
       console.log("-- интервал ",i)
       console.log("begin ",data[0].intervals.intervals[i].begin)
        console.log("end ",data[0].intervals.intervals[i].end)
         }
*/




     }
//     console.log("=======================")

 /*
     if(root.current_camera.count>0)
       for(i in root.current_camera[0].m_intervals.intervals)
       {
     console.log("-- интервал ",i)
     console.log("begin ",root.current_camera[0].m_intervals.intervals[i].begin)
      console.log("end ",root.current_camera[0].m_intervals.intervals[i].end)
       }
 */

     for (i in data) {
 //     console.log("id: ", data[i].id)
 //     console.log("liveStream: ", data[i].liveStream)
 //     console.log("storageStream: ", data[i].storageStream)
 //     console.log("snapshot: ", data[i].snapshot)
     //    console.log("intervals: ", data[i].intervals.intervals[0].begin)


         root.update_intervals.clear()
          //              console.log("root.current_camera.length ",root.current_camera.count)
        root.update_intervals.append({

                                  m_intervals: data[i].intervals

                    })

 }

 root.update_intervals.updated()

     root.current_camera.updated()
}

Axxon.prototype.receive_strorage_stream = function (data) {
console.log('[receive_strorage_stream]')
    console.log(data)
    console.log(JSON.stringify(data))

    root.stream_from_storage.clear()
      var i
      for (i in data) {
          console.log("------------------------------")
          console.log("id: ", data[i].id)
          console.log("Camera: ", data[i].name)
          console.log("URL: ",data[i].stream)
          console.log("telemetryControlID: ",data[i].telemetryControlID)
          console.log("serviceId: ",this.serviceId)
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

    console.log("receive_preset_info")
    console.log(data)

var i
     root.camera_presets.clear()
      for (i in data) {
    console.log(data[i].Id," ",data[i].Name)

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
    } else {
        console.log('Axxon: rebuild whole tree')
        console.log(JSON.stringify(data))
    //    root.rtsp_stream_url.clear()

      //  for(x=0;x<20;x++)
        for (i in data) {
         console.log('---')
         console.log(data[i].id)
         console.log(data[i].name)
         console.log(data[i].stream.Accesspoint[0].Rtsp)
         console.log(data[i].Snapshot)
         console.log(data[i].State)
         console.log("accessMode: ",data[i].accessMode)
            var state =data[i].State
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


        var mapState=data[i].State

        var res=true
        for(var j=0;j< root.rtsp_stream_url.count;j++){

            if( data[i].id==root.rtsp_stream_url.get(j).id){
            console.log("[УЖЕ ЕСТЬ]")
            res=false


//обновляем все кроме alarm и дисплей - с ними надо сделать посложнее.
              //  root.rtsp_stream_url.get(j).id =data[i].id
                root.rtsp_stream_url.get(j).axxon_id =data[i].cameraId
                root.rtsp_stream_url.get(j).name =data[i].name
                root.rtsp_stream_url.get(j).point =data[i].stream.Accesspoint[0].Accesspoint
                root.rtsp_stream_url.get(j).url =data[i].stream.Accesspoint[0].Rtsp
               root.rtsp_stream_url.get(j).telemetryControlID =data[i].telemetryControlID
               // root.rtsp_stream_url.get(j).serviceId =data[i].serviceId
                root.rtsp_stream_url.get(j).Snapshot =data[i].Snapshot


                root.rtsp_stream_url.get(j).mapState =data[i].State

                root.rtsp_stream_url.get(j).color =data[i].color

            //    root.rtsp_stream_url.get(j).display="blink"


                console.log(data[i].State," ",root.rtsp_stream_url.get(j).mapState)
            }

        }
        if(res){
             console.log("[ДОБАВЛЯЮ]")
            root.rtsp_stream_url.append(    {
                                            id: data[i].id ,
                                            axxon_id: data[i].cameraId ,
                                            name: data[i].name ,
                                        //    name: x+i,
                                            point:data[i].stream.Accesspoint[0].Accesspoint,
                                            url:data[i].stream.Accesspoint[0].Rtsp,
                                            telemetryControlID: data[i].telemetryControlID,
                                            serviceId: this.serviceId,
                                            Snapshot:data[i].Snapshot,
                                            color:color,
                                            display:"",
                                            tooltip:"",
                                            mapState:mapState,
                                            stickyState:false
                                            })
        }






  //      }


        }

        for(i=0;i<root.rtsp_stream_url.count;i++)
        {
        console.log(root.rtsp_stream_url.get(i).name)

            var x=root.rtsp_stream_url.get(i)


            console.log(x.name,": stickyState: ",x.stickyState," mapState:",x.mapState)
            if(x.stickyState===false){
              console.log("Utils.updateMaps(x) ")
            Utils.updateMaps(x)
            }

        }

        model.clear()
        model.append(list)
  //      root.devices.updated()
        root.rtsp_stream_url.updated()
    }
}

Axxon.prototype.update = function (data) {
    console.log('Axxon: UPDATE')
    var maxRecords = 200
    for (var i in data) {
        var color = "gray"
    }
}

Axxon.prototype.validateTree = function (data) {
    console.log('Axxon: validateTree stub')
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

    console.log("")
        console.log("[handler_for_Telemetry_capture_session]")
    console.log("")
    console.log(data)
    console.log(JSON.stringify(data))
    if(data>0)
    root.telemetryId=data
//     console.log(root.telemetryId)
//    console.log("")

}

function request_URL(cameraId, serviceId, dt, format_dt)
{
    console.log("")
    console.log("")
    console.log("")
        console.log("[request_URL]")
    console.log("")
    console.log("")
    console.log("")

    var data={
    cameraId: cameraId,
    serviceId:serviceId ,
        dt:dt,
        format_dt:format_dt


        }

      //      cameraId+";"+dt+" "+format_dt
    console.log("data.cameraId : ",data.cameraId)
    console.log("data.serviceId : ",data.serviceId)
    console.log("data.dt       : ",data.dt)
    console.log("data.format_dt: ",data.format_dt)

      root.send(serviceId, 'request_URL', data)

}

function request_URL_for_globalDeviceId(cameraId, serviceId, dt)
{


    var data=cameraId+" "+dt
    console.log("data: ",data)
      root.send(serviceId, 'request_URL_for_globalDeviceId', data)

}

function request_intervals(cameraId,serviceId)
{
//console.log("request intrevals for camera id:",current_cameraId,"; service id: ",current_serviceId)
      root.send(serviceId, 'request_intervals', cameraId)
}

Axxon.prototype.checkSticky = function (event) {

console.log("event.event: ",event.event)
    console.log("stickyStates.indexOf(event.event): ",stickyStates.indexOf(event.event))
    return stickyStates.indexOf(event.event) >= 0


}


