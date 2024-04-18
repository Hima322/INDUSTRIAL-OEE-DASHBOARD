<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="print.aspx.cs" Inherits="WebApplication2.bom.Print" %> 
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
        var printerConnected = false 
         
        setInterval(function () {
            isPrinterConnected() 
        }, 1000)
         
        const isPrinterConnected = _ => { 
            $.ajax({
                type: "POST",
                url: "print.aspx/IS_PRINTER_CONNECTED",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d == "Success") {
                        printerConnected = true
                        $("#printer_badge").attr("class", "badge bg-success")
                    } else {
                        printerConnected = false
                        $("#printer_badge").attr("class", "badge bg-danger")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
          
        //on button click event 
        const handlePrint = _ => {
            let key = $("#key").val() 
            let val = $("#val").val() 
            let key1 = $("#key1").val() 
            let val1 = $("#val1").val() 

            $("#printing").css({ "display": "block" })
             
                $.ajax({
                    type: "POST",
                    url: "print.aspx/BOM_PRINT",
                    data: `{key : '${key}',val : '${val}',key1 : '${key1}',val1 : '${val1}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d == "Done") {
                            setTimeout(_ => location.reload(), 100)
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
                <span>PRINT BOM</span>
            </big>   
            <div style="margin-right:20px;">
                <span class="badge bg-danger" style="margin-right:5px;" id="printer_badge">PRINTER</span>      
            </div>
        </div>


        <div class="mx-5 mt-2 d-flex align-items-center mb-5">  
            <h5>Enter Key1 : </h5>  &ensp;
            <input id="key" class="form-control" placeholder="eg. 1st content" style="width:300px;" /> &ensp; 

            <h5>Enter Val1 : </h5>  &ensp;
            <input id="val" class="form-control" placeholder="eg. 1st content val" style="width:300px;" />  
               
        </div>  
        

        <div class="mx-5 mt-2 d-flex align-items-center mb-5">   
            <h5>Enter Key2 : </h5>  &ensp;
            <input id="key1" class="form-control" placeholder="eg. 2nd content" style="width:300px;" /> &ensp; 

            <h5>Enter Val2 : </h5>  &ensp;
            <input id="val1" class="form-control" placeholder="eg. 2nd content val" style="width:300px;" /> <br /><br />

           &ensp;&ensp; <button onclick="handlePrint()" type="button" class="btn btn-primary">Print</button>   
        </div> <br /><br />

        <img src="/image/printing.gif" width="200" style="display:none;margin:auto;" id="printing" />
         
    </form>
</body>
</html>
