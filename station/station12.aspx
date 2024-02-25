<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="station12.aspx.cs" Inherits="WebApplication2.station.Station12" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title> 
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="../css/libs/animate.css" />  
    <script src="../js/libs/sweetalert2.all.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script> 

        //function for check pc connected to station or not 
        var station = localStorage.getItem("station")
        var seat_data_id = 0
        var current_task_id = 0
        var inspection_task_list = []
        var inspection_task_id = new Set()
        var complete_inspection = new Set()
        var build_ticket = ""
        var fgpart = ""
        var plcStation = ""
        var sequence_number = ""
        var isValidBuildTicket = false 
        var user_details = {}
        var model_details = {}
        var task_list = [] 
        var bom_list = []
        var isBuiltTicketFunctionSucces = false 
         

        $(document).ready(function () {
            callStationInfo()
            getAllPlcTagList() 
            getInspectionTaskList() 
            $("#partImage").attr("src", `../image/task/${station}/1.jpg`)
            $("#inpection_task_list_modal").hide()
            $('input').attr('autocomplete', 'off');
             
            //checking if station is not inspection station then redirect index page 
            if (station != "Station-12") {
                location.href = "index.aspx"
            }  

            //function for check qr code validation or not  
            $("#build_ticket").keyup(function (e) {  

                if (e.key == "Enter") { 
                    //this is for indecate scannerbadge 
                    localStorage.setItem("1min", Date.now() + 60000)

                    build_ticket = e.target.value
                    fgpart = build_ticket.split("-")[0] + "-" + build_ticket.split("-")[1]
                    sequence_numnber = build_ticket.split("-")[2]

                    //LOGOUT FUNCTION FROM SCANNER 
                    if (e.target.value == "logout") {
                        return handleLogout();
                    }

                    //page reload function
                    if (e.target.value == "reload") {
                        return location.reload();
                    }

                    $.ajax({
                        type: "POST",
                        url: "station12.aspx/IsQRValid",
                        data: `{build_ticket : '${build_ticket}',station:'${station.split("-")[1]}', plcStation:'${plcStation}'}`,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: "true",
                        cache: "false",
                        success: (res) => {
                            if (res.d != 0) {
                                //matched build ticket code 
                                if (res.d == "Rejected") {
                                    return toast("Seat rejected.") && $("#build_ticket").val("")
                                }
                                if (res.d == "plcDiconnected") {
                                    return toast("Plc not connected.") && $("#build_ticket").val("")
                                }

                                seat_data_id = res.d
                                isValidBuildTicket = true 

                            } else {
                                $("#task_list_container tr:first").css({ background: "red", color: "white" })
                                $("#temp_build_ticket_data").text($("#build_ticket").val())
                                $("#temp_build_ticket_data").addClass("animate__tada")
                                $("#build_ticket").val("")
                            }
                        },
                        Error: function (x, e) {
                            console.log(e);
                        }
                    }) 
                    e.key = "k" 
                } 
            })
        })

        setInterval(function() {
            callStationInfo()
            getCurrentUser()
            isScannerConnected()
            isPlcConnected() 
        }, 1000) 

        setInterval(function () {  
            if(isValidBuildTicket) {
                getModelAndTaskList();
                handleTask()
                $("#LblSeqNumber").text(sequence_numnber)
            }
        }, 500); 

        function handleTask() { 

            task_list.forEach(e => {  

                if (e.ImageSeq == 1) { 
                    if (e.TaskCurrentValue == "" && !isBuiltTicketFunctionSucces) {
                        //this code for scan build ticket only   
                        buildTicketExecuteTask(e.ID, build_ticket) 
                    } 
                } else {

                if (e.TaskType == "Inspection") {
                    $("#inpection_task_list_modal").hide()
                } 

                    if (e.TaskType == "Inspection" && e.BomSeq == "VISUAL" && e.TaskCurrentValue == "" && (e.TaskStatus == "Running" || e.TaskStatus == "Error")) {
                        current_task_id = e.ID;
                        $("#inpection_task_list_modal").show()
                    } else if (e.TaskType == "Write bit" && e.TaskStatus == "Running" || e.TaskStatus == "Error") {
                        writeBitExecuteTask(e.ID) 
                    } else if (e.TaskType == "Read bit" && e.TaskStatus == "Running" && e.TaskCurrentValue == "") {
                        readBitExecuteTask(e.ID)
                    } else if (!task_list.some(k => k.TaskCurrentValue == "") && task_list.every(k => k.TaskStatus == "Done")) {
                        finishTask() 
                    }
                } 
            })
        }

        //function for write bit task
        const getAllPlcTagList = _ => {
            $.ajax({
                type: "POST",
                url: "station12.aspx/GetAllPlcTagList",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        let mes = data.find(e => e.PLCTagName == "MESStation")

                        let newMes = Object.fromEntries(
                            Object.entries(mes).map(
                                ([k, v]) => [v, k]
                            ))

                        let op = station.replace("Station-", "OP")

                        plcStation = newMes[op]

                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        //function for call station function for info
        const callStationInfo = () => {
            $.ajax({
                type: "POST",
                url: "station12.aspx/GetStationInfo",
                data: `{station : '${station}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $(".station_name").text(res.d)
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
                url: "station12.aspx/GetCurrentUser",
                data: `{station : '${station.split("-")[1]}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "USER_NULL") {
                        $("#auth_modal").css({ display: 'grid' })
                    } else {
                        user_details = JSON.parse(res.d)
                        $("#auth_modal").css({ display: 'none' })
                        $("#current_user").text(user_details.UserName)

                        //show database is connected in badge 
                        $("#database_badge").attr("class", "badge bg-success")
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
                url: "station12.aspx/GetModelAndTaskList",
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
                        bom_list = JSON.parse(data.bomList) 

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
                                        <th>${e.TaskType == "Inspection" ? e.BomSeq : e.TaskName}</th>
                                        <th>${e.TaskType}</th>
                                        <th >
                                            <span class="animate__animated ${e.TaskStatus == 'Error' && new Date().getSeconds() % 4 == 0 ? 'animate__tada' : ''}">${e.TaskCurrentValue || "-"}<span> 
                                        </th>
                                        <th>${e.TaskStatus == 'Pending' ? "-" : e.TaskStatus == 'Running' || e.TaskStatus == 'Error' ? '<i class="spinner-grow spinner-grow-sm"></i>' : e.TaskStatus}</th>  
                                    </tr> 
                              `))

                        //chagne image during task change 
                        task_list.map((e, i) => {
                            if (e.TaskStatus == "Running" || e.TaskStatus == "Error") {
                                $("#partImage").attr("src", `../image/task/${station}/${e.ImageSeq}.jpg`)
                            }
                        })
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        //function for get inpection task list 
        function getInspectionTaskList(){
            $.ajax({
                type: "POST",
                url: "station12.aspx/GET_INSPECTION_TASK_lIST",
                data: `{station : '${station}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Error") return toast("Something went wrong")  
                    let data = JSON.parse(res.d)  
                    inspection_task_list = data

                    $('#inspection_task_list_container').html(
                        data.map((e,i) => `
                          <tr style="height: 46px; font-size: 20px;">
                            <th>${i+1}.</th>
                            <th>${e.InspectionName}</th>
                            <th>${e.InspectionType}</th>
                            <th class="btn-group" role="group" aria-label="inspection-list">   
                                <input type="radio" class="btn-check" name="options-outlined${e.ID}" id="OK${i + 1}" onclick="inspection_task_id.delete(${e.ID}) || complete_inspection.add(${e.ID})" autocomplete="off" >
                                <label class="btn btn-outline-success btn-sm" for="OK${i + 1}" >OK</label>

                                <input type="radio" class="btn-check" name="options-outlined${e.ID}" id="NG${i + 1}" autocomplete="off" onclick="inspection_task_id.add(${e.ID}) && complete_inspection.add(${e.ID})" >
                                <label class="btn btn-outline-danger btn-sm" for="NG${i + 1}">NG</label>
                            </th>
                        </tr>
                        `)
                    );
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
                url: "station12.aspx/BuildTicketExecuteTask",
                data: `{id : '${id}',val:'${value}',seat_data_id : '${seat_data_id}', model_variant : '${model_details.ModelVariant}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Done") {
                        isBuiltTicketFunctionSucces = true
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        //function for inspection execute task
        const inspectionExecuteTask = () => {
            if (complete_inspection.size != inspection_task_list.length) return toast("Incomplete Inspection")
            $.ajax({
                type: "POST",
                url: "station12.aspx/InspectionExecuteTask",
                data: `{id : '${current_task_id}',insId: '${[...inspection_task_id].join()}', model_variant: '${model_details.ModelVariant}', operator_name : '${user_details.UserName}', built_ticket : '${build_ticket}',seat_id : '${seat_data_id}' }`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d == "Done") {
                        $("#inpection_task_list_modal").hide()
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }  

        //function for write bit task
        const writeBitExecuteTask = (id) => {
            $.ajax({
                type: "POST",
                url: "station12.aspx/WriteBitExecuteTask",
                data: `{id : '${id}', model_variant: '${model_details.ModelVariant}', plcStation:'${plcStation}'}`,
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

        //function for read bit task
        const readBitExecuteTask = (id) => {
            $.ajax({
                type: "POST",
                url: "station12.aspx/ReadBitExecuteTask",
                data: `{id : '${id}', plcStation: '${plcStation}'}`,
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
         
        //function for finish task
        const finishTask = () => {
            $.ajax({
                type: "POST",
                url: "station12.aspx/FinishTask",
                data: `{station : '${station}', seat_data_id : '${seat_data_id}'}`,
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
         
        function isPlcConnected() {
            $.ajax({
                type: "POST",
                url: "station12.aspx/IS_PLC_CONNECTED",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d) { 
                        $("#plc_badge").attr("class", "badge bg-success")
                    } else {
                        $("#plc_badge").attr("class", "badge bg-danger")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            }) 
        }

        //funtion for check scanner connected or not 
        function isScannerConnected() {
            if (localStorage.getItem("1min") > Date.now()) {
                //show scanner is connected in badge 
                $("#scanner_badge").attr("class", "badge bg-success")
            } else {
                $("#scanner_badge").attr("class", "badge bg-danger")
            }
        }

        //alert toast function for notification 
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 3000,
            width:"400px",
            background: "yellow",
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.onmouseenter = Swal.stopTimer;
                toast.onmouseleave = Swal.resumeTimer;
            }
        }); 

        const toast = (txt, icon = "error") =>
            Toast.fire({
                icon: icon,
                title: `<h4>${txt}</h4>`
            });


    </script>
    <style>
        input {
            opacity: 0;
        }

        #task_list_container tr {
            height: 46px;
            font-size: 20px;
        }
        
        #auth_modal {
            position: fixed;
            top: 0;
            left: 0;
            background: rgba(0,0,0,.7);
            width: 100%;
            height: 100vh;
            display: none;
            place-items: center;
            z-index: 9;
            backdrop-filter: blur(2px);
        }  
        #inpection_task_list_modal{
            position: absolute;
            top: 0;
            left: 0; 
            width: 100%;
            height: 100vh;
            display: flex;  
            align-items:start;
            z-index: 9;
            backdrop-filter: blur(0px);
        } 
    </style>
</head>
<body class="bg-light">

    <form id="form1" runat="server"> 

            <%--header navbar code--%>
            <div class="d-flex align-items-center justify-content-center">
                <div class="px-2">
                    <img src="../image/logo.png" alt="error" height="60" />
                </div>

                <div class="text-center bg-warning px-3 py-1" style="height: 60px;">
                    <b class="text-dark">TM SEATING
                        <br />
                        CHENNAI PLANT</b>
                </div>

                <div class="text-center bg-secondary text-light py-1 px-3" style="height: 60px;">
                    <b>LINE
                        <br />
                        FRONT ROW</b>
                </div>

                <div class="text-center bg-primary flex-grow-1 px-3 d-flex justify-content-between align-items-center" style="height: 60px;">
                    <big class="text-light">
                        <b class="station_name"></b>
                    </big>
                    <big class="text-light animate__animated animate__bounceInDown ">
                        
                        <img src="../image/icon/user.png" height="20" />
                        <b id="current_user"></b></big>
                </div>

                <div class="text-center bg-secondary px-3 py-1" style="height: 60px;">
                    <b class="text-light">STATION-1R-10
                        <br />
                        <span id="current_time"></span></b>
                </div>

                <div class="text-center px-3 py-1" style="height: 60px;">
                    <span class="badge bg-danger" id="database_badge">DATABASE</span>
                    <span class="badge bg-danger" id="plc_badge">PLC</span>
                    <br /> 
                    <span class="badge bg-danger" id="scanner_badge">SCANNER</span>
                </div>
            </div>

            <%--script to show current date--%>
            <script>
                $("#current_time").text(new Date().toISOString().split("T")[0]) 
            </script>

            <%--header content--%>
            <table class="table table-bordered text-center mb-0">
                <tr class="table-dark">
                    <th>CUSTOMER</th>
                    <th>MODEL</th>
                    <th>VARIANT</th>
                    <th>FEATURES</th>
                    <th>SEAT TYPE</th>
                    <th>DESTINATION</th>
                    <th>TM FG PART NUMBER</th>
                    <th>CUS FG PART NUMBER</th>
                    <th>TAKT TIME (sec) </th>
                </tr>
                <tr class="table-secondary">
                    <th>
                        <h5 id="LblCustName"></h5>
                    </th>
                    <th>
                        <h5 id="LblModel"></h5>
                    </th>
                    <th>
                        <h5 id="LblVariant"></h5>
                    </th>
                    <th>
                        <h5 id="LblFeature"></h5>
                    </th>
                    <th>
                        <h5 id="LblSeatType" class="text-primary"></h5>
                    </th>
                    <th>
                        <h5 id="LblDestination"></h5>
                    </th>
                    <th>
                        <h5 id="LblFG_PartNumber"></h5>
                    </th>
                    <th>
                        <h5 id="LblCustPartNumber"></h5>
                    </th>
                    <th>
                        <h5 id="LblTaktTime">&nbsp;</h5>
                    </th>
                </tr>
            </table>

            <%--main body content--%>
            <div class="d-flex align-items-start">
                <%--left side details and image--%>
                <div>
                    <table class="table table-border text-center mb-0">
                        <tr>
                            <th class="table-dark">VIN NO</th>
                            <th class="table-secondary">
                                <h5 id="LblVinNumber"></h5>
                            </th>
                        </tr>
                        <tr>
                            <th class="table-dark">SEQ NO</th>
                            <th class="table-secondary">
                                <h5 id="LblSeqNumber"></h5>
                            </th>
                        </tr>
                    </table>

                    <img id="partImage" src="../image/invalid.jpg" alt="error" width="350" />

                </div>

                <%--right side details--%>
                <table class="flex-grow-1 text-center mb-0">
                    <thead>
                        <tr class="text-white" style="height: 46px; font-size: 20px; background: #212529;">
                            <th>SEQ</th>
                            <th>STEP</th>
                            <th>TASK TYPE</th>
                            <th>VALUE</th>
                            <th>STATUS</th>
                        </tr>
                    </thead>

                    <tbody id="task_list_container">
                        <%-- code will be come via ajax --%>
                        <tr style="background: yellow;">
                            <th>1.</th>
                            <th>Scan Build Ticket</th>
                            <th>Scan</th>
                            <th style="animation-iteration-count: 2; animation-delay: 2s;" class="animate__animated " id="temp_build_ticket_data">
                                <img src="/image/scaning.gif" height="30" />
                            </th>
                            <th><i class="spinner-grow spinner-grow-sm "></i></th>
                        </tr>
                        <tr>
                            <td colspan="5">
                                <asp:TextBox ID="build_ticket" runat="server" AutoPostBack="true" CssClass="form-control m-auto my-4" Onchange="return" Width="300"></asp:TextBox>
                                <script>
                                    //this is call to input focus continue
                                    setInterval(function () { $("#build_ticket").focus() }, 500)
                                </script>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
         
            <%--models for notification--%>
            <div id="modal_container"> 

                <%--code for assign station on local storage--%>
                <div id="inpection_task_list_modal">
                    <div class="bg-light ms-auto" style="width:calc(100% - 350px);margin-top:289px;background:rgb(250, 250, 250) !important;" > 
                         <table class="flex-grow-1 text-center w-100" >
                             <thead>
                                 <tr class="text-white" style="height: 46px; font-size: 20px; background: #212529;">
                                     <th>SEQ</th> 
                                     <th>INSPECTION NAME</th> 
                                     <th>INSPECTION TYPE</th> 
                                     <th>STATUS</th>
                                 </tr>
                             </thead>

                             <tbody id="inspection_task_list_container">
                                 <%-- code will be come via ajax --%> 
                             </tbody>
                         </table>
                        
                        <%--<button class="btn btn-primary d-block m-auto mt-3" type="button" onclick="inspectionExecuteTask()" >SAVE &amp; CONTINUE</button>--%>
                        
                        <input type="text" id="statusInput" />
                        <script>
                            setInterval(function () {
                                $("#statusInput").focus()
                            }, 500)

                            $("#statusInput").keyup(e => { 
                                if (e.key == "Enter") {
                                    if (e.target.value == "SAVE") {
                                        $("#statusInput").val("")
                                        return inspectionExecuteTask()
                                    }
                                    $(`#${e.target.value}`).click()
                                    $("#statusInput").val("")
                                } 
                            })
                        </script>
                    
                    
                    </div>
                </div>

                <%--code to check user is login or not--%>
                <div id="auth_modal">
                    <div class="p-5 bg-light shadow rounded" style="width: 500px;">
                        <h1 class="text-danger">User Unavailable. </h1>
                        <h4>At <big class="station_name"></big></h4>

                        <div class="my-4 d-flex justify-content-center">
                            <img src="/image/scaning.gif" height="50" class="mt-auto" />
                            <img src="/image/login.png" width="100" />
                            <i class="spinner-grow bg-info"></i>
                        </div>
                         
                        <asp:TextBox ID="user_login_id" runat="server" AutoPostBack="true" CssClass="form-control m-auto" Onchange="return" Width="300"></asp:TextBox> 
                        <button type="button" class="btn btn-danger" onclick="localStorage.removeItem('station') || location.reload()">Reset Station</button>
                    </div>

                    <script> 
                        $("#user_login_id").on("keyup", function (e) {
                            e.preventDefault()

                            //this is for indecate scannerbadge 
                            localStorage.setItem("1min", Date.now() + 60000)

                            var user_login_id = $(this).val()
                            if (e.key == "Enter") {
                                $.ajax({
                                    type: "POST",
                                    url: "station12.aspx/UserLogin",
                                    data: `{ Userid: '${user_login_id}',Station: '${station.split("-")[1]}'}`,
                                    contentType: "application/json; charset=utf-8",
                                    dataType: "json",
                                    async: "true",
                                    cache: "false",
                                    success: function (res) {
                                        toast(res.d)
                                        console.log(res.d)
                                        if (res.d == "success") { location.reload() }
                                        $("#user_login_id").val("")
                                    },
                                    Error: function (x, e) {
                                        console.log(e);
                                    }
                                });
                            }

                        })

                        //this is call to input focus continue 
                        setInterval(function () { $("#user_login_id").focus() }, 500)

                        //logout function this is call bellow 
                        function handleLogout() {
                            $.ajax({
                                type: "POST",
                                url: "station12.aspx/UserLogout",
                                data: `{ Userid: '${user_details.UserID}',Station: '${station.split("-")[1]}'}`,
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                async: "true",
                                cache: "false",
                                success: function (res) {
                                    if (res.d == "success") { location.reload() }
                                    toast(res.d)
                                },
                                Error: function (x, e) {
                                    console.log(e);
                                }
                            });
                        }

                    </script>

                </div> 

            <%--dropdown for setting--%>
            <div style="position: fixed; bottom: 0; right: 0; margin: 30px;">
                <div class="dropdown shadow rounded">
                    <button type="button" class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown">
                        <img src="../image/icon/tools.svg" height="20" />
                    </button>
                    <div class="dropdown-menu">
                        <button type="button" class="dropdown-item" onclick="localStorage.removeItem('station') || location.reload()">Reset Station</button>
                        <button type="button" class="dropdown-item text-danger" onclick="handleLogout()">Logout</button>
                    </div>
                </div>
            </div>

        </div> 
         
    </form>
</body>
</html>
