.import "utils.js" as Utils
.import "axxon.js" as Axxon



function capture_session(point)
{



if (root.storage_live=="live") root.send(Axxon.get_serviceId(), 'Telemetry_capture_session', point)
}

function hold_session()
{
//    console.log("[hold_session]")
//      console.log("root.telemetryId: ",root.telemetryId)
//      console.log("root.telemetryPoint: ",root.telemetryPoint)
    var data=root.telemetryId+" "+root.telemetryPoint
//    console.log("id: ",id," data: ",data)
     if(root.telemetryId>0)
    Axxon.tlmtr_cmd(data)
}



//-------
//"Telemetry_top_right" : svc.Telemetry_bottom,
//"Telemetry_top_left" : svc.Telemetry_top,
//"Telemetry_bottom_right" : svc.Telemetry_left,
//"Telemetry_bottom_left" : svc.Telemetry_right,


function move(_data)
{
    console.log("Telemetry_move")

 var data="Telemetry_move "+ root.telemetryPoint+" "+_data
console.log("Axxon.get_serviceId() ", Axxon.get_serviceId())

    console.log(data)
    Axxon.tlmtr_cmd(data)
}


//-------


function stop_moving()
{
    console.log("stop_moving")

 var data="Telemetry_move "+ root.telemetryPoint+" "+"0 0 0"
    Axxon.tlmtr_cmd(data)
}

function zoom_in()
{

 var data="Telemetry_zoom_in "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)
}

function zoom_out()
{
    var data="Telemetry_zoom_out "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)


}


function stop_zoom()
{
    var data="Telemetry_stop_zoom "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)

}

//-----------------------------------------------------
function focus_in()
{

    var data="Telemetry_focus_in "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)

}

function focus_out()
{

    var data="Telemetry_focus_out "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)


}


function stop_focus()
{

    var data="Telemetry_stop_focus "+ root.telemetryPoint
    Axxon.tlmtr_cmd(data)


}
//-----------------------------------------------------

function preset_info(point)
{
   console.log("[preset_info] ")
    var data= "Telemetry_preset_info "+ root.telemetryPoint
    console.log("data: ",data)

    Axxon.tlmtr_cmd(data)

}

function go_to_preset(value)
{
    console.log("[go_to_preset]")
    //console.log("id ",id)
      var data="Telemetry_go_to_preset "+ root.telemetryPoint+" "+value
    Axxon.tlmtr_cmd(data)
}

function edit(ind,name)
{

    var data="Telemetry_edit_preset "+ root.telemetryPoint+" "+ind.toString()+" "+name
    //console.log("str: ",str)

    Axxon.tlmtr_cmd(data)



}

function remove(value)
{

//console.log("Telemetry_remove_preset: ",value)
    var data="Telemetry_remove_preset "+ root.telemetryPoint+" "+" "+value
    //console.log("str: ",str)

    Axxon.tlmtr_cmd(data)




}

function add(name)
{
//console.log("Telemetry_add_preset: ",name)
    var data= "Telemetry_add_preset "+root.telemetryPoint+" "+ name

    Axxon.tlmtr_cmd(data)


}

