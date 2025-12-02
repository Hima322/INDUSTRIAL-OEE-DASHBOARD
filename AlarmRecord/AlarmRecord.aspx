<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AlarmRecord.aspx.cs" Inherits="WebApplication2.AlarmRecord.AlarmRecord" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Alarm Record Data</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Bootstrap -->
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <script src="../js/libs/bootstrap.bundle.min.js"></script>

    <!-- jQuery -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

    <!-- XLSX, jsPDF, AutoTable -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: #f3f6fd;
            margin: 0;
            padding: 0;
        }

        .container-box {
            max-width: 1200px;
            margin: 40px auto;
            background: #fff;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        .header-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            margin-bottom: 25px;
        }

            .header-bar h4 {
                font-weight: 700;
                color: #0d47a1;
                margin: 0;
            }

        .back-icon {
            position: absolute;
            left: 0;
            font-size: 24px;
            color: #0072ff;
            cursor: pointer;
            transition: 0.3s;
        }

            .back-icon:hover {
                color: #00c6ff;
                transform: scale(1.1);
            }

        .btn-custom {
            background: linear-gradient(135deg, #0072ff, #00c6ff);
            border: none;
            border-radius: 8px;
            color: #fff;
            padding: 10px 18px;
            transition: all 0.3s ease;
            font-weight: 600;
        }

            .btn-custom:hover {
                transform: translateY(-2px);
                box-shadow: 0 0 15px rgba(0, 150, 255, 0.4);
            }

        .table-container {
            margin-top: 25px;
            overflow-y: auto;
            max-height: 420px;
            border-radius: 12px;
            border: 1px solid #ddd;
        }

        table {
            width: 100%;
            text-align: center;
            border-collapse: collapse;
        }

        thead {
            background: #0072ff;
            color: #fff;
            position: sticky;
            top: 0;
        }

        th, td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }

        tr:hover {
            background-color: #f1f7ff;
        }

        /* Overlay (full screen, center content) */
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            display: none;
            justify-content: center; /* Horizontal center */
            align-items: center; /* Vertical center */
            z-index: 9999;
        }

        /* Popup box */
        .popup {
            background: #fff;
            padding: 25px 30px;
            border-radius: 12px;
            width: 320px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.2);
            animation: popupShow 0.25s ease;
        }

        /* Animation */
        @keyframes popupShow {
            from {
                transform: scale(0.8);
                opacity: 0;
            }

            to {
                transform: scale(1);
                opacity: 1;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="container-box">

            <!-- Header -->
            <div class="header-bar">
                <i class="fa fa-arrow-left back-icon" onclick="window.history.back()"></i>
                <h4><i class="fa fa-bell"></i>Alarm Record Data</h4>
            </div>

            <!-- Filter Section -->
            <div class="row g-3 align-items-end">

                <div class="col-12 col-md-3">
                    <label>Search Type:</label>
                    <select id="ddlSearchType" class="form-select">
                        <option value="range">Date Range</option>
                        <option value="shift">Date + Shift</option>
                    </select>
                </div>

                <div class="col-12 col-md-3 range-fields">
                    <label>Date From:</label>
                    <input type="date" id="txtDateFrom" class="form-control" />
                </div>

                <div class="col-12 col-md-3 range-fields">
                    <label>Date To:</label>
                    <input type="date" id="txtDateTo" class="form-control" />
                </div>

                <div class="col-12 col-md-3 shift-fields" style="display: none;">
                    <label>Date:</label>
                    <input type="date" id="txtShiftDate" class="form-control" />
                </div>

                <div class="col-12 col-md-3 shift-fields" style="display: none;">
                    <label>Shift:</label>
                    <select id="ddlShift" class="form-select">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                    </select>
                </div>

                <div class="col-12 col-md-3 group-fields">
                    <label>Select Group:</label>
                    <select id="ddlGroup" class="form-select">
                        <option value="ALL">ALL</option>
                        <option value="MR">MR</option>
                        <option value="OR">OR</option>
                        <option value="OR2">OR2</option>
                        <option value="PC">PC</option>
                        <option value="MR1">MR1</option>
                        <option value="MR2">MR2</option>
                        <option value="SC">SC</option>
                    </select>
                </div>

                <div class="col-12 col-md-auto">
                    <button type="button" id="btnShow" class="btn btn-custom"><i class="fa fa-eye"></i>Show</button>
                </div>

                <div class="col-12 col-md-auto">
                    <button type="button" id="btnDownload" class="btn btn-custom"><i class="fa fa-download"></i>Download</button>
                </div>

            </div>

            <!-- Table Section -->
            <div class="table-container mt-4" id="tableArea">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>Start Time</th>
                            <th>End Time</th>
                            <th>Duration(MM:Sec)</th>
                            <th>Shift</th>
                            <th>Message</th>
                            <th>Alarm Group</th>
                        </tr>
                    </thead>
                    <tbody id="tbodyAlarm">
                        <tr>
                            <td colspan="6" class="text-center">Click "Show" to load data</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Download Popup -->
            <div class="overlay" id="downloadPopup">
                <div class="popup">
                    <h5><i class="fa fa-file-arrow-down"></i>Choose Download Format</h5>
                    <button type="button" class="btn btn-custom mb-2" id="downloadPdf"><i class="fa fa-file-pdf"></i>PDF</button>
                    <button type="button" class="btn btn-custom mb-2" id="downloadExcel"><i class="fa fa-file-excel"></i>Excel</button><br />
                    <button type="button" class="btn btn-outline-secondary mt-3" id="closePopup"><i class="fa fa-times"></i>Cancel</button>
                </div>
            </div>

        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- REQUIRED: Load jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        var dataLoaded = false;

        $(document).ready(function () {
            toggleFields();
            $("#ddlSearchType").change(toggleFields);
        });

        /*----------------------------------------------------------
            SHOW / HIDE FIELDS
        ----------------------------------------------------------*/
        function toggleFields() {
            var type = $("#ddlSearchType").val();

            if (type === "range") {
                $(".range-fields").show();   // From + To
                $(".shift-fields").hide();   // Hide Shift Fields
                $("#ddlShift").val("");      // Clear shift
            }
            else {
                $(".range-fields").hide();   // Hide Date-To
                $(".shift-fields").show();   // Show Shift Field
                $("#txtDateTo").val("");     // Clear Date-To
            }

            $(".group-fields").show();
        }

        /*----------------------------------------------------------
            LOAD ALARM DATA (AJAX CALL)
        ----------------------------------------------------------*/
        function loadAlarms() {

            var type = $("#ddlSearchType").val();

            var dataToSend = {
                dateFrom: type === "range" ? $("#txtDateFrom").val() : $("#txtShiftDate").val(),
                dateTo: type === "range" ? $("#txtDateTo").val() : $("#txtShiftDate").val(),
                shift: type === "range" ? "" : $("#ddlShift").val(),
                group: $("#ddlGroup").val()
            };

            console.log("Sending To Backend:", dataToSend);

            $.ajax({
                type: "POST",
                url: "AlarmRecord.aspx/GetAlarmData",
                data: JSON.stringify(dataToSend),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {

                    console.log("Backend Response: ", response);

                    var tbody = $("#tbodyAlarm");
                    tbody.empty();

                    if (response.d && response.d.length > 0) {

                        $.each(response.d, function (i, item) {
                            tbody.append(`
                        <tr>
                            <td>${item.Start_Date}</td>
                            <td>${item.End_date}</td>
                            <td>${item.Duration}</td>
                            <td>${item.ShiftData}</td>
                            <td>${item.Message}</td>
                            <td>${item.AlarmGroup}</td>
                        </tr>
                    `);
                        });

                        dataLoaded = true;
                    }
                    else {
                        tbody.append("<tr><td colspan='6' class='text-danger text-center'>No records found</td></tr>");
                        dataLoaded = false;
                    }
                },

                error: function (xhr, status, error) {
                    console.log("AJAX ERROR:", xhr.responseText, error);
                    alert("ERROR: Backend not responding.");
                }
            });
        }

        /*----------------------------------------------------------
            BUTTON CLICK EVENTS
        ----------------------------------------------------------*/
        $("#btnShow").click(function () {
            loadAlarms();
        });

        $("#btnDownload").click(function () {
            if (!dataLoaded) {
                alert("Please click Show first.");
                return;
            }
            $("#downloadPopup").fadeIn(200);
        });

        $("#closePopup").click(function () {
            $("#downloadPopup").fadeOut(200);
        });

        /*----------------------------------------------------------
            DOWNLOAD EXCEL
        ----------------------------------------------------------*/
        $("#downloadExcel").click(function () {
            const table = document.querySelector("#tableArea table");
            if (!table) return alert("No data");

            const wb = XLSX.utils.table_to_book(table, { sheet: "Alarm Data" });
            XLSX.writeFile(wb, "AlarmData.xlsx");

            $("#downloadPopup").fadeOut(200);
        });

        /*----------------------------------------------------------
            DOWNLOAD PDF
        ----------------------------------------------------------*/
        $("#downloadPdf").click(function () {

            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();

            const headers = [];
            $("#tableArea thead th").each(function () {
                headers.push($(this).text());
            });

            const data = [];
            $("#tbodyAlarm tr").each(function () {
                const row = [];
                $(this).find("td").each(function () {
                    row.push($(this).text());
                });
                data.push(row);
            });

            doc.text("Alarm Record Data", 14, 15);
            doc.autoTable({
                head: [headers],
                body: data,
                startY: 25
            });

            doc.save("AlarmData.pdf");
            $("#downloadPopup").fadeOut(200);
        });
    </script>


</body>
</html>

