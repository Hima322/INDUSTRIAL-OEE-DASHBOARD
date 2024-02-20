<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.monitor.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Monitor Screen</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <script src="../js/libs/bootstrap.bundle.min.js"></script>
    <script src="../js/libs/sweetalert2.all.min.js"></script>
    <script src="../js/libs/plotly.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>  
    <script>

        var pwd = ""
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.onmouseenter = Swal.stopTimer;
                toast.onmouseleave = Swal.resumeTimer;
            }
        });
        //alert toast function for notification  
        const toast = (txt, icon = "success") =>
            Toast.fire({
                icon: icon,
                title: txt
            });

        $(document).ready(function () { 
            getStationAssignments()
            getStationName()
            getPlcTagName()
            createColumnName()
            getDctoolList()
            getShiftSetting()
            getAndonTimingTarget()
            $("#currentYear").val(new Date().getFullYear())
            getProductionYearBase($("#yearPicker").val())
            $("#loading").hide()  
            //this function to show year inside line graph
            $("#yearPicker").prepend(new Array(new Date().getFullYear() - 2024).fill().map((_,i) => `<option>${2024+i}</option>`))

            <%--pwd = prompt("Hi admin enter your password : ")
            while (pwd != <%=pwd%>)
                pwd = prompt("Please enter password to access this page : ") 
            toast("Success.")--%>
        }) 

        function getStationAssignments() {
            $.ajax({
                type: "POST",
                url: "index.aspx/STATION_ASSIGNMENTS",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        let notNullDataArray = Object.entries(data).filter(([, v], i) => v !== "" && i > 1)
                        let notNullData = {}
                        for ([st, op] of notNullDataArray) {
                            notNullData[op.substring(2)] = st.replace("Station", "")
                        }

                        $("#staion_data_container").html(
                            new Array(36).fill().map((e, i) => `
                             <tr>
                                 <td>Station-${i + 1}</td>
                                 <td ondrop="drop(event)" ondragover="allowDrop(event)" id="Station${i + 1}">
                                        <b draggable='true'
                                            data-start="${data[`Station${i + 1}`] && notNullData[Number(data[`Station${i + 1}`].substring(2)) - 1] || 0}"
                                            data-end="${data[`Station${i + 1}`] && notNullData[Number(data[`Station${i + 1}`].substring(2)) + 1] || 37}"
                                            ondragstart='drag(event)' id='op${i + 1}'>${data[`Station${i + 1}`]}</b>
                                 </td> 
                             </tr>
                         `)
                        )

                    } else {
                        toast("Something went wrong.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        function getStationName() {
            $.ajax({
                type: "POST",
                url: "index.aspx/STATION_NAME",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        data.splice(15, 0, data.at(-1))
                        data = data.slice(0, data.length - 1)

                        $("#staion_name_container").html(
                            data.map(e => `
                             <tr>
                                 <td>${e.StationNameID == "Station-0" ? "Built Ticket" : e.StationNameID == "Station-16" ? "Rework" : e.StationNameID}</td > 
                                 <td><input class="form-control bolrder-less-input form-control-sm" value="${e.Station_Name}" id="input${e.ID}" onkeyup=removeBtnDisabled(${e.ID}) /></td> 
                                 <td><button type="button" class="btn btn-sm" disabled id="btn${e.ID}" onclick=updateStationName(${e.ID},$("#input${e.ID}").val()) >Edit</button></td>
                             </tr>
                         `)
                        )

                    } else {
                        toast("Something went wrong.", "error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        function getAndonTimingTarget() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_ANDON_TIMING_TARGET",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d) 

                        $("#shiftATargetContainer").html(
                            data.filter(f => f.ShiftName == "A").map((e,i) => `
                              <tr>
                                 <td>${i+1}</td>
                                 <td>${e.HourName}</td>
                                 <td><input value="${e.Target}" type="number" class="form-control bolrder-less-input m-auto" style="width:100px;" onkeyup="updateAndonTarget(${e.ID},this.value)" /></td> 
                             </tr>
                         `)
                        )
                        
                        $("#shiftBTargetContainer").html(
                            data.filter(f => f.ShiftName == "B").map((e,i) => `
                              <tr>
                                 <td>${i+1}</td>
                                 <td>${e.HourName}</td>
                                 <td><input value="${e.Target}" type="number" class="form-control bolrder-less-input m-auto" style="width:100px;" onkeyup="updateAndonTarget(${e.ID},this.value)" /></td> 
                             </tr>
                         `)
                        )
                        
                        $("#shiftCTargetContainer").html(
                            data.filter(f => f.ShiftName == "C").map((e,i) => `
                              <tr>
                                 <td>${i+1}</td>
                                 <td>${e.HourName}</td>
                                 <td><input value="${e.Target}" type="number" class="form-control bolrder-less-input m-auto" style="width:100px;" onkeyup="updateAndonTarget(${e.ID},this.value)" /></td> 
                             </tr>
                         `)
                        )

                    } else {
                        toast("Something went wrong.", "error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }


        function getPlcTagName() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_PLC_TAG_NAME",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        console.log(data)

                        let WriteBit = data[0]
                        let ReadBit = data[1]
                        let MaintenanceDelay = data[2]
                        let OperatrorDelay = data[3]
                        let QualityDelay = data[4]
                        let MaterialDelay = data[5]
                        let ScanBit = data[6]

                        //fetch scan all tags 
                        Object.keys(ScanBit).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_scan_bit_tag").append(`
                            <td>
                                <input  
                                    onfocus=readPlcTag(this.value)
                                    class="bolrder-less-input form-control-sm"
                                    value="${ScanBit[sKey]}"  
                                    onkeyup=updatePlcTagName(${ScanBit.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch write all tags 
                        Object.keys(WriteBit).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_write_bit_tag").append(`
                            <td>
                                <input  
                                    onfocus=readPlcTag(this.value)
                                    class="bolrder-less-input form-control-sm"
                                    value="${WriteBit[sKey]}"  
                                    onkeyup=updatePlcTagName(${WriteBit.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch read all tags  
                        Object.keys(ReadBit).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_read_bit_tag").append(`
                            <td>
                                <input  
                                    onfocus=readPlcTag(this.value)
                                    class="bolrder-less-input form-control-sm"
                                    value="${ReadBit[sKey]}"  
                                    onkeyup=updatePlcTagName(${ReadBit.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch MaintenanceDelay all tags 
                        Object.keys(MaintenanceDelay).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_maintenance_bit_tag").append(`
                            <td>
                                <input  
                                    class="bolrder-less-input form-control-sm"
                                    value="${MaintenanceDelay[sKey]}"  
                                    onkeyup=updatePlcTagName(${MaintenanceDelay.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch OperatrorDelay all tags  
                        Object.keys(OperatrorDelay).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_operator_bit_tag").append(`
                            <td>
                                <input  
                                    class="bolrder-less-input form-control-sm"
                                    value="${OperatrorDelay[sKey]}"  
                                    onkeyup=updatePlcTagName(${OperatrorDelay.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch QualityDelay all tags
                        Object.keys(QualityDelay).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_quality_bit_tag").append(`
                            <td>
                                <input  
                                    class="bolrder-less-input form-control-sm"
                                    value="${QualityDelay[sKey]}"  
                                    onkeyup=updatePlcTagName(${QualityDelay.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )
                        //fetch MaterialDelay all tags
                        Object.keys(MaterialDelay).filter((f, i) => i > 1).map((sKey, i) =>
                            $("#plc_material_bit_tag").append(`
                            <td>
                                <input  
                                    class="bolrder-less-input form-control-sm"
                                    value="${MaterialDelay[sKey]}"  
                                    onkeyup=updatePlcTagName(${MaterialDelay.ID},'Station${i + 1}',this.value)
                                    />
                            </td> 
                            `)
                        )


                    } else {
                        toast("Something went wrong.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        function readPlcTag(tag) {
            $.ajax({
                type: "POST",
                url: "index.aspx/READ_PLCTAG",
                data: `{tag : '${tag}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (!(res.d.includes("True") || res.d.includes("False"))) return toast(res.d, "error")
                    toast(res.d)
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        function removeBtnDisabled(id) {
            $(`#btn${id}`).attr("disabled", false)
            $(`#btn${id}`).addClass("btn-primary")
        }

        function allowDrop(ev) {
            ev.preventDefault();
        }

        var opt = "";
        var start = "";
        var end = "";
        function drag(ev) {
            opt = ev.target.innerText
            ev.dataTransfer.setData("text", ev.target.id);

            start = ev.target.getAttribute("data-start");
            end = ev.target.getAttribute("data-end");
        }

        function drop(ev) {
            ev.preventDefault();
            let conSta = ev.target.id.replace("Station", "")
            if (ev.target.innerText) return toast("Already it\'s station.", "error")

            if (opt != "OP4" && opt != "OP5" && opt != "OP6" && opt != "OP7") {
                if (conSta < start || conSta > end) {
                    return toast("You can\' skip station.", "error")
                }
            }

            var data = ev.dataTransfer.getData("text");
            ev.target.append(document.getElementById(data));
            updateStationPosition(opt, ev.target.id, "Station" + data.substring(2))
        }

        function updateStationPosition(operator, currentSt, prevSt) {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_STATION_POSITION",
                data: `{Operator : '${operator}', CurrentST : '${currentSt}', PrevST : '${prevSt}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.") 
                        getStationAssignments()
                    } else {
                        toast(res.d)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        function updateAndonTarget(id, value) {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_ANDON_TARGET",
                data: `{id : '${id}', value : '${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.") 
                    } else {
                        toast(res.d)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        function updateStationName(id, value) {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_STATION_NAME",
                data: `{id : '${id}', value : '${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.")
                        getStationName()
                    } else {
                        toast(res.d)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        function updatePlcTagName(id, station, value) {

            if (pwd.toLowerCase() != 'pmal2360') return toast("Sorry! You are not developer so you can not edit tags.", "error")

            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_PLCTAG_NAME",
                data: `{id : '${id}', station : '${station}', value : '${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Done") {
                        toast("Updated.")
                    } else {
                        toast(res.d)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        function updateIpAddress(key, value) {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_IPADDRESS",
                data: `{key: '${key}', value : '${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.")
                    } else {
                        toast(res.d, "error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        function updateDctoolIpAddress(id, value) {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_DCTOOL_IPADDRESS",
                data: `{id: '${id}', value : '${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.")
                    } else {
                        toast(res.d,"error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        function updateShiftSettingTiming(id, value,time) {  
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_SHIFT_SETTING_TIMING",
                data: `{id: '${id}', value : '${value}',time:'${time}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.")
                    } else {
                        toast(res.d,"error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        function getShiftSetting() { 
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_SHIFT_SETTING",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {  
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                         

                        $("#shiftSetting").html(
                            data.map(e => 
                                    `<tr>
                                        <td>${e.ShiftName}</td>
                                        <td>${e.ShiftName.length > 3 ? `<input class="form-control bolrder-less-input" value="${e.StartTime}" onkeyup=updateShiftSettingTiming(${e.ID},this.value,'StartTime') />` : e.StartTime }</td> 
                                        <td>${e.ShiftName.length > 3 ? `<input class="form-control bolrder-less-input" value="${e.EndTime}" onkeyup=updateShiftSettingTiming(${e.ID},this.value,'EndTime') />` : e.EndTime }</td>  
                                    </tr>
                                `)
                            )

                    } else {
                        toast(res.d,"error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        function getProductionYearBase(year) { 
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_PRODUCTION_YEAR_BASE",
                data: `{year : '${year}'}`,
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
        
        function handleUpdateSeftyLine() {
            $("#loading").show()
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_SEFTYLINE",
                data: `{value : '${$("#seftyInput").val().replaceAll("#", "&#").replace("??", "") }'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()

                    if (res.d == "Done") {
                        toast("Success.") 
                    } else {
                        toast(res.d,"error")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        function getDctoolList() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_DCTOOL_LIST",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                            data.forEach(e =>  
                            $("#dctoolshowlist").append(
                                `<div class="container-fluid d-flex gap-2 mb-1">
                                    <div style="width:200px;"><b>${e.TorqueName} Dctool : -</b></div>
                                    <input value="${e.TorqueToolIPAddress}" onkeyup='$("#dctool${e.ID}").attr("disabled",false)' type="text" id="dctool${e.ID}input" />
                                    <button type="button" disabled="disabled" id="dctool${e.ID}" onclick="updateDctoolIpAddress(${e.ID}, $('#dctool${e.ID}input').val())" class="btn btn-primary btn-sm">Update</button>
                                </div> `
                            )
                        )
                    } 
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
          
        function createColumnName() {
            for (var i = 1; i < 37; i++) {
                $(".table_column_name").append(`<td>Station${i}</td>`)
            }
        }

    </script>
    <style>
        * {
            user-select: none;
        }

        .bolrder-less-input {
            text-align: center;
            border: 0px !important;
            outline: none;
        }

        tbody tr td:nth-child(2) {
            cursor: pointer;
        }

        .modebar-group:last-child {
            display: none !important;
        }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="m-0">


            
            <%--navbar header--%>
            <div class="navbar navbar-light d-flex align-items-center px-5" style="background: lightgray;">
                <!--header logo--> 
                <img src="../image/logo.png" alt="error" height="45" /> 
                <big><b>MONITOR AND CONTROL SCREEN</b></big> 
                <div>
                    <input autofocus="autofocus" style="opacity:0;" onkeyup="pwd = this.value" /> 
                    <button class="btn btn-light" type="button" onclick="location.href = '/index.aspx'">Dashboard</button> 
                </div>
            </div>

             
            <%--tab section body content--%>
            <div class="container-fluid">
                <div class="tab-content mt-3">

                    <%--all controll button group--%>
                    <ul class="nav nav-pills" id="myTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active border" id="monitor-tab" data-bs-toggle="tab" data-bs-target="#monitor" type="button" role="tab" aria-controls="station" aria-selected="true">MONITOR CONTROL</button>
                        </li>

                        <li class="nav-item" role="presentation">
                            <button class="nav-link ms-2 border" id="station-tab" data-bs-toggle="tab" data-bs-target="#station" type="button" role="tab" aria-controls="station" aria-selected="true">STATION CONTROL</button>
                        </li>
                        
                        <li class="nav-item" role="presentation">
                            <button class="nav-link ms-2 border" id="andon-tab" data-bs-toggle="tab" data-bs-target="#andon" type="button" role="tab" aria-controls="andon" aria-selected="true">ANDON CONTROL</button>
                        </li>

                        <li class="nav-item ms-2" role="presentation">
                            <button class="nav-link border" id="plc-tab" data-bs-toggle="tab" data-bs-target="#plc" type="button" role="tab" aria-controls="plc" aria-selected="true">PLC CONTROL</button>
                        </li>

                        <li class="nav-item ms-2" role="presentation">
                            <button class="nav-link border" id="printer-tab" data-bs-toggle="tab" data-bs-target="#printer" type="button" role="tab" aria-controls="printer" aria-selected="false">PRINTER CONTROL</button>
                        </li>

                        <li class="nav-item ms-2" role="presentation">
                            <button class="nav-link border" id="dctool-tab" data-bs-toggle="tab" data-bs-target="#dctool" type="button" role="tab" aria-controls="dctool" aria-selected="false">DC TOOLS CONTROL</button>
                        </li>
                    </ul>


                    <%--monitor control code--%>
                    <div class="mt-3 tab-pane fade show active" id="monitor">
                        <%--this graph to represent delays like maintinace operator etc--%>
                        <div id="myPlot2" class="mx-3" style="width: calc(100% - 40px);"></div>

                        <%--this date for graphs--%> 
                        <div class="d-flex justify-content-between mx-3 gap-3 mt-3"> 
                            <button>Year</button>
                            <select class="form-select" id="yearPicker" style="width:200px;" onchange="getProductionYearBase(this.value)"> 
                                <option selected="selected" id="currentYear"></option>
                            </select>
                        </div>

                        <%--this graph for another work--%> 
                        <div class="d-flex justify-content-around mx-3 gap-3 mt-3"> 
                            <div id="myPlot1" style="width: 50%;"></div>
                            <div id="myPlot" style="width: 50%;"></div> 
                        </div>

                        <%--script for graph--%> 
                        <script> 

                            //for 1  delay graph
                            const xArray2 = ["Maintenance Delay", "Operatror Delay", "Quality Delay", "Material Delay", "Light Delay"];
                            const yArray2 = [55, 49, 44, 24, 15];

                            const data2 = [{
                                x: xArray2,
                                y: yArray2,
                                type: "bar",
                                orientation: "v",
                                marker: { color: "#0d6efd" }
                            }];

                            const layout2 = { title: "Today current delay records." };

                            Plotly.newPlot("myPlot2", data2, layout2);



                        //for 2
                        const xArray1 = ["MID MT", "PRIMIUM MT", "UPPER MT", "MIT CVT", "E2", "CL"];
                        const yArray1 = [55, 49, 44, 24, 85,33];

                        const layout1 = { title: "Variant wise production structure" };

                        const data1 = [{ labels: xArray1, values: yArray1, type: "pie" }];

                        Plotly.newPlot("myPlot1", data1, layout1);


                            //for 3
                            const xArray = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                            const yArray = [743, 834, 938, 839, 739, 909, 930, 821, 734, 943, 658, 843];

                            // Define Data
                            const data = [{
                                x: xArray,
                                y: yArray,
                                mode: "lines",
                                type: "scatter"
                            }];

                            // Define Layout
                            const layout = {
                                xaxis: { title: "Time in month" },
                                yaxis: { title: "Seat production" },
                                title: "Seat Production Year Basis"
                            };

                            // Display using Plotly
                            Plotly.newPlot("myPlot", data, layout);


                        </script>
                    </div> 
                     

                    <%--station control code--%>
                    <div class="mt-3 tab-pane fade" id="station">
                        <div class="d-flex mx-3">
                            <%--this is for update station position--%>
                            <div class="container-fluid ">
                                <table class="table table-bordered text-center ">
                                    <thead class="table-primary">
                                        <tr>
                                            <th colspan="2">STATION POSITION UPDATE</th>
                                        </tr>
                                        <tr>
                                            <th>Con. station</th>
                                            <th>MES Station</th>
                                        </tr>
                                    </thead>
                                    <tbody id="staion_data_container">
                                        <%--data will fetch from js--%>
                                        <tr>
                                            <td colspan="2">
                                                <img style="height: 200px; margin: 50px auto;" src="../image/empty.png" alt="error" />
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            
                            <%--this is loading section--%> 
                            <div style="position:fixed;top:0;right:0;" class="spinner-border text-primary m-4" id="loading"></div>

                            <%--this sectin for update station name--%>
                            <div class="container-fluid">
                                <table class="table table-bordered text-center ">
                                    <thead class="table-primary">
                                        <tr>
                                            <th colspan="3">STATION NAME UPDATE</th>
                                        </tr>
                                        <tr>
                                            <th>MES Station</th>
                                            <th>Station name</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="staion_name_container">
                                        <%--data will fetch from js--%>
                                        <tr>
                                            <td colspan="3">
                                                <img style="height: 200px; margin: 50px auto;" src="../image/empty.png" alt="error" />
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    
                    <%--andon control code--%>
                    <div class="mt-3 tab-pane fade" id="andon">
                        <div class="d-flex mx-3">
                            <%--this is for update andon position--%>
                            <div class="container-fluid "> 

                                <table class="table table-bordered text-center ">
                                    <thead class="table-primary">
                                        <tr>
                                            <th colspan="3">SHIFT SETTING</th>
                                        </tr>
                                        <tr>
                                            <th>Shift Name</th>
                                            <th>Start Time</th>
                                            <th>End Time</th>
                                        </tr>
                                    </thead>
                                    <tbody id="shiftSetting">
                                        <%--data will fetch from js--%>
                                        <tr>
                                            <td colspan="2">
                                                <img style="height: 200px; margin: 50px auto;" src="../image/empty.png" alt="error" />
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div> 

                            <%--this sectin for update andon name--%>
                            <div class="container-fluid">
                               <h5>Andon Sefty Title</h5> 
                                <textarea onkeyup="$('#seftyTitleUpdateButton').attr('disabled',false) && $('#imojiGroup').css({opacity:1})" id="seftyInput" rows="3" class="form-control"><%=seftyTitle %></textarea> 
                                <div class="d-flex my-3"> 
                                    <div class="btn-group" role="group" aria-label="Basic radio toggle button group" id="imojiGroup" style="opacity:.5;">
                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio1" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio1" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128516;' + ' ')">&#128516;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio2" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio2" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128521;' + ' ')">&#128521;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio3" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio3" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128520;' + ' ')">&#128520;</label>
                                        
                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio4" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio4" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128525;' + ' ')">&#128525;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio5" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio5" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128536;' + ' ')">&#128536;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio6" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio6" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128545;' + ' ')">&#128545;</label>
                                        
                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio7" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio7" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128553;' + ' ')">&#128553;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio8" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio8" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128557;' + ' ')">&#128557;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio9" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio9" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#128567;' + ' ')">&#128567;</label>

                                          <input type="radio" class="btn-check" name="btnradio" id="btnradio10" autocomplete="off" />
                                          <label class="btn btn-outline-primary" for="btnradio10" onclick="$('#seftyInput').val($('#seftyInput').val() + ' ' + '#129296;' + ' ')">&#129296;</label>
                                     </div>
                                    <button type="button" class="btn btn-primary d-block ms-auto" disabled="disabled" id="seftyTitleUpdateButton" onclick="handleUpdateSeftyLine()">Update</button>
                                </div>
                                
                                <%--for shift a target edit--%>   
                                <div class="card mt-2">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseshiftATarget">Shift A Target.
                                        </a>
                                    </div>
                                    <div id="collapseshiftATarget" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">
                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr>
                                                            <th class="table-primary"> # </th>
                                                            <th class="table-primary"> Timing </th>
                                                            <th class="table-primary"> Target </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="shiftATargetContainer">
                                                        <%--data will fetch from js--%> 
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <%--for shift b target edit--%>   
                                <div class="card mt-2">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseshiftBTarget">Shift B Target.
                                        </a>
                                    </div>
                                    <div id="collapseshiftBTarget" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">
                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr>
                                                            <th class="table-primary"> # </th>
                                                            <th class="table-primary"> Timing </th>
                                                            <th class="table-primary"> Target </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="shiftBTargetContainer">
                                                        <%--data will fetch from js--%> 
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <%--for shift c target edit--%>   
                                <div class="card mt-2">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseshiftCTarget">Shift C Target.
                                        </a>
                                    </div>
                                    <div id="collapseshiftCTarget" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">
                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr>
                                                            <th class="table-primary"> # </th>
                                                            <th class="table-primary"> Timing </th>
                                                            <th class="table-primary"> Target </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="shiftCTargetContainer">
                                                        <%--data will fetch from js--%> 
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                            </div>
                        </div>
                    </div>


                    <%--plc control code--%>
                    <div class="mt-3 tab-pane fade" id="plc">
                        <div class="row mx-3">

                            <div id="accordion">

                                <%--write plc ip address here--%>
                                <div class="card">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapsePlcIp">Manage plc ip address.
                                        </a>
                                    </div>
                                    <div id="collapsePlcIp" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid col-12">
                                                <b>PLC IP Address : </b>
                                                <input value="<%=plcIpAddress %>" onkeyup='$("#plcIpAddressUpdateBtn").attr("disabled",false)' type="text" id="plc_ip_address_value" />
                                                <button type="button" disabled="disabled" id="plcIpAddressUpdateBtn" onclick="updateIpAddress('PlcIp', $('#plc_ip_address_value').val())" class="btn mb-1 btn-primary btn-sm">Update</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%--scan bit tag data here--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseZero">Show scan bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseZero" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">
                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_scan_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <%--write plc tag data here--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseOne">Show write bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseOne" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">
                                            <%--this is for show write plc bit tag--%>
                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_write_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%--this is for show read plc bit tag--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="collapsed btn" data-bs-toggle="collapse" href="#collapseTwo">Show read bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseTwo" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_read_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%--this is for show maintenance plc bit tag--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="collapsed btn" data-bs-toggle="collapse" href="#collapseThree">Show maintenance delay bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseThree" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_maintenance_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%--this is for show operator plc bit tag--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="collapsed btn" data-bs-toggle="collapse" href="#collapseFour">Show operator delay bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseFour" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_operator_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%--this is for show quality plc bit tag--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="collapsed btn" data-bs-toggle="collapse" href="#collapseFive">Show quality delay bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseFive" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_quality_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>

                                        </div>
                                    </div>
                                </div>


                                <%--this is for show material plc bit tag--%>
                                <div class="card mt-1">
                                    <div class="card-header">
                                        <a class="collapsed btn" data-bs-toggle="collapse" href="#collapseSix">Show material delay bit plc tag detail.
                                        </a>
                                    </div>
                                    <div id="collapseSix" class="collapse" data-bs-parent="#accordion">
                                        <div class="card-body">

                                            <div class="container-fluid table-responsive">
                                                <table class="table table-bordered text-center ">
                                                    <thead>
                                                        <tr class="table_column_name">
                                                            <th class="table-primary">StationName</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <%--data will fetch from js--%>
                                                        <tr id="plc_material_bit_tag">
                                                            <th class="table-primary">TagName</th>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>


                    <%--printer control--%>
                    <div class="mt-3 collapse tab-pane fade" id="printer">
                        <div class="container">

                            <div id="accordionPrinter">
                                <%--write printer ip address here--%>
                                <div class="card">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapsePrinter1">Manage printer ip address.
                                        </a>
                                    </div>
                                    <div id="collapsePrinter1" class="collapse" data-bs-parent="#accordionPrinter">
                                        <div class="card-body">

                                            <%--this is for show printer of built ticket ip address--%>
                                            <div class="container-fluid">
                                                <b>Built Ticket Printer Ip Address : <small>port</small> &ensp; &ensp;&ensp;&ensp;&ensp; -  </b>
                                                <input value="<%=printer1IpAddress %>" onkeyup='$("#printer1IpAddressUpdateBtn").attr("disabled",false)' type="text" id="printer1_ip_address_value" />
                                                <button type="button" disabled="disabled" id="printer1IpAddressUpdateBtn" onclick="updateIpAddress('PrinterIp', $('#printer1_ip_address_value').val())" class="btn mb-1 btn-primary btn-sm">Update</button>
                                            </div>

                                            <%--this is for show printer of built finel ticket ip address--%>
                                            <div class="container-fluid">
                                                <b>Finel Built Ticket Printer Ip Address : <small>port</small> &ensp;- </b>
                                                <input value="<%=printer2IpAddress %>" onkeyup='$("#printer2IpAddressUpdateBtn").attr("disabled",false)' type="text" id="printer2_ip_address_value" />
                                                <button type="button" disabled="disabled" id="printer2IpAddressUpdateBtn" onclick="updateIpAddress('FinelPrinterIp', $('#printer2_ip_address_value').val())" class="btn mb-1 btn-primary btn-sm">Update</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                    
                    <%--dctool control--%>
                    <div class="mt-3 collapse tab-pane fade" id="dctool">
                        <div class="container"> 
                            <div id="accordionDctool">
                                <%--write dc ip address here--%>
                                <div class="card">
                                    <div class="card-header">
                                        <a class="btn" data-bs-toggle="collapse" href="#collapseDctool1">Manage Dctool ip address.
                                        </a>
                                    </div>
                                    <div id="collapseDctool1" class="collapse" data-bs-parent="#accordionDctool">
                                        <div class="card-body" id="dctoolshowlist">

                                            <%--this is for show printer of built ticket ip address--%>
                                            <div class="container-fluid d-flex gap-2 mb-1 align-items-center">
                                                <div style="width:200px;"><b>Rework Dctool : - </b></div>
                                                <input value="<%=reworkDctoolIpAddress %>" onkeyup='$("#reworkDctoolIpAddressUpdateBtn").attr("disabled",false)' type="text" id="rework_dctool_ip_address_value" />
                                                <button type="button" disabled="disabled" id="reworkDctoolIpAddressUpdateBtn" onclick="updateIpAddress('ReworkDcTooIP', $('#rework_dctool_ip_address_value').val())" class="btn mb-1 btn-primary btn-sm">Update</button>
                                            </div>
                                              
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <br />
        </div>
    </form>
</body>
</html>
