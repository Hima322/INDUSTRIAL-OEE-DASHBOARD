<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="station16.aspx.cs" Inherits="WebApplication2.station.Station16" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title> 
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="../css/libs/animate.css" />  
    <script src="../js/libs/sweetalert2.all.min.js"></script>
    <script type="text/javascript" src="../js/libs/moment.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script> 

        //function for check pc connected to station or not 
        var station = localStorage.getItem("station") 
        var inspection_task_id = new Set()
        var build_ticket = "" 
        var fgpart = "" 
        var user_details = {}  
        var bom_list = []
        var torque_list = []
        var filter_torque_task = []  
        var seatId = 0;
        var torqueType = ""
        var torqueAttempt = 0
         

        $(document).ready(function () { 
            callStationInfo()
            $("#inpection_task_list_container").hide()
            $("#torque_list_show_table").hide()
            $("#scanImg").hide()
            $("#rightScanImg").hide()
            $("#partImage").attr("src", `../image/task/${station}/1.jpg`)
            $('input').attr('autocomplete', 'off') 
             
            //checking if station is not inspection station then redirect index page 
            if (station != "Station-16") {
                location.href = "index.aspx"
            }  

            //function for check qr code validation or not  
            $("#build_ticket").keyup(function (e) {  

                if (e.key == "Enter") { 
                    //this is for indecate scannerbadge 
                    localStorage.setItem("1min", Date.now() + (1000 * 60 * 5)) 

                    //LOGOUT FUNCTION FROM SCANNER 
                    if (e.target.value == "logout") {
                        return handleLogout();
                    }

                    //page reload function
                    if (e.target.value == "reload") {
                        return location.reload();
                    }

                    build_ticket = e.target.value
                    fgpart = build_ticket.split("-")[0] + "-" + build_ticket.split("-")[1]

                    $.ajax({
                        type: "POST",
                        url: "station16.aspx/IsQRValid",
                        data: `{build_ticket : '${build_ticket}'}`,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: "true",
                        cache: "false",
                        success: (res) => { 
                            if (res.d == "Rejected") return toast("Seat Rejected.") && $("#build_ticket").val("")

                            if (res.d == "plcDiconnected") {
                                return toast("Plc not connected.") && $("#build_ticket").val("")
                            }

                            if (res.d != "Error") {
                                const data = JSON.parse(res.d)
                                seatId = data[0].SeatID
                                getBomList()
                                getTorqueGroupList() 

                                $("#task_list_container").html(`
                                    <tr style="background: green;color:white;">
                                        <th>1.</th>
                                        <th>Scan Build Ticket</th>
                                        <th>Scan</th>
                                        <th>${build_ticket}</th>
                                        <th>Done</th>
                                    </tr>
                                `)
                                 
                                $("#inpection_task_list_container").show()

                                $('#inpection_task_list_container').prepend(
                                    data.map((e, i) => `
                                         <div class="card" id="card${e.ID}" style="min-width:200px;max-width:500px;background:red;">
                                            <div class="card-body text-light">
                                                <h5 class="card-title">${e.InspectionName}</h5> 
                                                <div>
                                                    <b class="badge bg-warning text-dark">${e.InspectionType}</b> 
                                                    <b class="badge text-dark bg-warning">${moment(e.InspectionDateTime).fromNow().toUpperCase()}</b> 
                                                    <b class="badge bg-warning text-dark">${e.StationNameID.toUpperCase()}</b> 
                                                </div> 
                                                <div class="btn-group w-100 mt-2 bg-light" role="group" aria-label="inspection-list">
                                                    <input type="radio" class="btn-check" name="options-outlined${e.ID}" id="success-outlined${e.ID}" onchange="updateReworkTask(${e.ID},'OK') || $('#card${e.ID}').css({background:'green'})" />
                                                    <label class="btn btn-light btn-sm" for="success-outlined${e.ID}" >OK</label>
                                                    <input type="radio" class="btn-check" name="options-outlined${e.ID}" id="danger-outlined${e.ID}" checked="checked" onchange="updateReworkTask(${e.ID},'NG') || $('#card${e.ID}').css({background:'red'})" />
                                                    <label class="btn btn-light btn-sm" for="danger-outlined${e.ID}">NG</label>
                                                </div>
                                            </div>
                                        </div> 
                                      `)
                                );
                                 
                            } else {
                                toast("Seat Has No Rework Points.")
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

            //function for scan qr bom validation or not   
            $("#bomScanInput").keyup(e => {
                if (e.key == "Enter") {
                    let bomSeq = $("#bomList").val().split(",").at(-1).trim()
                    let partNumber = $("#bomList").val().split(",").at(-2).trim()
                    if (e.target.value.includes(partNumber)) {
                        scanExecuteTask(bomSeq, partNumber)
                        $("#bomScanInput").val("")
                        $("#scanImg").hide()
                        $("#rightScanImg").show()
                        $("#bomScanInput").blur()
                    } else {
                        toast("Invalid Barcode " + e.target.value)
                        $("#bomScanInput").val("")
                    }
                }
            })

        })

        function intervalFunction() { 
            callStationInfo()
            getCurrentUser()
            isScannerConnected()
            isPingDctool() 
            ToolStatus() 
            handleTorqueTask()

        } 

        setInterval(intervalFunction, 500); 


        //code for handle task torque 
        const handleTorqueTask = _ => { 
            filter_torque_task.map(e => {
                if (e.TaskStatus == "Running" || e.TaskStatus == "Error") {
                    torqueExecuteTask(e.ID, e.BomSeq)
                }
            }) 
            if (torqueType != "") {
                $("#torque_list_show_table").show()
                $("#torque_list_show_table tbody").html(
                    filter_torque_task.map((e, i) => `
                    <tr>
                        <td>${i + 1}.</td> 
                        <td>${e.TaskCurrentValue || "-"}</td>
                        <th>
                            ${e.TaskStatus == 'Pending' ? "-" : e.TaskStatus == 'Running' ? '<i class="spinner-grow spinner-grow-sm"></i>' : e.TaskStatus == 'Error' ? '<i class="spinner-grow bg-danger spinner-grow-sm"></i>' : '<img src="../image/icon/check.svg" height=20px/>'}
                            <font color="red">${e.TaskStatus == 'Error' ? torqueAttempt : ''}</font>
                         </th>  
                    </tr>
                `)
                )
            }
        }
         
        //function for call station function for info
        const callStationInfo = () => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/GetStationInfo",
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

        //function for tool status function for info
        const ToolStatus = _ => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/ToolStatus",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d.toLowerCase().includes("false")) {
                        $("#dctoolimage").css({ opacity: 0 })
                        $("#startTorque").removeClass("start")
                    } else {
                        $("#dctoolimage").css({ opacity: .3 })
                        $("#startTorque").addClass("start")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }


        function isPingDctool() {
            $.ajax({
                type: "POST",
                url: "station16.aspx/PING_DCTOOL",
                data: `{station:'${station}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Done") { 
                        $("#dctool_badge").attr("class", "badge bg-success")
                    } else { 
                        $("#dctool_badge").attr("class", "badge bg-danger")
                    } 
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
                url: "station16.aspx/GetCurrentUser",
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

        //function for scan execute task
        const scanExecuteTask = (bom_seq, val) => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/ScanExecuteTask",
                data: `{bom:'${bom_seq}',val:'${val}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {

                },
                Error: function (x, e) {
                    console.log(e); 
                }
            })
        }

        //function for torque tightning user 
        var EntryPoint = true 
        const torqueExecuteTask = (id, torque_seq) => {
            if (EntryPoint) {
                EntryPoint = false
                $.ajax({
                    type: "POST",
                    url: "station16.aspx/TorqueExecuteTask",
                    data: `{torque_seq : '${torque_seq}',username:'${user_details.UserName}', seat_data_id : '${seatId}', station : '${station}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d != "") {
                            var [status, value] = res.d.split(":") 

                            if (status == "Done") {
                                filter_torque_task.map((e,i) => {
                                    if (e.ID == id) {
                                        torqueAttempt = 0
                                        e.TaskCurrentValue = value
                                        e.TaskStatus = "Done"
                                        EntryPoint = true

                                        //this code for next task running 
                                        filter_torque_task[i + 1].TaskStatus = "Running"
                                    }
                                })
                            } else if (status == "Error") {
                                filter_torque_task.map(e => {
                                    if (e.ID == id) {
                                        e.TaskCurrentValue = value
                                        e.TaskStatus = "Error"
                                        EntryPoint = true
                                        torqueAttempt += 1
                                    }
                                })
                            }
                        } else { 
                            EntryPoint = true
                        }
                    },
                    Error: function (x, e) {
                        console.log(e);
                        EntryPoint = true
                    }
                })
            }
        }  
        
        //function for get bom list
        const getBomList = () => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/GetBomList",
                data: `{fgpart : '${fgpart}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d != "Error") { 
                        bom_list = JSON.parse(res.d)  
                        $("#bomList").append(
                            bom_list.map(e => `
                                <option value="${e.PartName}, ${e.PartNumber}, ${e.ScanSequence}">${e.PartName}</option>
                            `)
                        )
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }  
        
        //function for get torque list 
        const getTorqueGroupList = () => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/GetTorqueGroupList",
                data: `{fgpart : '${fgpart}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d != "Error") { 
                        let data = JSON.parse(res.d)
                        torque_list = data
                        torque_list.map(m => m.TaskCurrentValue = "") 

                        console.log(torque_list)
                        console.log(data)
                         
                        $("#torqueList").append(
                            [...new Set(torque_list.map(f => f.BomSeq.trim()))].map(e => `
                                <option>${e}</option>
                            `)
                        )
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }   

        //function for inspection execute task
        const updateReworkTask = (id,status) => {
            $.ajax({
                type: "POST",
                url: "station16.aspx/UPDATE_REWORK_TASK",
                data: `{id : '${id}', status : '${status}' }`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {  
                    if(res.d != "Done") toast(res.d)
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }    

        const handleShowTorqueListTable = tq => {
            torqueType = tq
            EntryPoint = true
            filter_torque_task = torque_list.filter(f => f.BomSeq == tq)
            for (let i = 0; i < filter_torque_task.length; i++) { 
                if (i == 0) {
                    filter_torque_task[i].TaskStatus = "Running"
                } else {
                    filter_torque_task[i].TaskStatus = "Pending"
                }
            }  
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

        #startTorque.start {
            position: absolute;
            width: 90%; 
            height:20px;
            left:50%;
            transform:translate(-50%);
            bottom:20px;
            background:lightgray;
            border-radius:50px;
        }

            #startTorque.start:after {
                content: "";
                width: 0;
                height: 100%;
                position: absolute; 
                border-radius:50px;
                bottom: 0;
                left: 0;
                background:rgba(0,255,0,.8);
                animation: torque_animate 29s linear;
            }

        @keyframes torque_animate{ 
            70%{
                background:rgba(0,255,0,.8);
            }
            100%{
                width:100%;
                background:rgba(255,0,0,.8);
            }
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
        #inpection_task_list_container{
            position: absolute;
            top: 152px;
            left: 0; 
            width: 100%;  
            z-index: 9; 
            display:flex;
            flex-wrap:wrap;
            justify-content:center;
            gap:10px;
            padding:10px; 
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
                    <br />
                    <span class="badge bg-danger" id="dctool_badge">DC TOOLS</span>
                    <span class="badge bg-danger" id="scanner_badge">SCANNER</span>
                </div>
            </div>

            <%--script to show current date--%>
            <script>
                $("#current_time").text(new Date().toISOString().split("T")[0]) 
            </script>
         
            <%--main body content--%>
            <div class="d-flex"> 

                <table class="flex-grow-1 text-center mb-0">
                    <thead>
                        <tr class="text-white" style="height: 46px; font-size: 20px; background: #212529;padding:0 10px;">
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
                                    $("#build_ticket").focus()
                                    setInterval(function () { $("#build_ticket").focus() }, 500)
                                </script>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <%--this is for show all inpections list--%>
                <div id="inpection_task_list_container">   
                     <%--here data will fetch by ajax--%>     

                    <div class="bg-light p-3 shadow rounded" style="position:fixed;bottom:30px;right:30px;z-index:999;">
                        <button type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvas" class="btn">CHANGE BOM</button>   
                        <button type="button" onclick="location.reload()" class="btn btn-primary">SAVE CHANGES</button> 
                    </div> 

                    <div class="offcanvas offcanvas-end" id="offcanvas">
                        <div class="offcanvas-body"> 
                            <%--this is for change bom part--%>
                            <big>Change Bom if Required</big> <br /> 
                            <div class="d-flex mt-2"> 
                                <select class="form-control" onchange="$('#scanImg').show() && $('#bomScanInput').focus() && $('#rightScanImg').hide()" id="bomList">
                                    <option hidden="hidden" selected="selected" >Select Bom</option> 
                                </select>
                                <img src="/image/scaning.gif" height="30" class="m-1" id="scanImg" />
                                <img src="/image/icon/check.svg" height="30" class="m-1" id="rightScanImg" />
                            </div> 
                            <input id="bomScanInput" onblur="$('#scanImg').hide()" /><br /> 

                            <%--this is torque section--%> 
                            <big>Tight Torque if Required </big> <br />   
                            <select class="form-control mt-2" id="torqueList" onchange="handleShowTorqueListTable(this.value)">
                                <option hidden="hidden" selected="selected" >Select Tourque</option> 
                            </select>  <br />

                            <%--if torque required then this table for torque--%> 
                            <table class="w-100 text-center table" id="torque_list_show_table">
                                <thead>
                                <tr>
                                    <th>Seq</th> 
                                    <th>Value</th>
                                    <th>Status</th>
                                </tr> 
                                </thead>
                                <tbody>
                                    
                                </tbody>
                            </table><br />

                            <button data-bs-dismiss="offcanvas" type="button" class="btn btn-secondary d-block m-auto">Continue & Next</button>

                        <%--progress bar for torque giving--%> 
                        <div id="startTorque"></div>


                        </div>   
                    </div>  

                </div>

                <%--show error from backend--%>
            <% if (CurrentError != "")
                { %>
            <%--<div id="toast" class="toast <%=CurrentError == "" ? "" : "show" %> bg-white" style="position: fixed; bottom: 20px; right: 20px; z-index: 999;">
                <div class="d-flex p-2 bg-secondary toast-body text-white">
                    <big class="me-auto ps-2"><%=CurrentError %></big>
                    <button type="button" class="btn-close text-white" data-bs-dismiss="toast"></button>
                </div>
            </div>--%>
            <% } %>

            <%--models for notification--%>
            <div id="modal_container"> 
                 
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
                                    url: "inspection.aspx/UserLogin",
                                    data: `{ Userid: '${user_login_id}',Station: '${plcStation.replace("Station", "") }'}`,
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
                                url: "inspection.aspx/UserLogout",
                                data: `{ Userid: '${user_details.UserID}',Station: '${plcStation.replace("Station", "") }'}`,
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

    <script defer="defer"> 

        //code for toast auto close  
        if (document.getElementById("toast").classList.value.split(" ").includes("show")) {
            setTimeout(function () {
                document.getElementById("toast").classList.remove("show")
                <%CurrentError = "";%>
            }, 5000)
        }

    </script>

</body>
</html>
