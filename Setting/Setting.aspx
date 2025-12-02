<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Setting.aspx.cs" Inherits="WebApplication2.Setting.Setting" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Shift Production Settings</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


    <style>
        body { background:#eef2f7; padding:25px; }
        .card { border-radius:14px; }
        th { background:#0d6efd; color:white; }
        .inline-edit-row { background:#fff3cd !important; }
    </style>
</head>
<body>

<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />


<div class="container">

    <!-- HEADER -->
 <div class="d-flex align-items-center mb-4">
    <i class="fa fa-arrow-left me-3" style="cursor:pointer;" onclick="window.history.back()"></i>
    <h3 class="fw-bold mb-0">⚙️ Shift Production Settings</h3>
</div>


    <!-- SEARCH CARD -->
    <div class="card shadow p-3 mb-4">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label fw-semibold">Select Date</label>
                <input type="date" id="txtDate" class="form-control" />
            </div>
            <div class="col-md-2">
                <button type="button" onclick="loadData()" class="btn btn-primary w-100 fw-semibold">Search</button>
            </div>
        </div>
    </div>

    <!-- TABLE -->
    <div class="card shadow">
        <div class="table-responsive p-3">
            <table class="table table-bordered align-middle text-center">
                <thead>
                    <tr>
                        <th>Date Time</th>
                        <th>Shift</th>
                        <th>Running Size</th>
                        <th>Total Production</th>
                        <th>Superviser Name</th>
                        <th>Reject Part</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblBody"></tbody>
            </table>
        </div>
    </div>

    <!-- TARGET SECTION -->
    <div class="card shadow p-3 mt-4">
        <h5 class="fw-bold mb-3">🎯 Set Target</h5>

        <div class="row g-2">
            <div class="col-md-3">
                <select id="shiftSelect" class="form-select">
                    <option value="">Select Shift</option>
                    <option value="TargetAshift">1</option>
                    <option value="TargetBshift">2</option>
                    <option value="TargetCshift">3</option>
                    <option value="TargetMonth">Month</option>
                </select>
            </div>
            <div class="col-md-3">
                <input type="number" placeholder="Enter Target" id="targetValue" class="form-control" />
            </div>
            <div class="col-md-2">
                <button type="button" onclick="saveTarget()" class="btn btn-success w-100">Save</button>
            </div>

        </div>
    </div>
   <!-- 👤 Supervisor -->
        <div class="card p-3 mt-4">
            <h5 class="fw-bold">🧑‍💼 Supervisor</h5>

            <div class="row g-2">
                <div class="col-md-4">
                    <input type="text" id="supervisorName" maxlength="50" class="form-control" placeholder="Enter Supervisor Name">
                </div>

                <div class="col-md-2">
                    <button type="button" onclick="saveSupervisor()" class="btn btn-primary w-100">Save</button>
                </div>
            </div>
        </div>

        <!-- 📝 Remarks -->
        <div class="card p-3 mt-4">
            <h5 class="fw-bold">📝 Remarks</h5>

            <div class="row g-2">
                <div class="col-md-4">
                    <input type="text" id="REMARK" maxlength="500" class="form-control" placeholder="Enter remark...">
                </div>

                <div class="col-md-2">
                    <button type="button" onclick="SaveRemark()" class="btn btn-primary w-100">Save</button>
                </div>
            </div>
        </div>

</div>



</form>

<!-- ✅ Toast -->
<div class="position-fixed top-0 end-0 p-3" style="z-index:9999;">
    <div id="toastMsg" class="toast text-bg-success border-0">
        <div class="d-flex">
            <div class="toast-body fw-bold" id="toastText">Updated</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>

    function showToast(msg, type = "success") {
        $("#toastMsg").removeClass("text-bg-danger text-bg-success")
            .addClass(type === "success" ? "text-bg-success" : "text-bg-danger");
        $("#toastText").text(msg);
        new bootstrap.Toast(document.getElementById("toastMsg")).show();
    }

    function loadData() {
        const dt = $("#txtDate").val();
        if (!dt) return showToast("Please select a date", "error");

        PageMethods.GetTodayData(dt, function (list) {
            if (!list.length) {
                $("#tblBody").html("");
                return showToast("No data found", "error");
            }

            let html = "";
            list.forEach(r => {
                html += `
                <tr id="row_${r.ID}">
                    <td>${r.DateTime}</td>
                    <td>${r.Shift}</td>
                    <td>${r.RunningSize}</td>
                    <td>${r.TotalProduction}</td>
                    <td>${r.SuperviserName}</td>
                    <td id="rej_${r.ID}">${r.RejectPart}</td>
                    <td><button type="button" class="btn btn-warning btn-sm" onclick="editRow(${r.ID}, '${r.RejectPart}')">Edit</button></td>
                </tr>`;
            });
            $("#tblBody").html(html);

        }, () => showToast("Server Error", "error"));
    }

    function editRow(id, val) {
        $(".inline-edit-row").remove();
        $(`#row_${id}`).after(`
        <tr class="inline-edit-row">
            <td colspan="4" class="text-end fw-bold">Update Reject:</td>
            <td><input type="number" class="form-control form-control-sm" id="inp_${id}" value="${val}" /></td>
            <td>
                <button type="button" class="btn btn-success btn-sm" onclick="saveRow(${id})">Save</button>
                <button type="button" class="btn btn-secondary btn-sm" onclick="$('.inline-edit-row').remove()">Cancel</button>
            </td>
        </tr>`);
    }

    function saveRow(id) {
        const value = $(`#inp_${id}`).val();
        PageMethods.UpdateShiftData(id, value, function () {
            $(`#rej_${id}`).text(value);
            $(".inline-edit-row").remove();
            showToast("Reject Updated ✅");
        }, () => showToast("Update Failed ❌", "error"));
    }

    function saveTarget() {
        const shift = $("#shiftSelect").val();
        const target = $("#targetValue").val();

        if (!shift || !target) return showToast("Please fill both fields", "error");

        PageMethods.SaveTarget(shift, target, function () {
            showToast("Target Saved 🎯");
            $("#targetValue").val("");
        }, () => showToast("Error Saving Target ❌", "error"));
    }
    /* --------------------------------------------------------------------------
         👤 SAVE SUPERVISOR
      -------------------------------------------------------------------------- */
    function saveSupervisor() {

        const name = $("#supervisorName").val().trim();
        if (!name) return showToast("Enter Supervisor", "error");

        PageMethods.SaveSupervisor(name,
            function () {
                showToast("Supervisor Saved");
                $("#supervisorName").val("");
            },
            function () {
                showToast("Failed", "error");
            }
        );
    }

    /* --------------------------------------------------------------------------
       📝 SAVE REMARK
    -------------------------------------------------------------------------- */
    function SaveRemark() {

        const remark = $("#REMARK").val().trim();
        if (!remark) return showToast("Enter Remark", "error");

        PageMethods.SaveRemark(remark,
            function (res) {

                if (res === "OK") {
                    showToast("Remark Saved 👍");
                    $("#REMARK").val("");
                } else {
                    showToast(res, "error");
                }

            },
            function () {
                showToast("Server Error", "error");
            }
        );
    }

</script>

</body>
</html>
