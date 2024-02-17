<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="station0.aspx.cs" Inherits="WebApplication2.station.Station0" %> 

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

        //alert toast function for notification  
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 3000,
            background: "yellow",
            width: "600px", 
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.onmouseenter = Swal.stopTimer;
                toast.onmouseleave = Swal.resumeTimer;
            }
        });
        //alert toast function for notification  
        const toast = (txt, icon = "error") =>
            Toast.fire({
                icon: icon,
                title: `<h4>${txt}</h4>`
            });


        var station = localStorage.getItem("station")
        var user_details = {}
        var PrinterConnected = false

        $(document).ready(function () {
            callStationInfo() 
            GetRequiredPrint() 
            $("#barcode_input").focus()  

            $("#barcode_input").keyup(function (e) { 
                e.preventDefault()
                if (e.key == "Enter") {

                    //this is for indecate scannerbadge 
                    localStorage.setItem("1min", Date.now() + 60000)

                    //LOGOUT FUNCTION FROM SCANNER 
                    if (e.target.value == "logout") {
                        return handleLogout();
                    }

                    //page reload function
                    if (e.target.value == "reload") {
                        return location.reload();
                    } 

                    checkQrCode(e.target.value)
                }
            })
            //checking if station assigned not build ticket then redirect index page 
            if (station != "Station-0") {
                location.href = "index.aspx"
            } 
        })


        setInterval(function () {
            callStationInfo()
            getCurrentUser()
            isPrinterConnected()
            isScannerConnected()
            $("#barcode_input").focus()  
        }, 1000);
  
        //function for call station function for info
        const callStationInfo = () => {
            $.ajax({
                type: "POST",
                url: "station0.aspx/GetStationInfo",
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

        //function for check is printer connected
        const isPrinterConnected = () => {
            $.ajax({
                type: "POST",
                url: "station0.aspx/ISPRINTERCONNECTED",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 
                    if (res.d == "Success") {
                        PrinterConnected = true; 
                        $("#printer_badge").attr("class", "badge bg-success")
                    } else {
                        PrinterConnected = false;
                        $("#printer_badge").attr("class", "badge bg-danger")
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
                url: "station0.aspx/GetCurrentUser",
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

        function GetRequiredPrint() {
            $.ajax({
                type: "POST",
                url: "station0.aspx/GetRequiredPrint",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") { 
                        var data = JSON.parse(res.d)

                        $("#seq").text(data.seq)
                        $("#model").text(data.model)
                        $("#variant").text(data.variant)
                        $("#fgpart").text(data.fgpart)
                        $("#seat").text(data.seat)
                         
                    } else {
                        toast(`Unavailable seat to print built ticket.`)
                        $("#barcode_input").val("");
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
         
        function checkQrCode(qr) {
            if (!PrinterConnected) {
                toast("Printer not connected.")
                $("#barcode_input").val(""); 
            } else {
                $.ajax({
                    type: "POST",
                    url: "station0.aspx/IsQRValid",
                    data: `{value : '${qr}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d != null) {
                            if (res.d.includes("Error")) return toast(res.d) 
                            $("#result_container").html(` <img src="/image/printing.gif" width="200" class="mt-5 my-4" /><h2>Printing QrCode</h2>`)
                            setTimeout(_ => location.reload(),3000)
                        } else {
                            toast(`Invalid Barcode ${qr}`)
                            $("#barcode_input").val(""); 
                        }
                    },
                    Error: function (x, e) {
                        console.log(e);
                    }
                })
            }
        } 
         
        function isScannerConnected() {
            if (localStorage.getItem("1min") > Date.now()) {

                //show scanner is connected in badge 
                $("#scanner_badge").attr("class", "badge bg-success")
            } else {
                $("#scanner_badge").attr("class", "badge bg-danger")
            }
        }

    </script>
    
    <style>
        input {
            opacity:0;
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
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div>
            <%--header navbar code--%>
            <div class="d-flex align-items-center justify-content-center">
                <div class="px-2">
                    <img src="../image/logo.png" alt="error" height="60" />
                </div>
                
                <div class="text-center bg-secondary px-3 pt-1" style="height: 60px;">
                    <b class="text-light">TM SEATING
                         <br />
                        CHENNAI PLANT</b>
                </div>

                <div class="text-center bg-primary flex-grow-1 px-3 d-flex justify-content-between align-items-center" style="height: 60px;">
                    <big class="text-light">
                        <b class="station_name"></b>
                    </big>
                    <big class="text-light animate__animated animate__bounceInDown ">
                        <img src="../image/icon/user.png" height="20" />
                        <b id="current_user"></b>
                    </big>
                </div>
                
                <div class="text-center bg-warning px-3 pt-2" style="height: 60px;">
                    <b class="text-dark"> 
                        <span id="current_date"></span><br />
                        <span id="current_time"></span>
                    </b>
                </div>

                <script>
                   function setGetTime(){
                        $("#current_date").text(new Date().toLocaleString().split(",")[0])
                        $("#current_time").text(new Date().toLocaleString().split(",")[1])
                    }

                    setGetTime()
                    setInterval(function () {
                        setGetTime()
                    },1000)
                </script>


                <div class="text-center px-3" style="height: 60px;">
                    <big><span class="badge bg-danger" id="database_badge">DATABASE</span></big>
                    <br />
                    <big><span class="badge bg-danger" id="scanner_badge">SCANNER</span></big>
                    <big><span class="badge bg-danger" id="printer_badge">PRINTER</span></big>
                </div>
            </div>

            <%--header content--%>
            <table class="table table-bordered text-center mb-0">
                <tr class="table-dark">
                    <th>SEQ</th>
                    <th>MODEL</th>
                    <th>VARIANT</th>
                    <th>FG PART NO.</th>
                    <th>SEAT</th> 
                </tr>
                <tr class="table-primary">
                    <th id="seq"></th>
                    <th id="model"></th>
                    <th id="variant"></th>
                    <th id="fgpart"></th>
                    <th id="seat">&nbsp;</th> 
                </tr>
            </table>

            <%--main body content--%>
            <div class="d-flex justify-content-center align-items-center animate__animated animate__flipInX">
                <div class="text-center" id="result_container">

                    <div class="d-flex justify-content-center align-items-start mt-5">
                        <img src="/image/man_with_scanner.png" height="300" class="my-4" />
                        <img src="/image/scaning.gif" width="150" class="my-4" />
                    </div> 
                    
                        <asp:TextBox ID="barcode_input" runat="server" AutoPostBack="true" CssClass="form-control m-auto" Onchange="return" Width="300"></asp:TextBox>
                </div>
            </div>


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
                            var user_login_id = $(this).val()
                            if (e.key == "Enter") {

                                //this is for indecate scannerbadge 
                                localStorage.setItem("1min", Date.now() + 60000)

                                $.ajax({
                                    type: "POST",
                                    url: "print_build_ticket.aspx/UserLogin",
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
                                url: "print_build_ticket.aspx/UserLogout",
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
                            <button type="button" class="dropdown-item" onclick="localStorage.removeItem('station') || location.reload() ">Reset Station</button>
                            <button type="button" class="dropdown-item text-danger" onclick="handleLogout()">Logout</button>
                        </div>
                    </div>
                </div>

            </div>


        </div>
    </form>
</body>
</html>
