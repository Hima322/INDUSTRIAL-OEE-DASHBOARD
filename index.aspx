<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.index" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Smart Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --primary: #0b63d5;
            --accent: #00c853;
            --warn: #ff9800;
            --danger: #e53935;
            --info: #2196f3;
            --bg: #f4f7fb;
        }

        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background: var(--bg);
            color: #1f2937;
            overflow-x: hidden;
        }

        /* Sidebar */
        #sidebar {
            position: fixed;
            top: 0;
            left: -250px;
            height: 100vh;
            width: 250px;
            background: linear-gradient(180deg, var(--primary), #37b6ff);
            color: #fff;
            display: flex;
            flex-direction: column;
            padding: 20px;
            box-shadow: 4px 8px 20px rgba(11,99,213,0.15);
            transition: all 0.4s ease;
            z-index: 1000;
        }

            #sidebar.active {
                left: 0;
            }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            font-size: 16px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.15);
        }

            .brand .logo {
                width: 40px;
                height: 40px;
                border-radius: 10px;
                background: #fff;
                color: var(--primary);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
            }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 10px;
            color: rgba(255,255,255,0.95);
            padding: 10px 15px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s;
        }

            .nav-link:hover, .nav-link.active {
                background: rgba(255,255,255,0.15);
                transform: translateX(4px);
            }

        /* Topbar */
        .topbar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 60px;
            background: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 18px;
            z-index: 999;
            transition: left 0.4s ease;
        }

        #sidebar.active ~ .topbar {
            left: 250px;
        }

        .menu-btn {
            border: none;
            background: transparent;
            font-size: 20px;
            color: var(--primary);
            cursor: pointer;
        }

        main.content {
            margin-left: 0;
            padding: 40px 20px 20px;
            transition: margin-left 0.4s ease;
        }

        #sidebar.active ~ .content {
            margin-left: 250px;
        }

        .status-card {
            background: #fff;
            border-radius: 12px;
            padding: 8px 14px; /* instead of 2px 16px 16px */
            min-width: 265px;
            height: 200px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            transition: transform 0.1s;
            text-align: center;
        }


            /* Headings inside card */
            .status-card h6 {
                font-weight: bold; /* make heading bold */
                font-size: 16px; /* slightly larger font */
                margin-bottom: 8px; /* reduce spacing */
            }

            /* Main values inside card */
            .status-card h3 {
                font-weight: bold; /* bold value */
                font-size: 28px;
                margin: 0;
                color: #0b63d5;
            }


            .status-card:hover {
                transform: scale(1.02);
            }

        /* .status-card h6 {
                font-size: 14px;
                margin-bottom: 5px;
            }

            .status-card h3 {
                font-size: 24px;
                margin: 0;
            }*/

        .indicator {
            width: 15px;
            height: 15px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 5px;
            transition: background-color 0.3s;
        }

        .bg-success {
            background-color: #28a745 !important;
        }
        /* Green */
        .bg-danger {
            background-color: #dc3545 !important;
        }
        /* Red */
        .bg-warning {
            background-color: #ffc107 !important;
        }
        /* Yellow */
        .bg-info {
            background-color: #17a2b8 !important;
        }
        /* Blue */
        .bg-secondary {
            background-color: #6c757d !important;
        }
        /* Gray for inactive */

        /* Blinking effect */
        .blink {
            animation: blink-animation 1s infinite;
        }

        @keyframes blink-animation {
            0%, 50%, 100% {
                opacity: 1;
            }

            25%, 75% {
                opacity: 0;
            }
        }

        /* Charts */
        .chart-box {
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            height: 100%;
        }

        footer {
            margin-top: 30px;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .row.flex-nowrap {
                flex-wrap: nowrap;
                overflow-x: auto;
            }
        }

        .indicator {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            transition: background-color 0.3s;
        }

        .blink {
            animation: blinkAnim 1s infinite;
        }

        .card h6, .card h3 {
            margin-top: 2px;
            margin-bottom: 2px;
        }



        @keyframes blink {
            50% {
                opacity: 0.4;
            }
        }

        @keyframes blinkAnim {
            0%, 50%, 100% {
                opacity: 1;
            }

            25%, 75% {
                opacity: 0.3;
            }
        }

        .bg-secondary {
            background-color: #6c757d !important;
        }

        .big-label {
            font-size: 48px; /* increase as needed */
            font-weight: bold; /* bold text */
            color: #0b63d5; /* optional color */
        }
    </style>

