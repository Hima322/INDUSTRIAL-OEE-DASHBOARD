<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionData.aspx.cs" Inherits="WebApplication2.production.modelselection" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Production Data</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: #f4f7fc;
            margin: 0;
            padding: 0;
        }
        .container-box {
            max-width: 1200px;
            margin: 40px auto;
            background: #fff;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
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
            font-size: 22px;
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
            padding: 8px 18px;
            transition: 0.3s;
            font-weight: 600;
            font-size: 14px;
        }
        .btn-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,114,255,0.4);
        }
        .section-title {
            font-weight: 600;
            color: #0d47a1;
            margin-top: 30px;
            margin-bottom: 10px;
        }
        .overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.4);
            backdrop-filter: blur(6px);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .popup {
            background: #fff;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.25);
            text-align: center;
            width: 90%;
            max-width: 400px;
            animation: zoomIn 0.3s ease;
        }
        .popup h5 {
            color: #0072ff;
            font-weight: 700;
            margin-bottom: 20px;
        }
        @keyframes zoomIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        @media (max-width: 768px) {
            .btn-custom {
                width: 100%;
                margin-top: 5px;
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
                <h4><i class="fa fa-industry me-2"></i>Production Reports</h4>
            </div>

            <!-- Filters -->
            <div class="row g-3 align-items-end">
                <div class="col-12 col-md-3">
                    <label class="form-label">Search Type</label>
                    <select id="ddlSearchType" class="form-select">
                        <option value="range">Date Range</option>
                        <option value="shift">Date + Shift</option>
                    </select>
                </div>
                <div class="col-12 col-md-3 range-fields">
                    <label class="form-label">Date From</label>
                    <input type="date" id="txtDateFrom" class="form-control" />
                </div>
                <div class="col-12 col-md-3 range-fields">
                    <label class="form-label">Date To</label>
                    <input type="date" id="txtDateTo" class="form-control" />
                </div>
                <div class="col-12 col-md-3 shift-fields" style="display:none;">
                    <label class="form-label">Date</label>
                    <input type="date" id="txtShiftDate" class="form-control" />
                </div>
                <div class="col-12 col-md-3 shift-fields" style="display:none;">
                    <label class="form-label">Shift</label>
                    <select id="ddlShift" class="form-select">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                    </select>
                </div>
                <div class="col-12 col-md-auto">
                    <button type="button" id="btnShow" class="btn btn-custom"><i class="fa fa-eye me-1"></i> Show</button>
                </div>
                <div class="col-12 col-md-auto">
                    <button type="button" id="btnDownload" class="btn btn-custom"><i class="fa fa-download me-1"></i> Download</button>
                </div>
            </div>

            <!-- Table 1 -->
            <h5 class="section-title">Production Data</h5>
            <div class="table-responsive table-container" id="tableArea1">
                <table class="table table-bordered table-hover">
                    <thead class="table-primary text-white">
                        <tr>
                            <th>DateTime</th>
                            <th>Shift</th>
                            <th>Size</th>
                            <th>Production</th>
                            <th>Running Time</th>
                            <th>Breakdown Time</th>
                            <th>Standby Time</th>
                            <th>Manual Mode Time</th>
                            <th>Superviser Name</th>

                            <th>Rejected Part</th>
                            <th>Remarks</th>
                        </tr>
                    </thead>
                    <tbody id="ProductionAlarm">
                        <tr><td colspan="9">Click "Show" to load data</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="text-end mt-3">
                <button type="button" id="btnExcel1" class="btn btn-custom"><i class="fa fa-file-excel me-1"></i> Excel</button>
                <button type="button" id="btnPdf1" class="btn btn-custom"><i class="fa fa-file-pdf me-1"></i> PDF</button>
            </div>

            <!-- Table 2 -->
            <h5 class="section-title">Production Summary</h5>
            <div class="table-responsive table-container" id="tableArea2">
                <table class="table table-bordered table-hover">
                    <thead class="table-primary text-white">
                        <tr>
                            <th>Date</th>
                            <th>Shift</th>
                            <th>Duration</th>
                            <th>Total Production</th>
                        </tr>
                    </thead>
                    <tbody id="ProductionSummary">
                        <tr><td colspan="4">Click "Show" to load production summary</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="text-end mt-3">
                <button type="button" id="btnExcelSummary" class="btn btn-custom"><i class="fa fa-file-excel me-1"></i> Excel</button>
                <button type="button" id="btnPdfSummary" class="btn btn-custom"><i class="fa fa-file-pdf me-1"></i> PDF</button>
            </div>

        </div>
    </form>

    <!-- Popup -->
    <div class="overlay" id="downloadPopup">
        <div class="popup">
            <h5><i class="fa fa-file-arrow-down"></i> Choose Download Format</h5>
            <button type="button" class="btn btn-custom mb-2" id="downloadPdf"><i class="fa fa-file-pdf me-1"></i> PDF</button>
            <button type="button" class="btn btn-custom mb-2" id="downloadExcel"><i class="fa fa-file-excel me-1"></i> Excel</button><br />
            <button type="button" class="btn btn-outline-secondary mt-3" id="closePopup"><i class="fa fa-times me-1"></i> Cancel</button>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>

    <script>
        var dataLoaded1 = false;
        var dataLoaded2 = false;

        $("#ddlSearchType").change(function () {
            var type = $(this).val();
            if (type === "range") {
                $(".range-fields").show();
                $(".shift-fields").hide();
            } else {
                $(".range-fields").hide();
                $(".shift-fields").show();
            }
        });

        $("#btnShow").click(function () {
            loadProductionData();
            loadProductionSummary();
        });

        $("#btnDownload").click(function () {
            if (!dataLoaded1 && !dataLoaded2) {
                alert("Please click Show first.");
                return;
            }
            $("#downloadPopup").css("display", "flex").hide().fadeIn(200);
        });

        $("#closePopup").click(function () {
            $("#downloadPopup").fadeOut(200);
        });

        function loadProductionData() {
            var searchType = $("#ddlSearchType").val();
            var payload = {};
            if (searchType === "range") {
                payload = {
                    dateFrom: $("#txtDateFrom").val(),
                    dateTo: $("#txtDateTo").val(),
                    shift: null
                };
            } else {
                payload = {
                    dateFrom: $("#txtShiftDate").val(),
                    dateTo: $("#txtShiftDate").val(),
                    shift: $("#ddlShift").val()
                };
            }

            $.ajax({
                type: "POST",
                url: "ProductionData.aspx/GetProductionData",
                data: JSON.stringify(payload),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var tbody = $("#ProductionAlarm");
                    tbody.empty();
                    if (response.d && response.d.length > 0) {
                        var totalProd = 0;
                        response.d.forEach(function (item) {
                            tbody.append(
                                `<tr>
                                <td>${item.DateTime}</td>
                                <td>${item.Shift}</td>
                                <td>${item.RunningSize}</td>
                                <td>${item.TotalProduction}</td>
                                <td>${item.TotalRunningTime}</td>
                                <td>${item.TotalBDtime}</td>
                                <td>${item.StandByTime}</td>
                                <td>${item.ManualModeTime}</td>
                                <td>${item.SupervisorName}</td>
                                <td>${item.RejectPart}</td>
                                <td>${item.Remarks}</td>
                            </tr>`
                            );
                            totalProd += item.TotalProduction;
                        });
                        tbody.append(
                            `<tr class="fw-bold bg-light">
                            <td colspan="3" class="text-end">Total</td>
                            <td>${totalProd}</td><td colspan="5"></td>
                        </tr>`
                        );
                        dataLoaded1 = true;
                    } else {
                        tbody.append("<tr><td colspan='9'>No records found</td></tr>");
                        dataLoaded1 = false;
                    }
                },
                error: function () {
                    alert("Error loading production data.");
                }
            });
        }

        function loadProductionSummary() {
            var searchType = $("#ddlSearchType").val();
            var payload = {};
            if (searchType === "range") {
                payload = {
                    dateFrom: $("#txtDateFrom").val(),
                    dateTo: $("#txtDateTo").val(),
                    shift: null
                };
            } else {
                payload = {
                    dateFrom: $("#txtShiftDate").val(),
                    dateTo: $("#txtShiftDate").val(),
                    shift: $("#ddlShift").val()
                };
            }

            $.ajax({
                type: "POST",
                url: "ProductionData.aspx/GetProductionSummary",
                data: JSON.stringify(payload),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var tbody = $("#ProductionSummary");
                    tbody.empty();
                    if (response.d && response.d.length > 0) {
                        response.d.forEach(function (item) {
                            tbody.append(
                                `<tr>
                                <td>${item.DateTime}</td>
                                <td>${item.Shift}</td>
                                <td>${item.Duration}</td>
                                <td>${item.TotalProduction}</td>
                            </tr>`
                            );
                        });
                        dataLoaded2 = true;
                    } else {
                        tbody.append("<tr><td colspan='4'>No records found</td></tr>");
                        dataLoaded2 = false;
                    }
                },
                error: function () {
                    alert("Error loading production summary.");
                }
            });
        }

        $("#downloadExcel").click(function () {
            // We'll export Table1 (or you may pick one)
            const table = document.querySelector("#tableArea1 table");
            if (!table) return alert("No data to download");
            const wb = XLSX.utils.table_to_book(table, { sheet: "Report" });
            XLSX.writeFile(wb, "Report.xlsx");
            $("#downloadPopup").fadeOut(200);
        });

        $("#downloadPdf").click(function () {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('l', 'pt', 'a4');
            doc.text("Report", 40, 40);
            doc.autoTable({ html: "#tableArea1 table", startY: 60 });
            doc.save("Report.pdf");
            $("#downloadPopup").fadeOut(200);
        });

        $("#btnExcel1").click(function () {
            if (!dataLoaded1) return alert("Please load Production Data first.");
            const wb = XLSX.utils.table_to_book(document.querySelector("#tableArea1 table"), { sheet: "Production Data" });
            XLSX.writeFile(wb, "ProductionData.xlsx");
        });

        $("#btnPdf1").click(function () {
            if (!dataLoaded1) return alert("Please load Production Data first.");
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('l', 'pt', 'a4');
            doc.text("Production Data Report", 40, 40);
            doc.autoTable({ html: "#tableArea1 table", startY: 60 });
            doc.save("ProductionData.pdf");
        });

        $("#btnExcelSummary").click(function () {
            if (!dataLoaded2) return alert("Please load Production Summary first.");
            const wb = XLSX.utils.table_to_book(document.querySelector("#tableArea2 table"), { sheet: "Production Summary" });
            XLSX.writeFile(wb, "ProductionSummary.xlsx");
        });

        $("#btnPdfSummary").click(function () {
            if (!dataLoaded2) return alert("Please load Production Summary first.");
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('p', 'pt', 'a4');
            doc.text("Production Summary Report", 40, 40);
            doc.autoTable({ html: "#tableArea2 table", startY: 60 });
            doc.save("ProductionSummary.pdf");
        });
    </script>

</body>
</html>
