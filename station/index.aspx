<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.station.Index" %>

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
        var build_ticket = ""
        var fgpart = ""
        var sequence_number = ""
        var isValidBuildTicket = false
        var user_details = {}
        var model_details = {} 
        var plcStation = ""
        var task_list = []
        var bom_list = []
        var isBuiltTicketFunctionSucces = false
        var torque_attemp = 0; 
        var PrinterConnected = false
        var dcToolIp = ""
        
         

        $(document).ready(function () {   

            //checking pc is conected to station or not 
            if (station == null) {
                $("#station_modal").css({ display: 'grid' });
            } else {
                $("#station_modal").css({ display: 'none' }); 
                //checking if station assigned for build ticket then redirect build ticket page 
                location.href = station.replace("-", "").toLowerCase() + ".aspx" 

            }
             
        }) 
          
        //alert toast function for notification 
        const Toast = Swal.mixin({
            toast: true,
            position: "bottom-end",
            showConfirmButton: false,
            timer: 3000,
            background:"yellow",
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

    </script>
    <style>
        input {
            opacity: 0;
        }

        #task_list_container tr {
            height: 46px;
            font-size: 20px; 
        }  
         #station_modal {
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
                        <b class="station_name">Station Description</b>
                    </big>
                    <big class="text-light animate__animated animate__bounceInDown ">
                        <img src="../image/icon/user.png" height="20" />
                        <b id="current_user">Current User</b>
                    </big>
                </div>

                <div class="text-center bg-secondary px-3 py-1" style="height: 60px;">
                    <b class="text-light">STATION-1R-10
                        <br />
                        <span id="current_time"></span></b>
                </div>

                <div class="text-center px-3 py-1" style="height: 60px;">
                    <span class="badge bg-danger" id="database_badge">DATABASE</span>
                    <span class="badge bg-danger" id="dctool_badge">DC TOOLS</span> 
                    <br />
                    <span class="badge bg-danger" id="plc_badge">PLC</span>
                    <span class="badge bg-danger" id="scanner_badge">SCANNER</span>
                </div>
            </div>

            <%--script to show current date--%>
            <script> $("#current_time").text(new Date().toISOString().split("T")[0]) </script>

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
             

            <%--models for notification--%>
            <div id="modal_container">
                <%--code for assign station on local storage--%>
                <div id="station_modal" style="z-index: 99;">
                    <div class="p-5 bg-light shadow rounded" style="width: 600px;">
                        <h3 class="text-danger mb-4">Make this PC a station.</h3>
                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); grid-gap: 10px;">
                            <%int[] stArr = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,16,14,15 };
                                foreach (var i in stArr) { %>
                            <% if (i == 0) { %>
                                <button class="btn btn-primary" style="width: 100%;" onclick="localStorage.setItem('station','Station-<%=i %>') || location.reload()"> Built Ticket Station </button>
                            <%  } else if (i == 16) {  %>
                                <button class="btn btn-danger" style="width: 100%;" onclick="localStorage.setItem('station','Station-<%=i %>') || location.reload()"> Rework Station </button>
                            <% }  else { %>
                                <button class="btn btn-secondary btn-lg" onclick="localStorage.setItem('station','Station-<%=i %>') || location.reload()">MES OP<%=i %></button>
                            <% } %>
                            <% } %>
                        </div>
                    </div>
                </div>  
            </div>

            <%--dropdown for setting--%>
            <div style="position: fixed; bottom: 0; right: 0; margin: 30px; ">
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
