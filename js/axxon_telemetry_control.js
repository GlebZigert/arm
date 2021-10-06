.import "utils.js" as Utils
.import "axxon.js" as Axxon



function capture_session(point,id)
{



if (root.storage_live=="live") root.send(id, 'Telemetry_capture_session', point)
}

function hold_session(id)
{
//    console.log("[hold_session]")
//      console.log("root.telemetryId: ",root.telemetryId)
//      console.log("root.telemetryPoint: ",root.telemetryPoint)
    var data=root.telemetryId+" "+root.telemetryPoint
//    console.log("id: ",id," data: ",data)
     if(root.telemetryId>0)
if (root.storage_live=="live") root.send(id, 'Telemetry_hold_session', data)
}



//-------
//"Telemetry_top_right" : svc.Telemetry_bottom,
//"Telemetry_top_left" : svc.Telemetry_top,
//"Telemetry_bottom_right" : svc.Telemetry_left,
//"Telemetry_bottom_left" : svc.Telemetry_right,


function move(_data,id)
{

 var data="Telemetry_move "+ root.telemetryPoint+" "+_data

    console.log(data)
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)
}


//-------


function stop_moving(id)
{
    console.log("stop_moving")

 var data="Telemetry_move "+ root.telemetryPoint+" "+"0 0 0"
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)
}

function zoom_in(id)
{

 var data="Telemetry_zoom_in "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)
}

function zoom_out(id)
{
    var data="Telemetry_zoom_out "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)


}


function stop_zoom(id)
{
    var data="Telemetry_stop_zoom "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)

}

//-----------------------------------------------------
function focus_in(id)
{

    var data="Telemetry_focus_in "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)

}

function focus_out(id)
{

    var data="Telemetry_focus_out "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)


}


function stop_focus(id)
{

    var data="Telemetry_stop_focus "+ root.telemetryPoint
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)


}
//-----------------------------------------------------

function preset_info(point,id)
{
   console.log("[preset_info] ")
    var data= "Telemetry_preset_info "+ root.telemetryPoint
    console.log("data: ",data)

if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)

}

function go_to_preset(value,id)
{
    console.log("[go_to_preset]")
    //console.log("id ",id)
      var data="Telemetry_go_to_preset "+ root.telemetryPoint+" "+value
if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)
}

function edit(ind,name,id)
{

    var data="Telemetry_edit_preset "+ root.telemetryPoint+" "+ind.toString()+" "+name
    //console.log("str: ",str)

if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)



}

function remove(value,id)
{

//console.log("Telemetry_remove_preset: ",value)
    var data="Telemetry_remove_preset "+ root.telemetryPoint+" "+" "+value
    //console.log("str: ",str)

if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)




}

function add(name,id)
{
//console.log("Telemetry_add_preset: ",name)
    var data= "Telemetry_add_preset "+root.telemetryPoint+" "+ name

if (root.storage_live=="live") root.send(id, 'Telemetry_command', data)


}