</head>
<body>
    <!-- Sidebar -->
    <aside id="sidebar">
        <div>
            <div class="brand">
                <img src="../image/companylogo.jpg" alt="ebco" style="height: 40px; width: auto;" />
                <%--<div class="logo">AB</div>--%>
                <div>ebco pvt ltd</div>
            </div>
            <nav class="mt-3">
                <a href="#" class="nav-link active"><i class="fa fa-home"></i><span>Home</span></a>
                <a href="../Production/ProductionData.aspx" class="nav-link"><i class="fa fa-chart-line"></i><span>Production</span></a>
                <a href="#" class="nav-link" id="MachineAlarm"><i class="fa fa-bell"></i><span>Machine Alarm</span></a>
                <a href="#" class="nav-link" id="reportsLink"><i class="fa fa-file-alt"></i><span>Change Size</span></a>
                <a href="../Setting/Setting.aspx" class="nav-link d-flex align-items-center">
                    <i class="fa fa-cog me-2"></i>
                    <span>Settings</span>
                </a>
                <a href="#" class="nav-link logout"><i class="fa fa-sign-out-alt"></i><span>Logout</span></a>
            </nav>
        </div>
    </aside>

    <!-- Topbar -->
    <header class="topbar">
        <button id="toggleMenu" class="menu-btn"><i class="fa fa-bars"></i>&nbsp;VASAI STDS ASSY PRODUCTION DATA</button>
        <div class="d-flex align-items-center gap-2">
            <small class="text-muted">Role,</small>
            <div id="userInitial" class="rounded-circle bg-primary text-white fw-bold d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">U</div>
            <strong id="userName">USER</strong>
            <span id="userRole" class="text-primary fw-bold">(Role)</span>
        </div>
    </header>

    <!-- Main Content -->
    <main class="content container-fluid">
        <div class="row g-3 mt-3 flex-nowrap overflow-auto">
            <div class="col-auto">
                <div class="card p-1 text-center flex-shrink-0" style="width: 400px;">
                    <div>
                        <h6 class="fw-bold fs-5 text-secondary">Running Shift</h6>
                        <h3 class="fw-bold fs-2 text-primary">
                            <asp:Label ID="RunningShift" runat="server" Text="-"></asp:Label>
                        </h3>
                    </div>
                </div>
            </div>

            <div class="col-auto">
                <div class="card p-1 text-center flex-shrink-0" style="width: 400px;">
                    <div>
                        <h6 class="fw-bold fs-5 text-secondary">Running Model</h6>
                        <h3 class="fw-bold fs-2 text-primary">
                            <asp:Label ID="RunningModel" runat="server" Text="-"></asp:Label>
                        </h3>
                    </div>
                </div>
            </div>

            <div class="col-auto">
                <div class="card px-1 py-0 text-center flex-shrink-0" style="width: 400px;">


                    <div>
                        <h6 class="fw-bold fs-5 text-secondary">Machine Status</h6>
                        <h3 class="fw-bold fs-2 text-primary">
                            <asp:Label ID="MachineStaId" runat="server"></asp:Label>
                        </h3>
                    </div>
                    <div id="MachineStatus" class="mt-1">
                        <div class="indicator rounded-circle mx-auto" style="width: 38px; height: 38px;"></div>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="card p-1 text-center flex-shrink-0" style="width: 400px;">
                    <div>
                        <h6 class="fw-bold fs-5 text-secondary">Equipment Availibility</h6>
                        <h3 class="fw-bold fs-2 text-primary">
                            <asp:Label ID="OEELable" runat="server" Text="-"></asp:Label>
                        </h3>
                    </div>
                </div>
            </div>
        </div>



        <!-- Status Cards in Single Row -->
        <div class="row g-3 mt-0 flex-nowrap overflow-auto status-row">



            <div class="col-auto">
                <div class="status-card">
                    <div>
                        <h6>Monthly Target</h6>
                        <h3>
                            <asp:Label ID="lblMonthlyTarget" runat="server" Text="0" CssClass="big-label"></asp:Label></h3>
                        <h6>Monthly Production</h6>
                        <h3>
                            <asp:Label ID="lblMonthlyProduction" runat="server" Text="0" CssClass="big-label"></asp:Label></h3>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="status-card">

                    <div>
                        <h6>Current Shift Target</h6>
                        <h3>
                            <asp:Label ID="lblTodayTarget" runat="server" Text="0" CssClass="big-label"></asp:Label></h3>
                        <h6>Current Shift Production</h6>
                        <h3>
                            <asp:Label ID="lblTodayProduction" runat="server" Text="0" CssClass="big-label"></asp:Label></h3>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="status-card">
                    <div>
                        <h6>Running Time</h6>
                        <h3>
                            <asp:Label ID="lblRunningTime" runat="server" Text="0"></asp:Label></h3>
                    </div>
                    <div id="RunningIndicator">
                        <div class="indicator"></div>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="status-card">
                    <div>
                        <h6>Breakdown Time</h6>
                        <h3>
                            <asp:Label ID="lblBreakdownTime" runat="server" Text="0"></asp:Label></h3>
                    </div>
                    <div id="BDIndicator">
                        <div class="indicator"></div>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="status-card">
                    <div>
                        <h6>Standby Time</h6>
                        <h3>
                            <asp:Label ID="lblStandbyTime" runat="server" Text="0"></asp:Label></h3>
                    </div>
                    <div id="STDYIndicator">
                        <div class="indicator"></div>
                    </div>
                </div>
            </div>
            <div class="col-auto">
                <div class="status-card">
                    <div>
                        <h6>ManualMode Time</h6>
                        <h3>
                            <asp:Label ID="lblManualTime" runat="server" Text="0"></asp:Label></h3>
                    </div>
                    <div id="ManualModeIndicator">
                        <div class="indicator"></div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Charts -->
        <%-- <div class="row g-3 mt-3">
        <div class="col-12 col-lg-6">
            <div class="chart-box">
                <h6><i class="fa fa-bell text-danger"></i>Hourly Machine Alarms(Current Shift)</h6>
                <canvas id="chartAlarms"></canvas> </div>

        </div>
        <div class="col-12 col-lg-6">
            <div class="chart-box">
                <h6 ><i class="fa fa-chart-area text-primary"></i>Hourly Production(Current Shift)</h6>
                <canvas id="chartHourly"></canvas>

            </div>

        </div>

    </div>--%>
        <div class="d-flex gap-2 mt-3">
            <!-- Table: 25% -->
            <div style="flex: 0 0 20%;">
                <div class="card shadow-sm p-3" style="height: 350px; overflow-y: auto;">
                    <h6 class="fw-bold text-secondary mb-3"></h6>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered table-sm mb-0">
                            <thead class="table-dark">
                                <tr class="text-center">
                                    <th class="fw-bold fs-6">Model Name</th>
                                    <th class="fw-bold fs-6">Total Qty</th>
                                </tr>
                            </thead>
                            <tbody id="shiftProductionBody" class="text-center fw-medium">
                                <!-- AJAX will fill rows here -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Hourly Machine Alarms: 37.5% -->
            <div style="flex: 0 0 35%;">
                <div class="card shadow-sm p-3" style="height: 350px; display: flex; flex-direction: column;">
                    <h6 class="fw-bold text-danger mb-3">
                        <i class="fa fa-bell"></i>Hourly Machine Alarms (Current Shift)
                    </h6>
                    <div style="flex: 1; position: relative;">
                        <canvas id="chartAlarms"></canvas>
                    </div>
                </div>
            </div>

            <!-- Hourly Production: 42% -->
            <div style="flex: 0 0 42%;">
                <div class="card shadow-sm p-3" style="height: 350px; display: flex; flex-direction: column;">
                    <h6 class="fw-bold text-primary mb-3">
                        <i class="fa fa-chart-area"></i>Hourly Production (Current Shift)
                    </h6>
                    <div style="flex: 1; position: relative;">
                        <canvas id="chartHourly"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <!-- Blur overlay -->
        <div id="blurOverlay" style="opacity: 0; pointer-events: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; backdrop-filter: blur(12px); background: rgba(0,0,0,0.3); z-index: 9998; transition: opacity 0.5s;">
        </div>

        <!-- Popup -->
        <div id="alertPopup" style="opacity: 0; pointer-events: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); padding: 5vh 5vw; border-radius: 3vh; text-align: center; z-index: 9999; box-shadow: 0 0 3vh rgba(0,0,0,0.8); font-family: Arial, sans-serif; width: 70vw; max-width: 900px; height: 50vh; max-height: 500px; transition: opacity 0s;">
            <h2 id="popupTitle" style="margin-bottom: 3vh; font-size: 6vh; font-weight: bold; color: white;">Alert</h2>
            <p id="popupMessage" style="font-size: 5vh; font-weight: bold; color: white;">Message</p>
            <button onclick="closePopup()" style="margin-top: 3vh; padding: 1.5vh 3vw; font-size: 3.5vh; font-weight: bold; border: none; border-radius: 1vh; cursor: pointer;">Close</button>
        </div>






        <!-- Toast -->
        <div class="position-fixed top-0 end-0 p-3" style="z-index: 1100">
            <div id="liveToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="d-flex">
                    <div class="toast-body fw-semibold" id="toastMessage">Access Denied</div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        </div>

        <!-- Status Bar -->
        <div class="text-center py-2"
            style="position: fixed; bottom: 32px; left: 0; width: 100%; background: #e9ecef; border-top: 1px solid #ccc; font-size: 25px; font-weight: 800;">
            🖥️ Server:
    <span id="database_badge" class="badge bg-secondary ms-2 me-5">Checking...</span>

            ⚙️ PLC:
    <span id="plc_badge" class="badge bg-secondary ms-2">Checking...</span>
        </div>

        <!-- Footer -->
        <footer class="text-center text-muted small fw-bold py-2"
            style="position: fixed; bottom: 0; left: 0; width: 100%; background: #f8f9fa; border-top: 1px solid #dee2e6;">
            © AB-VISION CONTROL SYSTEM — Smart Dashboard
        </footer>
    </main>
    <script>
        function isPlcConnected() {
            $.ajax({
                type: "POST",
                url: "index.aspx/ISPLCONNECTED",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (res.d) {
                        $("#plc_badge").attr("class", "badge bg-success").text("Connectivity is OK");
                    } else {
                        $("#plc_badge").attr("class", "badge bg-danger").text("Connectivity is not  OK");
                    }

                },
                error: function () {
                    $("#plc_badge").attr("class", "badge bg-warning text-dark").text("Error");
                }
            });
        }

        function isdbConnected() {
            $.ajax({
                type: "POST",
                url: "index.aspx/ISDBCONNECTION",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (res.d.includes("Success")) {
                        $("#database_badge").attr("class", "badge bg-success").text("Connectivity is OK");
                    } else {
                        $("#database_badge").attr("class", "badge bg-danger").text("Connectivity is not  OK");
                    }
                },
                error: function () {
                    $("#database_badge").attr("class", "badge bg-warning text-dark").text("Error");
                }
            });
        }

        function refreshStatuses() {
            isdbConnected();
            isPlcConnected();
        }

        $(document).ready(function () {
            refreshStatuses();
            setInterval(refreshStatuses, 1000);
        });
    </script>
    <script>
        function showPopup(title, message) {
            const popup = document.getElementById('alertPopup');
            const overlay = document.getElementById('blurOverlay');

            document.getElementById('popupTitle').innerText = title;
            document.getElementById('popupMessage').innerText = message;

            // Message
            switch (message) {
                case "Maintenance Call": popup.style.background = "red"; break;
                case "Priventive Manintenance": popup.style.background = "red"; break;
                case "Planned Conversion": popup.style.background = "red"; popup.style.color = "red"; break;
                case "unplanned Conversion": popup.style.background = "red"; break;
                default: popup.style.background = "red"; break;
            }

            overlay.style.pointerEvents = "auto";
            popup.style.pointerEvents = "auto";
            overlay.style.opacity = "1";
            popup.style.opacity = "1";
        }

        function closePopup() {
            const popup = document.getElementById('alertPopup');
            const overlay = document.getElementById('blurOverlay');

            overlay.style.opacity = "0";
            popup.style.opacity = "0";
            overlay.style.pointerEvents = "none";
            popup.style.pointerEvents = "none";
        }

        function checkAlertMessage() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GetAlertMessage",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = response.d;
                    const code = data.Code;
                    const message = data.Message;

                    if (code > 0 && message !== "") {
                        showPopup("Alert", message);
                    } else {
                        closePopup(); // hide when Call = 0
                    }
                },
                error: function (err) {
                    console.error("Error checking alert:", err);
                }
            });
        }

        // Run every 5 seconds
        setInterval(checkAlertMessage, 5000);

        // Check on page load
        $(document).ready(function () {
            checkAlertMessage();
        });



    </script>
    <script>
        function updateAvailability() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GetAvailability",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    $('#<%= OEELable.ClientID %>').text(response.d);
                },
                error: function (err) {
                    console.log("Error fetching availability:", err);
                }
            });
        }

        // Update every 5 seconds
        $(document).ready(function () {
            updateAvailability();          // initial load
            setInterval(updateAvailability, 5000); // refresh every 5 sec
        });
    </script>
    <script>
        // --- On page load ---
        $(function () {
            const username = localStorage.getItem("admin");
            const role = localStorage.getItem("role");

            // If not logged in, go to login
            if (!username || !role) {
                window.location.href = "login.aspx";
                return;
            }

            const roleLower = role.toLowerCase();

            // Set user info
            $("#userName").text(username.toUpperCase());
            $("#userRole").text("(" + roleLower.charAt(0).toUpperCase() + roleLower.slice(1) + ")");
            $(".topbar small.text-muted").text(roleLower.charAt(0).toUpperCase() + roleLower.slice(1) + ",");

            // Logout
            $(".logout").click(function () {
                localStorage.clear();
                sessionStorage.removeItem("keepData");
                window.location.href = "login.aspx";
            });

            // Sidebar toggle
            $("#toggleMenu").click(() => $("#sidebar").toggleClass("active"));

            // Role-based access: Reports
            $("#reportsLink").click(function (e) {
                if (roleLower !== "administrator" && roleLower !== "supervisor") {
                    e.preventDefault();
                    showToast("❌ Only Admin can access Reports.");
                } else {
                    window.location.href = "../report/index.aspx";
                }
            });

            // Role-based access: Machine Alarm
            $("#MachineAlarm").click(function (e) {
                if (roleLower !== "administrator" && roleLower !== "supervisor") {
                    e.preventDefault();
                    showToast("❌ Only Admin & Supervisor can access Machine Alarm.");
                } else {
                    window.location.href = "../AlarmRecord/AlarmRecord.aspx";
                }
            });
        });

        // ✅ Only clear localStorage when browser/tab is closed (not on refresh)
        window.addEventListener("beforeunload", function () {
            // Mark that a refresh/navigation happened
            sessionStorage.setItem("keepData", "true");
        });

        window.addEventListener("load", function () {
            // If no "keepData" flag → means browser/tab was reopened → clear
            if (!sessionStorage.getItem("keepData")) {
                localStorage.clear();
            }
            // Always reset the flag after load
            sessionStorage.removeItem("keepData");
        });

        // Toast function
        function showToast(message, type = "danger") {
            const toastEl = $("#liveToast");
            const toastMsg = $("#toastMessage");
            toastMsg.text(message);
            toastEl
                .removeClass("text-bg-danger text-bg-success text-bg-warning")
                .addClass(`text-bg-${type}`);
            const toast = new bootstrap.Toast(toastEl[0]);
            toast.show();
        }
    </script>

    <script>
        $(document).ready(function () {
            loadDashboard();

            function loadDashboard() {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/GetDashboardDataFromFile",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;

                        $("#lblTodayProduction").text(data.Production);
                        $("#lblRunningTime").text(data.RunningTime);
                        $("#lblBreakdownTime").text(data.BDTime);
                        $("#lblStandbyTime").text(data.StandbyTime);
                        $("#lblManualTime").text(data.ManualTime);

                        updateIndicator("#RunningIndicator .indicator", data.RunningStatus, "success");
                        updateIndicator("#BDIndicator .indicator", data.BDStatus, "danger");
                        updateIndicator("#STDYIndicator .indicator", data.StandbyStatus, "warning");
                        updateIndicator("#ManualModeIndicator .indicator", data.ManualStatus, "info");


                        updateMachineStatus("#MachineStatus .indicator", data.RunningStatus);
                    },
                    error: function (err) {
                        console.error("Error loading dashboard:", err);
                    }
                });
            }
            function updateMachineStatus(selector, status) {
                var indicator = $(selector);

                // Remove all previous color + blink classes
                indicator.removeClass("bg-success bg-danger blink");
                console.log(status)
                if (status == 1) {
                    indicator.addClass("bg-success blink"); // green + blink
                } else {
                    indicator.addClass("bg-danger blink"); // red + blink
                }
            }


            function updateIndicator(selector, status, type) {
                var indicator = $(selector);

                // Remove previous classes
                indicator.removeClass("bg-success bg-danger bg-warning bg-info bg-secondary blink");

                if (status == 1) {

                    indicator.addClass(`bg-${type} blink`);
                    indicator.addClass('bg')
                } else {
                    indicator.addClass("bg-white");
                }
            }

            // Auto-refresh every 10 seconds
            setInterval(loadDashboard, 10000);
        });

    </script>
    <script>
        $(document).ready(function () {
            loadShiftProduction();
            GETCURRENTSHIFTTARGET();
            GETCURRENTMONTHLYTARGET();
            setInterval(function () {
                 loadShiftProduction();
                GETCURRENTMONTHLYTARGET();
                GETCURRENTSHIFTTARGET();
            }, 1000);
        });

        function loadShiftProduction() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GetShiftProduction",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var tbody = $('#shiftProductionBody');
                    tbody.empty();
                    response.d.forEach(function (item) {
                        tbody.append(
                            '<tr>' +
                            '<td>' + item.RunningSize + '</td>' +
                            '<td>' + item.TotalQty + '</td>' +
                            '</tr>'
                        );
                    });
                },
                error: function (err) {
                    console.log("Error fetching shift production:", err);
                }
            });
        }


        function GETCURRENTSHIFTTARGET() {
            const runningShift = $("#RunningShift").val() || $("#RunningShift").text().trim();
            console.log("Running Shift:", runningShift);

            $.ajax({
                type: "POST",
                url: "index.aspx/GetShiftTarget",
                data: JSON.stringify({ currentShift: runningShift }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const targetValue = response.d;
                    $("#lblTodayTarget").text(targetValue);
                },
                error: function (err) {
                    console.error("Error fetching shift target:", err);
                }
            });
        }
        function GETCURRENTMONTHLYTARGET() {
            const runningShift = $("#RunningShift").val() || $("#RunningShift").text().trim();
            console.log("Running Shift:", runningShift);

            $.ajax({
                type: "POST",
                url: "index.aspx/GetMonthlyTarget",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const targetValue = response.d;
                    $("#lblMonthlyTarget").text(targetValue);
                },
                error: function (err) {
                    console.error("Error fetching shift target:", err);
                }
            });
        }


    </script>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>

    <script>
        function loadVarData() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GetVarData",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = response.d;
                    $("#<%= RunningShift.ClientID %>").text(data.RunningShift);
                    $("#<%= RunningModel.ClientID %>").text(data.RunningModel);
                },
                error: function (err) {
                    console.error("Error fetching data:", err);
                }
            });
        }

        $(document).ready(function () {
            loadVarData();
            setInterval(loadVarData, 60000);
        });
    </script>

    <script>
        $(document).ready(function () {

            // ---- Breakdown Time Chart ----
            // ---- Alarm Chart ----
            // --- Common Function: Generate Time Labels Based on Shift ---
            function generateShiftLabels(shiftStart, shiftEnd) {
                let labels = [];
                let current = new Date(shiftStart);

                while (current < shiftEnd) {
                    let next = new Date(current);
                    next.setHours(current.getHours() + 1);
                    next.setMinutes(0);

                    // if shift start has minutes (e.g. 6:30), next will be 7:00
                    if (next > shiftEnd) next = new Date(shiftEnd);

                    labels.push(
                        `${current.getHours().toString().padStart(2, '0')}:${current.getMinutes().toString().padStart(2, '0')} - ${next.getHours().toString().padStart(2, '0')}:${next.getMinutes().toString().padStart(2, '0')}`
                    );

                    current = new Date(next);
                }

                return labels;
            }

            // --- Alarm Chart ---
            let alarmChart;

            function loadAlarmChart() {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/GetChartData",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const data = response.d.ShiftAlarms;
                        const machines = data.map(x => x.Machines);

                        let shiftStart = new Date(response.d.ShiftStart);
                        let shiftEnd = new Date(response.d.ShiftEnd);
                        let labels = generateShiftLabels(shiftStart, shiftEnd);

                        // Align backend data with time labels
                        let bdTimes = [];
                        let runTimes = [];

                        labels.forEach(lbl => {
                            let [startHr, startMin] = lbl.split(' - ')[0].split(':').map(Number);

                            // find matching record based 
                            let record = data.find(x => {
                                let hr = parseInt(x.HourRange.split(':')[0]);
                                return hr === startHr + 1;
                            });

                            bdTimes.push(record ? record.TotalBDTime : 0);
                            runTimes.push(record ? record.TotalRunTime : 0);
                        });

                        let ctx = document.getElementById('chartAlarms').getContext('2d');
                        if (alarmChart) alarmChart.destroy();

                        alarmChart = new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels,
                                datasets: [
                                    {
                                        label: 'Breakdown Time (Min)',
                                        data: bdTimes,
                                        borderColor: 'rgba(255, 99, 132, 1)',
                                        backgroundColor: 'rgba(255, 99, 132, 0.3)',
                                        borderWidth: 2,
                                        fill: false,
                                        tension: 0.3
                                    },
                                    {
                                        label: 'Running Time (Min)',
                                        data: runTimes,
                                        borderColor: 'rgba(54, 162, 235, 1)',
                                        backgroundColor: 'rgba(54, 162, 235, 0.3)',
                                        borderWidth: 2,
                                        fill: false,
                                        tension: 0.3
                                    }
                                ]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                interaction: { mode: 'index', intersect: false },
                                plugins: {
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                let hourMachines = machines[context.dataIndex];
                                                let lines = [`${context.dataset.label}: ${context.formattedValue} Min`];
                                                if (hourMachines) {
                                                    hourMachines.forEach(m => {
                                                        lines.push(`${m.Machine}: BD=${m.BDTime} | RT=${m.RunTime}`);
                                                    });
                                                }
                                                return lines;
                                            }
                                        }
                                    }
                                },
                                scales: {
                                    x: { title: { display: true, text: 'Hour Range' } },
                                    y: { beginAtZero: true, title: { display: true, text: 'Minutes' } }
                                }
                            }
                        });
                    },
                    error: err => console.error('Error loading chart:', err)
                });
            }


            // --- Production Chart ---
            let productionChart;

            function loadProductionChart() {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/GetHourlyProductionByShift",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const data = response.d.Data;
                        let shiftStart = new Date(response.d.ShiftStart);
                        let shiftEnd = new Date(response.d.ShiftEnd);
                        let labels = generateShiftLabels(shiftStart, shiftEnd);

                        let values = [];

                        labels.forEach(lbl => {
                            let [startHr, startMin] = lbl.split(' - ')[0].split(':').map(Number);
                            let record = data.find(x => {
                                let hr = parseInt(x.HourRange.split(':')[0]);
                                return hr === startHr + 1;
                            });
                            values.push(record ? record.Total : 0);
                        });

                        let ctx = document.getElementById('chartHourly').getContext('2d');
                        if (productionChart) productionChart.destroy();

                        productionChart = new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels,
                                datasets: [{
                                    label: 'Total Production',
                                    data: values,
                                    backgroundColor: 'rgba(54, 162, 235, 0.6)',
                                    borderColor: 'rgba(0, 123, 255, 1)',
                                    borderWidth: 1
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { display: false },
                                    tooltip: {
                                        enabled: true,
                                        callbacks: { label: ctx => `Count: ${ctx.raw}` }
                                    },
                                    datalabels: {
                                        color: '#000',
                                        font: { weight: 'bold', size: 13 },
                                        anchor: 'end',
                                        align: 'end',
                                        offset: 2,
                                        formatter: v => v > 0 ? v : ''
                                    }
                                },
                                scales: {
                                    x: {
                                        title: { display: true, text: 'Hour Range' },
                                        ticks: { font: { size: 12 } }
                                    },
                                    y: {
                                        title: { display: true, text: 'Production Count' },
                                        beginAtZero: true,
                                        ticks: { stepSize: 10, font: { size: 12 } }
                                    }
                                }
                            },
                            plugins: [ChartDataLabels]
                        });
                    },
                    error: err => console.error('Error loading production chart:', err)
                });
            }

            //let alarmChart;

            //function loadAlarmChart() {
            //    $.ajax({
            //        type: "POST",
            //        url: "index.aspx/GetChartData",
            //        data: '{}',
            //        contentType: "application/json; charset=utf-8",
            //        dataType: "json",
            //        success: function (response) {
            //            var data = response.d.ShiftAlarms;
            //            var machines = data.map(x => x.Machines);

            //            // Shift timings
            //            let shiftStart = new Date(response.d.ShiftStart);
            //            let shiftEnd = new Date(response.d.ShiftEnd);

            //            // Generate hour range labels exactly till shift end
            //            let labels = [];
            //            let current = new Date(shiftStart);
            //            while (current < shiftEnd) {
            //                let next = new Date(current);
            //                next.setHours(current.getHours() + 1);
            //                if (next > shiftEnd) next = new Date(shiftEnd);

            //                labels.push(
            //                    `${current.getHours().toString().padStart(2, '0')}:${current.getMinutes().toString().padStart(2, '0')} - ${next.getHours().toString().padStart(2, '0')}:${next.getMinutes().toString().padStart(2, '0')}`
            //                );
            //                current = next;
            //            }

            //            // --- FIX: Align hour properly ---
            //            let bdTimes = [];
            //            let runTimes = [];
            //            labels.forEach(lbl => {
            //                let hr = parseInt(lbl.split(':')[0]); // e.g., 15
            //                // Adjust +1 if backend uses hour END instead of START
            //                let record = data.find(x => parseInt(x.HourRange.split(':')[0]) === hr + 1);
            //                bdTimes.push(record ? record.TotalBDTime : 0);
            //                runTimes.push(record ? record.TotalRunTime : 0);
            //            });

            //            // Create chart
            //            var ctx = document.getElementById('chartAlarms').getContext('2d');
            //            if (alarmChart) alarmChart.destroy();

            //            alarmChart = new Chart(ctx, {
            //                type: 'line',
            //                data: {
            //                    labels: labels,
            //                    datasets: [
            //                        {
            //                            label: 'Breakdown Time (Min)',
            //                            data: bdTimes,
            //                            borderColor: 'rgba(255, 99, 132, 1)',
            //                            backgroundColor: 'rgba(255, 99, 132, 0.3)',
            //                            borderWidth: 2,
            //                            fill: false,
            //                            tension: 0.3
            //                        },
            //                        {
            //                            label: 'Running Time (Min)',
            //                            data: runTimes,
            //                            borderColor: 'rgba(54, 162, 235, 1)',
            //                            backgroundColor: 'rgba(54, 162, 235, 0.3)',
            //                            borderWidth: 2,
            //                            fill: false,
            //                            tension: 0.3
            //                        }
            //                    ]
            //                },
            //                options: {
            //                    responsive: true,
            //                    maintainAspectRatio: false,
            //                    interaction: { mode: 'index', intersect: false },
            //                    plugins: {
            //                        tooltip: {
            //                            callbacks: {
            //                                label: function (context) {
            //                                    let hourMachines = machines[context.dataIndex];
            //                                    let lines = [`${context.dataset.label}: ${context.formattedValue} Min`];
            //                                    if (hourMachines) {
            //                                        hourMachines.forEach(m => {
            //                                            lines.push(`${m.Machine}: BD=${m.BDTime} | RT=${m.RunTime}`);
            //                                        });
            //                                    }
            //                                    return lines;
            //                                }
            //                            }
            //                        }
            //                    },
            //                    scales: {
            //                        x: { title: { display: true, text: 'Hour Range' } },
            //                        y: { beginAtZero: true, title: { display: true, text: 'Minutes' } }
            //                    }
            //                }
            //            });
            //        },
            //        error: function (err) {
            //            console.error('Error loading chart:', err);
            //        }
            //    });
            //}



            //// ---- Hourly Production Chart ----
            //let productionChart;

            //function loadProductionChart() {
            //    $.ajax({
            //        type: "POST",
            //        url: "index.aspx/GetHourlyProductionByShift",
            //        data: '{}',
            //        contentType: "application/json; charset=utf-8",
            //        dataType: "json",
            //        success: function (response) {
            //            var data = response.d.Data;

            //            // Shift timings
            //            let shiftStart = new Date(response.d.ShiftStart);
            //            let shiftEnd = new Date(response.d.ShiftEnd);

            //            // Generate hour range labels exactly till shift end
            //            let labels = [];
            //            let current = new Date(shiftStart);
            //            while (current < shiftEnd) {
            //                let next = new Date(current);
            //                next.setHours(current.getHours() + 1);
            //                if (next > shiftEnd) next = new Date(shiftEnd);

            //                labels.push(
            //                    `${current.getHours().toString().padStart(2, '0')}:${current.getMinutes().toString().padStart(2, '0')} - ${next.getHours().toString().padStart(2, '0')}:${next.getMinutes().toString().padStart(2, '0')}`
            //                );
            //                current = next;
            //            }

            //            // --- FIX: Align hour properly ---
            //            let values = [];
            //            labels.forEach(lbl => {
            //                let hr = parseInt(lbl.split(':')[0]);
            //                let record = data.find(x => parseInt(x.HourRange.split(':')[0]) === hr + 1);
            //                values.push(record ? record.Total : 0);
            //            });

            //            // Create chart
            //            var ctx = document.getElementById('chartHourly').getContext('2d');
            //            if (productionChart) productionChart.destroy();

            //            productionChart = new Chart(ctx, {
            //                type: 'bar',
            //                data: {
            //                    labels: labels,
            //                    datasets: [{
            //                        label: 'Total Production',
            //                        data: values,
            //                        backgroundColor: 'rgba(54, 162, 235, 0.6)',
            //                        borderColor: 'rgba(0, 123, 255, 1)',
            //                        borderWidth: 1
            //                    }]
            //                },
            //                options: {
            //                    responsive: true,
            //                    maintainAspectRatio: false,
            //                    plugins: {
            //                        legend: { display: false },
            //                        tooltip: {
            //                            enabled: true,
            //                            callbacks: {
            //                                label: function (context) {
            //                                    return `Count: ${context.raw}`;
            //                                }
            //                            }
            //                        },
            //                        datalabels: {
            //                            color: '#000',
            //                            font: { weight: 'bold', size: 13 },
            //                            anchor: 'end',
            //                            align: 'end',
            //                            offset: 2,
            //                            formatter: function (value) {
            //                                return value > 0 ? value : '';
            //                            }
            //                        }
            //                    },
            //                    scales: {
            //                        x: {
            //                            title: { display: true, text: 'Hour Range' },
            //                            ticks: { font: { size: 12 } }
            //                        },
            //                        y: {
            //                            title: { display: true, text: 'Production Count' },
            //                            beginAtZero: true,
            //                            ticks: { stepSize: 10, font: { size: 12 } }
            //                        }
            //                    }
            //                },
            //                plugins: [ChartDataLabels]
            //            });
            //        },
            //        error: function (err) {
            //            console.error('Error loading production chart:', err);
            //        }
            //    });
            //}


            // ---- Initial load ----
            loadAlarmChart();
            loadProductionChart();


            // ---- Auto refresh every 10 minutes ----
            setInterval(loadAlarmChart, 600000);
            setInterval(loadProductionChart, 600000);
        });
    </script>



    <script>
        $(document).ready(function () {

            loadDashboard();
            loadShiftProduction();
            setInterval(loadDashboard, 5000); // refresh every 5 seconds

            function loadDashboard() {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/GetDashboardDataFromFile",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;

                        $("#lblTodayProduction").text(data.TodayProduction);
                        $("#lblMonthlyProduction").text(data.MonthlyProduction);
                        $("#lblRunningTime").text(data.RunningTime);
                        $("#lblBreakdownTime").text(data.BDTime);
                        $("#lblStandbyTime").text(data.StandbyTime);
                        $("#lblManualTime").text(data.ManualTime);



                        var runningIndicator = $("#cardRunning .indicator");
                        runningIndicator.removeClass("blink bg-success bg-secondary");

                        if (data.RunningStatus == 1) {
                            runningIndicator.addClass("bg-success blink");
                        } else {
                            runningIndicator.addClass("bg-secondary");
                        }
                    },
                    error: function (err) {
                        console.error(err);
                    }
                });
            }
        });
    </script>


</body>
</html>
