<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="task.aspx.cs" Inherits="WebApplication2.station.Task" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="../css/libs/font-awesome.min.css" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script>  
    <link rel="stylesheet" href="../css/libs/animate.css" /> 
    <script src="../js/libs/sweetalert2.all.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script>
        var modelDetail = []
        var pwd = ""
        var EntryPoint = true

        $(document).ready(function () {

            getModelDetail()
            getStationList() 

            pwd = prompt("Hi admin enter your password : ")
            while (pwd != <%=pwd%>)
                pwd = prompt("Please enter password to access this page : ") 
            toast("Success.")

        })


         //function for get station list function for crud
        const getStationList = _ => { 
            $.ajax({
                type: "POST",
                url: "task.aspx/GET_STATION_LIST",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#loading").hide()
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        let dataKey = Object.keys(data[0])
                        let stn = [...new Set(data.map(e => e.StationNameID))] 

                        stn.forEach(e =>
                            $("#accordion").append(
                            `<div class="card mb-2">
                              <div class="card-header">
                                <a class="btn" data-bs-toggle="collapse" href="#collapse${e}">
                                  ${e}
                                </a>
                              </div>
                              <div id="collapse${e}" class='collapse' data-bs-parent="#accordion">
                                <div class="card-body table-responsive">
                                    <table class="table table-bordered mb-0 text-center table-sm">
                                        <thead class="table-secondary">
                                            <tr>
                                                <th class="px-2">Seq</th>
                                                <th style="padding:5px 80px;">${dataKey[3]}</th>  
                                                <th class="px-2">TaskSequence</th>
                                                ${ dataKey.filter((_, i) => i > 7).map(k => {
                                                    let modelVal= modelDetail.find(e => e.ModelVariant == k)
                                                    return ` <th>${modelVal.Model}<br /> ${modelVal.Variant} [${modelVal.Seat == "DRIVER" ? modelVal.Seat + "-LH" : modelVal.Seat + "-RH" }] <br /> <i> (${modelVal.FG_PartNumber})</i></th>`
                                                }).join('') 
                                                } 
  
                                            </tr>
                                        </thead>
                                        <tbody> 
                                            ${ data.filter(f => f.StationNameID == e).map(j =>
                                                ` <tr>
                                                    <td>${j.ImageSeq}</td> 
                                                    <td>
                                                        ${j.ImageSeq == 1 || j.ImageSeq == 9 || j.ImageSeq == 10 || j.TaskType == "Inspection" || j.TaskType == "QrPrint" ? j.TaskName : (` 
                                                            <select class="form-control" onchange="updateTaskListTable(${j.ID},'TaskName',this.value)" >
                                                                <option></option>
                                                                <option ${j.TaskName == "SCAN" ? "selected" : "" }>SCAN</option>
                                                                <option ${j.TaskName == "TIGHT TORQUE" ? "selected" : "" }>TIGHT TORQUE</option> 
                                                            </select>
                                                        `) }
                                                    </td> 
                                                    <td>${j.ImageSeq == 1 || j.ImageSeq == 9 || j.ImageSeq == 10 || j.TaskType == "Inspection" || j.TaskType == "QrPrint" ? j.BomSeq : `<input value="${j.BomSeq}" onkeyup="updateTaskListTable(${j.ID},'BomSeq',this.value.toUpperCase().trim())" />` }</td> 

                                                   ${
                                                    dataKey.filter((_,i) => i > 7).map(k => `
                                                        <td style="padding:5px 100px;"> 
                                                            <div class="btn-group w-100 mt-2 bg-light" role="group">
                                                                <input ${j.ImageSeq == 1 || j.ImageSeq == 9 || j.ImageSeq == 10 ? "disabled" : ""} type="radio" class="btn-check" name="options-outlined${j.ID + k}" id="success-outlined${j.ID + k}" ${j[k] == 1 ? "checked" : ""} onchange="updateTaskListTable(${j.ID},'${k}',1)" />
                                                                <label class="btn btn-outline-success btn-sm" for="success-outlined${j.ID + k}" >YES</label>
                                                                <input ${j.ImageSeq == 1 || j.ImageSeq == 9 || j.ImageSeq == 10 ? "disabled" : ""} type="radio" class="btn-check" name="options-outlined${j.ID + k}" id="danger-outlined${j.ID + k}" ${j[k] == 0 ? "checked" : ""} onchange="updateTaskListTable(${j.ID},'${k}',0)"/>
                                                                <label class="btn btn-outline-danger btn-sm" for="danger-outlined${j.ID + k}">NO</label>
                                                            </div>
                                                        </td>
                                                        `).join('')
                                                   }                                                     
                                                    </tr>`
                                            ).join('')}
                                        </tbody>
                                    </table>
                                </div>
                              </div>
                        `)) 

                    } else {
                        toast("Something went wrong","error")
                    }
                },
                Error: function (x, e) {
                    console.log(e); 
                }
            })
        }
         
        //function for get update station task list function for crud
        const updateTaskListTable = (id,colName,val) => {
            $.ajax({
                type: "POST",
                url: "task.aspx/UPDATE_TASKLIST_TABLE",
                data: `{id : '${id}', colName : '${colName}', val : '${val}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
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
 
        //function for get station list function for crud
        const getModelDetail = _ => {
            $.ajax({
                type: "POST",
                url: "task.aspx/GET_MODEL_DETAIL",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        modelDetail = data 
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }  

        //alert toast function for notification 
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
             
    </script>
    <style>
        input,select{
            border:none !important;
            text-align:center;
            outline:none;
        }
        table tr td:nth-child(2),table tr th:nth-child(2){ 
            position:sticky; 
            left:-17px;
            top:0;
            z-index:99; 
        }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
    <div>
        
        <div style="position:fixed;top:0;right:0;" class="spinner-border text-primary m-4" id="loading"></div>
         
        <%--navbar header--%> 
        <div class="navbar navbar-light d-flex p-3">     
            <big>
                <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                <span>STATION TASK LIST</span>
            </big>                     
        </div>


        <div id="accordion" class="container">
             
        </div>


         
        <br />
    </div>
    </form>
</body>
</html>