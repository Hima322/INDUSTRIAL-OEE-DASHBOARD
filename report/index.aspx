
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.report.Index" %>

<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sample Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="../css/libs/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" /> 

    <script type="text/javascript" src="../js/libs/toastify-js.js"></script>
    <script type="text/javascript" src="../js/libs/bootstrap.bundle.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>   
     <script type="text/javascript" src="../js/libs/xlsx.full.min.js"></script>


    <script>


        const table = {
            show: _ => {
                $("#table").show()
                $(".downloadBtn").show()
            },
            hide: _ => {
                $("#table").hide()
                $(".downloadBtn").hide()
            }
        }

        $(document).ready(function () {
            getModelList();
            getVariantList()
            table.hide()

        })

        function ExportToExcel(type, fn, dl) {
            var elt = document.getElementById('table');
            var wb = XLSX.utils.table_to_book(elt, { sheet: "sheet1" });
            return dl ?
                XLSX.write(wb, { bookType: type, bookSST: true, type: 'base64' }) :
                XLSX.writeFile(wb, fn || ('SampleReport.' + (type || 'xlsx')));
        }
             
        const getModelList = _ => {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_MODEL_LIST",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        $("#modelContainer").html(
                            data.map(e => `
                                <option value="${e.PartNumber}">${e.ModelName}</option>
                            `)
                        )
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        const getVariantList = _ => {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_VARIANT_LIST",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        $("#variantContainer").html(
                            data.map(e => `
                                <option value="${e.FG_PartNumber}">${e.Variant} (${e.FG_PartNumber})</option>
                            `)
                        )
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const handleShowModelReport = _ => {
            let model = $("#modelContainer").val()
            let from = $("#modelFrom").val()
            let to = $("#modelTo").val()

            if (!from || !to) return toast("Please select date.")

            $.ajax({
                type: "POST",
                url: "index.aspx/GET_MODEL_REPORT",
                data: `{model:'${model}',from:'${from}',to:'${to}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        $("#table tbody").html(
                            data.map(e => `
                                <tr>
                                    <td>${e.Date.split("T")[0]}</td>
                                    <td>${e.Time.split(".")[0]}</td>
                                    <td>${e.Shift}</td>
                                    <td>${e.SeatSerialNumber}</td>
                                    <td>${e.BuildLabelNumber}</td>
                                    <td>${e.StationNo}</td>
                                    <td>${e.StationDescription}</td>
                                    <td>${e.ParameterDescription}</td>
                                    <td>${e.DataValues}</td>
                                    <td>${e.OverallStatus}</td>
                                    <td>${e.OperatorName}</td>
                                </tr>
                            `)
                        )
                        table.show()
                    } else {
                        toast("Record not found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         

        const handleShowVariantReport = _ => {
            let variant = $("#variantContainer").val()
            let from = $("#variantFrom").val()
            let to = $("#variantTo").val()

            if (!from || !to) return toast("Please select date.")

            $.ajax({
                type: "POST",
                url: "index.aspx/GET_VARIANT_REPORT",
                data: `{variant:'${variant}',from:'${from}',to:'${to}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        $("#table tbody").html(
                            data.map(e => `
                                <tr>
                                    <td>${e.Date.split("T")[0]}</td>
                                    <td>${e.Time.split(".")[0]}</td>
                                    <td>${e.Shift}</td>
                                    <td>${e.SeatSerialNumber}</td>
                                    <td>${e.BuildLabelNumber}</td>
                                    <td>${e.StationNo}</td>
                                    <td>${e.StationDescription}</td>
                                    <td>${e.ParameterDescription}</td>
                                    <td>${e.DataValues}</td>
                                    <td>${e.OverallStatus}</td>
                                    <td>${e.OperatorName}</td>
                                </tr>
                            `)
                        )
                        table.show()
                    } else {
                        toast("Record not found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        const handleShowShiftReport = _ => { 
            let from = $("#shiftFrom").val()
            let to = $("#shiftTo").val()
            let shift = $("#currentshift").val()

            if (!from || !to) return toast("Please select date.")

            $.ajax({
                type: "POST",
                url: "index.aspx/GET_SHIFT_REPORT",
                data: `{shift : '${shift}',from:'${from}',to:'${to}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        $("#table tbody").html(
                            data.map(e => `
                                <tr>
                                    <td>${e.Date.split("T")[0]}</td>
                                    <td>${e.Time.split(".")[0]}</td>
                                    <td>${e.Shift}</td>
                                    <td>${e.SeatSerialNumber}</td>
                                    <td>${e.BuildLabelNumber}</td>
                                    <td>${e.StationNo}</td>
                                    <td>${e.StationDescription}</td>
                                    <td>${e.ParameterDescription}</td>
                                    <td>${e.DataValues}</td>
                                    <td>${e.OverallStatus}</td>
                                    <td>${e.OperatorName}</td>
                                </tr>
                            `)
                        )
                        table.show()
                    } else {
                        toast("Record not found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const handleShowDayReport = _ => { 
            let from = $("#dayFrom").val()
            let to = $("#dayTo").val()

            if (!from || !to) return toast("Please select date.")

            $.ajax({
                type: "POST",
                url: "index.aspx/GET_DAY_REPORT",
                data: `{from:'${from}',to:'${to}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)

                        $("#table tbody").html(
                            data.map(e => `
                                <tr>
                                    <td>${e.Date.split("T")[0]}</td>
                                    <td>${e.Time.split(".")[0]}</td>
                                    <td>${e.Shift}</td>
                                    <td>${e.SeatSerialNumber}</td>
                                    <td>${e.BuildLabelNumber}</td>
                                    <td>${e.StationNo}</td>
                                    <td>${e.StationDescription}</td>
                                    <td>${e.ParameterDescription}</td>
                                    <td>${e.DataValues}</td>
                                    <td>${e.OverallStatus}</td>
                                    <td>${e.OperatorName}</td>
                                </tr>
                            `)
                        )
                        table.show()
                    } else {
                        toast("Record not found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const handleShowSerialNumberReport = _ => { 
            let serial = $("#serialNumber").val() 

            if (!serial) return toast("Please enter serial number.")

            $.ajax({
                type: "POST",
                url: "index.aspx/GET_SERIAL_REPORT",
                data: `{serial:'${serial}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let e = JSON.parse(res.d)

                        $("#table tbody").html(`<tr>
                                <td>${e.Date.split("T")[0]}</td>
                                <td>${e.Time.split(".")[0]}</td>
                                <td>${e.Shift}</td>
                                <td>${e.SeatSerialNumber}</td>
                                <td>${e.BuildLabelNumber}</td>
                                <td>${e.StationNo}</td>
                                <td>${e.StationDescription}</td>
                                <td>${e.ParameterDescription}</td>
                                <td>${e.DataValues}</td>
                                <td>${e.OverallStatus}</td>
                                <td>${e.OperatorName}</td>
                           </tr> `)
                        table.show()
                    } else {
                        toast("Record not found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        //alert toast function for notification 
        const toast = txt =>

            Toastify({
                text: txt,
                duration: 5000,
                gravity: "bottom",
                position: "right",
                style: {
                    background: 'lightgray',
                    color: 'black',
                    fontSize: '20px',
                    fontWeight: 600,
                    borderRadius: '5px'
                }
            }).showToast();

    </script> 
    <style>
        table{
            table-layout:auto !important;
        }
        table thead tr th:first-child{
            min-width:110px;
        }
        table thead tr th:nth-child(5){
            min-width:178px;
        }
        table thead tr th:nth-child(9){
            min-width:120px;
        }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div>   

              
            <%--navbar header--%>
            <div class="navbar navbar-light d-flex p-3">
                <big>
                    <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                    <b>GENERATE REPORT</b>
                </big>

                <%--filter report button group--%>
                <ul class="nav nav-pills" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active border" id="model-tab" data-bs-toggle="tab" data-bs-target="#model" type="button" role="tab" aria-controls="model" aria-selected="true" onclick="table.hide()">Model</button>
                    </li>

                    <li class="nav-item ms-2" role="presentation">
                        <button class="nav-link border " id="variant-tab" data-bs-toggle="tab" data-bs-target="#variant" type="button" role="tab" aria-controls="variant" aria-selected="false" onclick="table.hide()">Variant</button>
                    </li>
                    
                    <li class="nav-item ms-2" role="presentation">
                        <button class="nav-link border " id="day-tab" data-bs-toggle="tab" data-bs-target="#day" type="button" role="tab" aria-controls="day" aria-selected="false" onclick="table.hide()">Date</button>
                    </li>

                    <li class="nav-item ms-2" role="presentation">
                        <button class="nav-link border" id="shift-tab" data-bs-toggle="tab" data-bs-target="#shift" type="button" role="tab" aria-controls="shift" aria-selected="false" onclick="table.hide()">Shift</button>
                    </li>

                    <li class="nav-item ms-2" role="presentation">
                        <button class="nav-link border" id="serial-tab" data-bs-toggle="tab" data-bs-target="#serial" type="button" role="tab" aria-controls="serial" aria-selected="false" onclick="table.hide()">Serial</button>
                    </li>
                </ul>
                 

            </div>

            <%--body content--%>
            <div class="container ">
                <div class="tab-content">

                    <%--model wise report code--%>
                    <div class="row tab-pane fade show active" id="model">
                        <div class="row">
                            <div class="col-sm-2">
                                <b>Model :</b>
                                <select class="form-select" id="modelContainer">
                                    <option>Model</option>
                                </select>
                            </div>
                            <div class="col-sm-2">
                                <b>From :</b>
                                <input type="date" class="form-control" id="modelFrom" />
                            </div>
                            <div class="col-sm-2">
                                <b>To : </b>
                                <input type="date" class="form-control" id="modelTo" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handleShowModelReport()">SHOW</button> 
                            </div>
                            <div class="col-sm-2">
                                <br />
                                <button type="button" class="btn btn-primary downloadBtn" onclick="ExportToExcel()">Download Report</button>
                            </div>
                        </div>
                    </div>

                    <%--day wise report code--%>
                    <div class=" collapse tab-pane fade" id="variant">
                        <div class="row">
                            <div class="col-sm-3">
                                <b>Variant :</b> 
                                <select class="form-select" id="variantContainer">
                                    <option>Variant</option>
                                </select>
                            </div>
                            <div class="col-sm-2">
                                <b>From :</b>
                                <input type="date" class="form-control" id="variantFrom" />
                            </div>
                            <div class="col-sm-2">
                                <b>To : </b>
                                <input type="date" class="form-control" id="variantTo" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handleShowVariantReport()">SHOW</button> 
                            </div>
                            <div class="col-sm-2">
                                <br />
                                <button type="button" class="btn btn-primary downloadBtn" onclick="ExportToExcel()">Download Report</button>
                            </div>
                        </div>
                    </div>

                    <%--day wise report code--%>
                    <div class=" collapse tab-pane fade" id="day">
                        <div class="row">
                            <div class="col-sm-2">
                                <b>From :</b>
                                <input type="date" class="form-control" id="dayFrom" />
                            </div>
                            <div class="col-sm-2">
                                <b>To : </b>
                                <input type="date" class="form-control" id="dayTo" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handleShowDayReport()">SHOW</button> 
                            </div>
                            <div class="col-sm-2">
                                <br />
                                <button type="button" class="btn btn-primary downloadBtn" onclick="ExportToExcel()">Download Report</button>
                            </div>
                        </div>
                    </div>

                    <%--shift wise report code--%>
                    <div class="collapse tab-pane fade" id="shift">
                        <div class="row">
                            <div class="col-sm-2">
                                <b>Shift :</b>
                                <select class="form-select" id="currentshift">
                                    <option>A</option>
                                    <option>B</option>
                                    <option>C</option>
                                </select>
                            </div>
                            <div class="col-sm-2">
                                <b>From :</b>
                                <input type="date" class="form-control" id="shiftFrom" />
                            </div>
                            <div class="col-sm-2">
                                <b>To : </b>
                                <input type="date" class="form-control" id="shiftTo" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handleShowShiftReport()">SHOW</button> 
                            </div>
                            <div class="col-sm-2">
                                <br />
                                <button type="button" class="btn btn-primary downloadBtn" onclick="ExportToExcel()">Download Report</button>
                            </div>
                        </div>
                    </div>

                    <%--serial wise report code--%>
                    <div class="collapse tab-pane fade" id="serial">
                        <div class="row">
                            <div class="col-sm-5">
                                <b>Serial Number :</b>
                                <input class="form-control" placeholder="eg. ER4NS5-32000-00042241220021022" id="serialNumber" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handleShowSerialNumberReport()">SHOW</button>  
                            </div>
                            <div class="col-sm-2">
                                <br />
                                <button type="button" class="btn btn-primary downloadBtn" onclick="ExportToExcel()">Download Report</button>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
             

            <div class="container-fluid px-4 mt-4 table-responsive">
                <%--code for show reported data--%>

                <table id="table" class="table text-center table-sm table-bordered table-striped " style="width: 100%">
                    <thead class="table-secondary" >
                        <tr>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Shift</th>
                            <th>SerialNo</th>
                            <th>Build Label No</th>
                            <th>StationNo.</th>
                            <th>Station Description</th>
                            <th>Parameter Description</th>
                            <th>Data Values</th>
                            <th>Overall Status</th>
                            <th>Operator Name</th>
                        </tr>
                    </thead>
                    <tbody> </tbody> 
                </table>



            <div id="singleReportContainer" class="table-responsive container">
                <h5>Torque Details</h5>
                <table class="table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Shift</th> 
                            <th>StationNo.</th>
                            <th>Station Description</th>
                            <th>Parameter Description</th>
                            <th>Data Values</th>
                            <th>Overall Status</th>
                            <th>Operator Name</th>
                        </tr>
                    </thead>
                    <tbody> </tbody> 
                </table>
            </div>

                
            </div>
            <br /><br />
        </div>
    </form>
</body>
</html>

