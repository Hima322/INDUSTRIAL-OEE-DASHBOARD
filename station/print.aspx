<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="print.aspx.cs" Inherits="WebApplication2.station.Print" %> 
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="../css/libs/font-awesome.min.css" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script>   
    <script src="../js/libs/sweetalert2.all.min.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script> 
        var printer1Connected = false
        var printer2Connected = false
         
        setInterval(function () {
            isPrinter1Connected()
            isPrinter2Connected()
        }, 1000)
         
        const isPrinter1Connected = _ => { 
            $.ajax({
                type: "POST",
                url: "print.aspx/IS_PRINTER1_CONNECTED",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d == "Success") {
                        printer1Connected = true
                        $("#printer1_badge").attr("class", "badge bg-success")
                    } else {
                        printer1Connected = false
                        $("#printer1_badge").attr("class", "badge bg-danger")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        const isPrinter2Connected = _ => { 
            $.ajax({
                type: "POST",
                url: "print.aspx/IS_PRINTER2_CONNECTED",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d == "Success") {
                        printer2Connected = true
                        $("#printer2_badge").attr("class", "badge bg-success")
                    } else {
                        printer2Connected = false
                        $("#printer2_badge").attr("class", "badge bg-danger")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        //on button click event 
        const handlePrint = _ => {
            let seqNum = $("#seqNumber").val()
            let seatType = $("#seatType").val()
            let printType = $("#printType").val()

            if (printType == "printer1") {
                if (!printer1Connected) return toast("Printer not connected", "error")
            } else {
                if (!printer2Connected) return toast("Printer not connected", "error")
            }

            if (!seqNum) return toast("Enter sequence number.","error") 

            $("#printing").css({ "display": "block" })

            if (printType == "printer1") {
                $.ajax({
                    type: "POST",
                    url: "print.aspx/BUILT_TICKET_PRINT",
                    data: `{sequence : '${seqNum}', seat : '${seatType}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d == "Done") {
                            setTimeout(_ => location.reload(), 1000)
                        } else {
                            toast(res.d, "error")
                            $("#printing").css({ "display": "none" })
                        }
                    },
                    Error: function (x, e) {
                        console.log(e);
                    }
                })
            } else { 
                $.ajax({
                    type: "POST",
                    url: "print.aspx/FINEL_QRCODE_PRINT",
                    data: `{sequence : '${seqNum}', seat : '${seatType}' }`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d == "Done") {
                            setTimeout(_ => location.reload(), 1000)
                        } else {
                            toast(res.d, "error")
                            $("#printing").css({ "display": "none" })
                        }
                    },
                    Error: function (x, e) {
                        console.log(e);
                    }
                })
            }
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
</head>
<body class="bg-light">
    <form id="form1" runat="server"> 
                  
        <%--navbar header--%> 
        <div class="navbar navbar-light d-flex p-3">     
            <big>
                <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                <span>PRINT QR CODE</span>
            </big>   
            <div style="margin-right:20px;">
                <span class="badge bg-danger" style="margin-right:5px;" id="printer1_badge">BUILT TICKET PRINTER</span>                  
                <span class="badge bg-danger" id="printer2_badge">FINEL QR PRINTER</span>
            </div>
        </div>


        <div class="mx-5 mt-2 d-flex align-items-center mb-5">  
            <h5>Enter Sequence Number : </h5>  &ensp;
            <input id="seqNumber" type="number" class="form-control" placeholder="eg. 00013" style="width:150px;" /> &ensp;

            <select class="form-select" id="seatType" style="width:150px;">
                <option selected="selected" value="DRIVER">DRIVER-LH</option>
                <option value="CO-DRIVER">CO-DRIVER-RH</option>
            </select> &ensp; 

            <select class="form-select" id="printType" style="width:200px;">
                <option selected="selected" value="printer1">Built Ticket</option>
                <option value="printer2">Finel Qr</option>
            </select> &ensp;&ensp;

            <button onclick="handlePrint()" type="button" class="btn btn-primary">Print</button>   
        </div> <br /><br />

        <img src="/image/printing.gif" width="200" style="display:none;margin:auto;" id="printing" />
         
    </form>
</body>
</html>
