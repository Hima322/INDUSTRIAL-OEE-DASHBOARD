<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.order.index" %>

<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" />
    <script type="text/javascript" src="../js/libs/toastify-js.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>

    <script> 

        var model_details = []
        var current_model = ""
        var driver_fgpart = ""
        var co_driver_fgpart = ""
        var driver_cust = ""
        var co_driver_cust = ""

        $(document).ready(function () {
            $("#data_container_table").hide() 
            remainSeat()

            $.ajax({
                type: "POST",
                url: "index.aspx/MODEL_DETAILS",
                data: `{ }`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        $("#loading").hide()

                        model_details = JSON.parse(res.d);

                        $("#model_value").html(
                            [...new Set(model_details.map(m => m.Model))].map((e, i) => `<option>${e}</option>`)
                        )
                        filterVariant(model_details[0].Model) 
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        })


        function filterVariant(m) {
            document.getElementById("show_table_preview").innerHTML = ""
            $("#data_container_table").hide()

            current_model = m;

            $("#variant_value").html(
                model_details.filter(e => e.Model == m && e.Seat == "DRIVER").map(e => `<option value='${e.Variant},${e.VariantID},${e.ModelVariant}'>${e.Variant},${e.PartName}</option>`)
            )

            filterSeat(`${model_details.filter(e => e.Model == m)[0].Variant},${model_details.filter(e => e.Model == m)[0].VariantID}`)
        }


        function filterSeat(v) {
            document.getElementById("show_table_preview").innerHTML = ""
            $("#data_container_table").hide()

            let current_variant = v.split(",")[0]
            let current_variant_id = v.split(",")[1] 

            driver_fgpart = model_details.filter(e => e.Model == current_model && e.Variant == current_variant && e.VariantID == current_variant_id && e.Seat == "DRIVER")[0].FG_PartNumber
            co_driver_fgpart = model_details.filter(e => e.Model == current_model && e.Variant == current_variant && e.VariantID == current_variant_id && e.Seat == "CO-DRIVER")[0].FG_PartNumber

            driver_cust = model_details.filter(e => e.Model == current_model && e.Variant == current_variant && e.VariantID == current_variant_id && e.Seat == "DRIVER")[0].CustPartNumber
            co_driver_cust = model_details.filter(e => e.Model == current_model && e.Variant == current_variant && e.VariantID == current_variant_id && e.Seat == "CO-DRIVER")[0].CustPartNumber

        }

        //function for change quantity 
        function hidePreview() { 
            document.getElementById("show_table_preview").innerHTML = ""
            $("#data_container_table").hide()
        }

        function handlePreview() {
            document.getElementById("show_table_preview").innerHTML = ""
            var model = $("#model_value").val()
            var variant = $("#variant_value").val().split(",")[0]
            var seatType = $("#seatType").val()
            var quantity = $("#quantity_value").val()
            if (!quantity) {
                toast("Please add quantity.")
            } else { 
                $("#data_container_table").show()
                for (var i = 0; i < quantity; i++) {
                    if (seatType == "SET" || seatType == "DRIVER") {
                        document.getElementById("show_table_preview").innerHTML += `<tr> 
                            <td>${i + 1}</td>
                            <td>${model}</td>
                            <td>${variant}</td>
                            <td>DRIVER</td>
                            <td>${driver_cust}</td>
                            <td>${driver_fgpart}</td> 
                            </tr>`
                    }

                    if (seatType == "SET" || seatType == "CO-DRIVER") {
                        document.getElementById("show_table_preview").innerHTML += `<tr> 
                        <td>${i + 1}</td>
                        <td>${model}</td>
                        <td>${variant}</td>
                        <td>CO-DRIVER</td>
                        <td>${co_driver_cust}</td>
                        <td>${co_driver_fgpart}</td> 
                    </tr>`
                    }
                } 
            } 
        }

        function handleAddOrder() {
            let model = $("#model_value").val()
            let variant = $("#variant_value").val().split(",")[0]
            let modelVariant = $("#variant_value").val().split(",")[2]
            let seatType = $("#seatType").val() 
            let quantity = $("#quantity_value").val()
            if (!quantity) {
                toast("Please add quantity.")
            } else {
                $("#loading").show();
                $("#add_button").attr("disabled", true);
                addBulkOrder(seatType, model, variant, driver_fgpart, co_driver_fgpart, quantity, modelVariant)
            }
        }

        //function for add bulk data in database 
        function addBulkOrder(seatType, model, variant, driver_fgpart, co_driver_fgpart, quantity, modelVariant) {
            $.ajax({
                type: "POST",
                url: "index.aspx/ADD_BULK_DATA",
                data: `{type:'${seatType}', model : '${model}', variant : '${variant}', driver_fgpart : '${driver_fgpart}', co_driver_fgpart :'${co_driver_fgpart}', quantity : '${quantity}',modelVariant:'${modelVariant}' }`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Done") {
                        $("#loading").hide()
                        toast("Successful.")
                        setTimeout(function () { location.reload() },1000)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        //function for get left seat data in database 
        function remainSeat() {
            $.ajax({
                type: "POST",
                url: "index.aspx/REMAIN_SEAT",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        $("#leftSeatButton").prepend(data.length)

                        let model = [...new Set(data.map(e => e.Model))]
                        let mdlVrt = [...new Set(data.map(e => e.ModelVariant))]

                        let mdlVrtArr = []
                        mdlVrt.forEach(e => mdlVrtArr.push({
                            model: data.filter(f => f.ModelVariant == e)[0].Model,
                            variant: data.filter(f => f.ModelVariant == e)[0].Variant,
                            length: data.filter(f => f.ModelVariant == e).length,
                        }))

                        let finelArr = []
                        model.forEach(e => finelArr.push(
                            mdlVrtArr.filter(f => f.model == e)
                        ))
                         
                        finelArr.forEach((e,i) => { 
                            $("#leftSeatModalBody").append(
                                `<ul> 
                                    <li><b>${e[0].model}</b></li>
                                    <ul id="${e[0].model}"> </ul>
                                </ul>`
                            ) 
                            e.forEach(j =>
                                document.getElementById(e[0].model).innerHTML += `<li>${j.variant} : <b>${j.length} seat</b></li>`
                            ) 
                        }) 
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
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div>

            <%--navbar header--%>
            <div class="navbar navbar-light d-flex p-3">
                <big>
                    <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                    <b>CREATE PRODUCTION</b>
                </big>
            </div>

            <%--body content--%>
            <div class="container">
                <div class="tab-content">

                    <%--filter report button group--%>
                    <div class="d-flex justify-content-between">
                        <%--left side navigation tabs--%> 
                        <ul class="nav nav-pills" id="myTab" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active border" id="data-tab" data-bs-toggle="tab" data-bs-target="#data" type="button" role="tab" aria-controls="data" aria-selected="true">Data</button>
                            </li>

                            <li class="nav-item ms-2" role="presentation">
                                <button class="nav-link border" id="file-tab" data-bs-toggle="tab" data-bs-target="#file" type="button" role="tab" aria-controls="file" aria-selected="false">File</button>
                            </li>
                        </ul> 

                        <%--right side of navigation--%> 
                        <div>  
                            <!-- Button to Open the Modal -->
                            <button type="button" class="btn btn-lg" data-bs-toggle="modal" data-bs-target="#leftSeatModal" id="leftSeatButton"> Seat Left &nbsp;<img src="../image/icon/eye.svg" width="20" /> </button>

                            <!-- The Modal -->
                            <div class="modal" id="leftSeatModal">
                              <div class="modal-dialog">
                                <div class="modal-content"> 
                                  <!-- Modal body -->
                                  <div class="modal-body" id="leftSeatModalBody">
                                      <h5 class="text-center mt-2">Production Left Seat Details</h5> 
                                  </div> 
                                </div>
                              </div>
                            </div> 

                        </div>

                    </div>
                    
                    <div style="position:fixed;top:0;right:0;" class="spinner-border text-primary m-4" id="loading"></div>

                    <%--model wise report code--%>
                    <div class="row mt-3 tab-pane fade show active" id="data">
                        <div class="row">
                            <div class="col-sm-2">
                                <b>Model :</b>
                                <select class="form-select" id="model_value" onchange="filterVariant(this.value)"></select>
                            </div>
                            <div class="col-sm-5">
                                <b>Variant : </b><i> part name</i>
                                <select class="form-select" id="variant_value" onchange="filterSeat(this.value)"></select>
                            </div> 
                            <div class="col-sm-2">
                                <b>Type: </b>
                                <select id="seatType" class="form-select" onchange="hidePreview()">
                                    <option checked="true">SET</option>
                                    <option>DRIVER</option>
                                    <option>CO-DRIVER</option>
                                </select>
                            </div>
                            <div class="col-sm-1">
                                <b>Quantity: </b>
                                <input onkeyup="this.value.length > 3 ? (this.value = this.value.substring(0,3)) && toast('Quantity Exceeded.') : ''" type="number" placeholder="10" class="form-control" id="quantity_value" oninput="hidePreview()" />
                            </div>
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary" type="button" onclick="handlePreview()"> PREVIEW </button>
                            </div> 
                            <div class="col-sm-1">
                                <br />
                                <button class="btn btn-primary ms-2" type="button" onclick="handleAddOrder()" id="add_button"> ADD </button>
                            </div>
                        </div>
                    </div>


                    <%--file wise create order--%>
                    <div class="mt-3 collapse tab-pane fade" id="file">
                        <div class="row">
                            <div class="col-sm-5">
                                <b>Upload File :</b>
                                <input type="file" class="form-control" />
                            </div>
                            <div class="col-sm-3">
                                <br />
                                <button class="btn btn-primary">UPLOAD</button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>


            <div class="container mt-4">
                <%--code for show reported data--%>
                <table class="table text-center table-bordered " id="data_container_table">
                    <thead class="table-secondary">
                        <tr>
                            <th>Seq</th>
                            <th>Model</th>
                            <th>Variant</th>
                            <th>Seat</th>
                            <th>Cust. Part Number</th>
                            <th>FGPart Number</th>
                        </tr>
                    </thead>
                    <tbody id="show_table_preview">
                    </tbody>
                </table>
            </div>

            <script>
                var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
                var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
                    return new bootstrap.Popover(popoverTriggerEl)
                })
            </script>

        </div>
    </form>
</body>
</html>
