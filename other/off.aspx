<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="off.aspx.cs" Inherits="WebApplication2.other.Off" %> 
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
        setInterval(function () {

        }, 1000)
         
        //const isPrinterConnected = _ => { 
        //    $.ajax({
        //        type: "POST",
        //        url: "off.aspx/IS_PRINTER_CONNECTED",
        //        data: ``,
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        async: "true",
        //        cache: "false",
        //        success: (res) => { 
        //            if (res.d == "Success") {
        //                printerConnected = true
        //                $("#printer_badge").attr("class", "badge bg-success")
        //            } else {
        //                printerConnected = false
        //                $("#printer_badge").attr("class", "badge bg-danger")
        //            }
        //        },
        //        Error: function (x, e) {
        //            console.log(e);
        //        }
        //    })
        //}
           
  
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
                <span>NETWORK SWITCH OFF</span>
            </big>   
            <%--<div style="margin-right:20px;">
                <span class="badge bg-danger" style="margin-right:5px;" id="printer_badge">PRINTER</span>      
            </div>--%>
        </div>

        <div class="mx-5 mt-2 d-flex align-items-center mb-5">   
            <button type="button" class="btn btn-primary btn-danger">POWER OFF</button>   
        </div> <br /><br /> 
         
    </form>
</body>
</html>
