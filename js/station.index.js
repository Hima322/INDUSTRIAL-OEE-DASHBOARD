//alert toast function for notification 
const toast = txt =>

    Toastify({
        text: txt,
        duration: 3000,
        gravity: "bottom",
        position: "right",
        style: {
            background: 'gray'
        }
    }).showToast();


//function for check pc connected to station or not 
var station = localStorage.getItem("station")
var seat_data_id = 0
var build_ticket = ""
var fgpart = ""
var sequence_number = ""
var isValidBuildTicket = false
var model_details = {}
var task_list = []


$(document).ready(function () { 
    callStationInfo()
    $("#partImage").attr("src", `../image/task/${station}/1.jpg`)

    if (station == null) {
        $("#station_modal").css({ display: 'grid' });
    } else {
        $("#station_modal").css({ display: 'none' });
    }

    //function for check qr code validation or not  
    $("#build_ticket").keyup(function (e) {
        e.preventDefault();
        if (e.key == "Enter") {
            build_ticket = e.target.value
            fgpart = build_ticket.split("-")[0] + "-" + build_ticket.split("-")[1]
            sequence_numnber = build_ticket.split("-")[2]

            $.ajax({
                type: "POST",
                url: "index.aspx/IsQRValid",
                data: `{build_ticket : '${build_ticket}',station:'${station.split("-")[1]}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != 0) {
                        //matched build ticket code 
                        seat_data_id = res.d
                        isValidBuildTicket = true
                    } else {
                        $("#task_list_container tr:first").css({ background: "red", color: "white" }) 
                        $("#temp_build_ticket_data").text($("#build_ticket").val()) 
                        $("#build_ticket").val("") 
                        //this logic for animate text after some delay 
                        if (new Date().getSeconds() % 4 == 0) {
                            $("#temp_build_ticket_data").addClass("animate__tada")
                        } else {
                            $("#temp_build_ticket_data").removeClass("animate__tada")
                        }
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
    })
})

function intervalFunction() {
    getCurrentUser();
    if (isValidBuildTicket) {
        getModelAndTaskList();
        $("#LblSeqNumber").text(sequence_numnber)
    }

    task_list.map((e, i) => {
        if (i == 0) {
            //this code for scan build ticket only 
            if (task_list[0].TaskCurrentValue == "") {
                buildTicketExecuteTask(task_list[0].ID, build_ticket)
            }
        } else {
            if (e.TaskType == "Scan") {
                $("#qr_scan_modal").css({ opacity: 0, visibility: "hidden" })
            }
            //code for scan task type 
            if (e.TaskType == "Scan" && (e.TaskStatus == "Running" || e.TaskStatus == "Error")) {
                $("#qr_scan_modal").css({ opacity: 1, visibility: "visible" })
                $("#qr_scan_modal div input").focus()
                $("#qr_scan_modal div input").keyup(function (j) {
                    j.preventDefault();
                    if (j.key == "Enter") {
                        scanExecuteTask(e.ID, fgpart, e.BomSeq, j.target.value)
                    }
                })
            } else if (e.TaskType == "Torque" && (e.TaskStatus == "Running" || e.TaskStatus == "Error") && e.TaskCurrentValue != "") {
                torqueExecuteTask(e.ID, e.BomSeq, e.TaskCurrentValue)
            } else if (e.TaskType == "Read bit" && (e.TaskStatus == "Running" || e.TaskStatus == "Error") && e.TaskCurrentValue != "") {
                readBitExecuteTask(e.ID)
            } else if (!task_list.some(k => k.TaskCurrentValue == "")) {
                finishTask(station, model_details.Seat)
            }
        }
    })
}
 
setInterval(intervalFunction, 500);


//function for call station function for info
const callStationInfo = () => {
    $.ajax({
        type: "POST",
        url: "index.aspx/GetStationInfo",
        data: `{station : '${station}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            $("#station_name").text(res.d)
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}

//function for get current user 
const getCurrentUser = () => {
    $.ajax({
        type: "POST",
        url: "index.aspx/GetCurrentUser",
        data: `{station : '${station.split("-")[1]}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            if (res.d == "USER_NULL") {
                $("#auth_modal").css({ display: 'grid' })
            } else {
                $("#auth_modal").css({ display: 'none' })
                $("#current_user").text(res.d)
            }
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}

//function for get task list and model also
const getModelAndTaskList = () => {
    $.ajax({
        type: "POST",
        url: "index.aspx/GetModelAndTaskList",
        data: `{station:'${station}',fgpart:'${fgpart}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            if (res.d != null) {
                data = JSON.parse(res.d);
                model_details = JSON.parse(data.model);
                task_list = JSON.parse(data.taskList)

                //write inkside model details section 
                $("#LblCustName").text(data.customer)
                $("#LblModel").text(model_details.Model)
                $("#LblVariant").text(model_details.Variant)
                $("#LblFeature").text(model_details.Features)
                $("#LblSeatType").text(model_details.Seat)
                $("#LblDestination").text(model_details.Destination)
                $("#LblCustPartNumber").text(model_details.CustPartNumber)
                $("#LblFG_PartNumber").text(model_details.FG_PartNumber)
                $("#LblTaktTime").text(235)

                $("#LblVinNumber").text(model_details.VIN)

                //write inside task list container  
                $("#task_list_container").html(
                    task_list.map((e, i) =>
                        `<tr class="text-${e.TaskStatus == 'Pending' || e.TaskStatus == 'Running' ? 'dark' : 'white'}" 
                                        style="background:${e.TaskStatus == 'Pending' ? 'transparent' : e.TaskStatus == 'Running' ? 'yellow' : e.TaskStatus == 'Error' ? 'red' : 'green'};">
                                        <th>${i + 1}.</th> 
                                        <th>${e.TaskName}</th>
                                        <th>${e.TaskType}</th>
                                        <th class="animate__animated ${e.TaskStatus == 'Error' && new Date().getSeconds() % 4 == 0 ? 'animate__tada' : ''}">${e.TaskCurrentValue || "-"}</th>
                                        <th>${e.TaskStatus == 'Pending' ? "-" : e.TaskStatus == 'Running' || e.TaskStatus == 'Error' ? '<i class="spinner-grow spinner-grow-sm"></i>' : e.TaskStatus}</th>  
                                    </tr>
                              `))

                //chagne image during task change 
                task_list.map((e, i) => {
                    if (e.TaskStatus == "Running" || e.TaskStatus == "Error") {
                        $("#partImage").attr("src", `../image/task/${station}/${i}.jpg`)
                    }
                })
            }
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}

//function for build ticket execute task
const buildTicketExecuteTask = (id, value) => {
    $.ajax({
        type: "POST",
        url: "index.aspx/BuildTicketExecuteTask",
        data: `{id : '${id}',val:'${value}',seat_data_id : '${seat_data_id}',model:'${model_details.Model}',variant : '${model_details.Variant}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            //console.log(res.d)
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}


//function for scan execute task
const scanExecuteTask = (id, fg, bom_seq, val) => {
    $.ajax({
        type: "POST",
        url: "index.aspx/ScanExecuteTask",
        data: `{id : '${id}',fgpart : '${fg}',bom:'${bom_seq}',val:'${val}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            if (res.d == "Done") {
                $("#qr_scan_modal").css({ opacity: 0, visibility: "hidden" })
                $("#qr_scan_modal div input").val("")
            } else {
                $("#qr_scan_modal div input").val("")
                $("#qr_scan_modal").css({ opacity: 1, visibility: "visible" })
            }
        },
        Error: function (x, e) {
            console.log(e);
            $("#qr_scan_modal").css({ opacity: 0, visibility: "hidden" })
        }
    })
}


//function for torque execute task
const torqueExecuteTask = (id, torque_seq, val) => {
    $.ajax({
        type: "POST",
        url: "index.aspx/TorqueExecuteTask",
        data: `{id : '${id}',torque_seq:'${torque_seq}',val:'${val}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            console.log(res.d)
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}


//function for torque execute task
const readBitExecuteTask = (id) => {
    $.ajax({
        type: "POST",
        url: "index.aspx/ReadBitExecuteTask",
        data: `{id : '${id}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            console.log(res.d)
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}

//function for torque execute task
const finishTask = (station, seatType) => {
    $.ajax({
        type: "POST",
        url: "index.aspx/FinishTask",
        data: `{station : '${station}',seatType:'${seatType}'}`,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: "true",
        cache: "false",
        success: (res) => {
            if (res.d) {
                location.reload()
            }
        },
        Error: function (x, e) {
            console.log(e);
        }
    })
}
