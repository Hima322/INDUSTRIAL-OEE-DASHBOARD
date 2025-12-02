<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.report.Index" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Change Size</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    
    <!-- Bootstrap & Font Awesome CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"/>
    <link rel="stylesheet" href="../css/libs/toastify.min.css"/>

    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../js/libs/toastify-js.js"></script>

    <style>
        body{background:#f8f9fa;}
        .card{border-radius:12px;}
        .table thead{background:#343a40;color:#fff;}
        .table tbody tr:hover{background:#e9ecef;}
        .back-icon{font-size:1.2rem;margin-right:0.5rem;}
        .running-row{background-color:#d1e7dd !important;}
        @media(max-width:576px){.btn{margin-bottom:4px;width:100%;}}
        .inline-box{background:#e2e3e5;padding:8px;border-radius:6px;margin-top:4px;}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

<div class="container mt-4">

    <div class="d-flex align-items-center mb-3">
        <a href="javascript:history.back();" class="text-decoration-none text-dark me-2">
            <i class="fa fa-arrow-left back-icon"></i> 
        </a>
        <h4 class="mb-0">Change Size</h4>
        <div class="ms-auto text-muted">
            User: <span id="usernameDisplay"></span> | Role: <span id="roleDisplay"></span>
        </div>
    </div>

    <!-- Dropdown for running model -->
    <div class="mb-3  d-flex justify-content-center">
        <select id="modelDropdown" class="form-select d-inline-block me-2" style="width:200px;"></select>
        <select id="SizeDropDown" class="form-select d-inline-block me-3" style="width: 200px;"></select>


        <button type="button" class="btn btn-success btn-sm" onclick="selectRunningModel()">Set Running Model</button>
    </div>
    <div class="mb-3">
        <button type="button" class="btn btn-success btn-sm" onclick="showAddBox()">Add Model</button>
    </div>
  <div id="addBox" class="inline-box d-none">
    <label class="me-2 fw-bold">Add Model:</label>
    
    <input type="text" id="addInput1" class="form-control d-inline-block w-auto me-2" placeholder="Name" />
    <input type="text" id="addInput2" class="form-control d-inline-block w-auto me-2" placeholder="SIZE" />
    <input type="text" id="addInput3" class="form-control d-inline-block w-auto me-2" placeholder="STDNAME" />
    
    <button type="button" class="btn btn-primary btn-sm" onclick="saveAdd()">Save</button>
    <button type="button" class="btn btn-secondary btn-sm" onclick="cancelAdd()">Cancel</button>
</div>


    <!-- Models Table -->
    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-bordered text-center" id="modelsTable">
                    <thead class="table-dark">
                        <tr>
                            <th>Name</th>
                            <th>Size</th>
                            <th>STDName</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</form>
   <script>
       let currentRole = (localStorage.getItem("role") || "user").toLowerCase();
       let currentUser = localStorage.getItem("username") || "User";
       let allModels = [];
       let runningStdName = null;
       let runningSize = null;

       // Display username and role
       $("#usernameDisplay").text(currentUser);
       $("#roleDisplay").text(currentRole.charAt(0).toUpperCase() + currentRole.slice(1));

       // Toast helper
       function showToast(msg, color) {
           Toastify({
               text: msg,
               duration: 3000,
               gravity: "top",
               position: "right",
               backgroundColor: color,
               close: true
           }).showToast();
       }

       // Load models
       function loadModels() {
           PageMethods.GetModels(function (response) {
               allModels = response.models || [];
               runningStdName = response.runningStdName;
               runningSize = response.runningSize;

               const tbody = $("#modelsTable tbody");
               const modelDropdown = $("#modelDropdown");
               const sizeDropdown = $("#SizeDropDown");

               tbody.empty();
               modelDropdown.empty();
               sizeDropdown.empty();

               const modelSet = new Set();

               allModels.forEach(model => {
                   // Table row
                   const rowClass = (model.STDName === runningStdName && model.Size === runningSize) ? 'running-row' : '';
                   tbody.append(`
                <tr class="${rowClass}" id="row_${model.ID}">
                    <td>${model.ModelName}</td>
                    <td>${model.Size}</td>
                    <td>${model.STDName || '-'}</td>
                    <td>${getActionButtons(model)}</td>
                </tr>
            `);

                   // Unique model dropdown
                   if (!modelSet.has(model.ModelName)) {
                       modelSet.add(model.ModelName);
                       modelDropdown.append(`<option value="${model.ModelName}">${model.ModelName}</option>`);
                   }
               });

               // Populate size dropdown for selected model
               updateSizeDropdown(modelDropdown.val());

               modelDropdown.off("change").on("change", function () {
                   updateSizeDropdown($(this).val());
               });

           }, function () {
               showToast("Error loading models", "red");
           });
       }

       // Update size dropdown based on selected model
       function updateSizeDropdown(modelName) {
           const sizeDropdown = $("#SizeDropDown");
           sizeDropdown.empty();

           if (!modelName) return;

           const sizes = allModels
               .filter(m => m.ModelName === modelName)
               .map(m => m.Size);

           [...new Set(sizes)].forEach(size => {
               sizeDropdown.append(`<option value="${size}">${size}</option>`);
           });
       }

       // Action buttons
       function getActionButtons(model) {
           if (currentRole === 'administrator') {
               return `
            <button type="button" class="btn btn-primary btn-sm me-1"
                onclick='editModel(${model.ID}, ${JSON.stringify(model.ModelName)}, ${JSON.stringify(model.Size)}, ${JSON.stringify(model.STDName)})'>
                Update
            </button>
            <button type="button" class="btn btn-danger btn-sm"
                onclick="deleteModel(${model.ID})">
                Delete
            </button>`;
           } else if (currentRole === 'administrator') {
               return `<button type="button" class="btn btn-success btn-sm" onclick="selectRunningModel()">
                    Select
                </button>`;
           } else {
               return 'No Permission';
           }
       }

       // Edit model inline
       function editModel(id, name, size, stdName) {
           $(".inline-box-row").remove();

           const inline = `
    <tr class="inline-box-row">
        <td colspan="4">
            <input type="text" id="updateName_${id}" class="form-control d-inline-block w-auto me-2" value="${name}" placeholder="Model Name" />
            <input type="text" id="updateSize_${id}" class="form-control d-inline-block w-auto me-2" value="${size}" placeholder="Size" />
            <input type="text" id="updateSTDName_${id}" class="form-control d-inline-block w-auto me-2" value="${stdName}" placeholder="STD Name" />
            <button type="button" class="btn btn-primary btn-sm" onclick="saveUpdateRow(${id})">Save</button>
            <button type="button" class="btn btn-secondary btn-sm" onclick="$(this).closest('tr').remove()">Cancel</button>
        </td>
    </tr>
    `;
           $(`#row_${id}`).after(inline);
       }

       // Save edited model
       function saveUpdateRow(id) {
           const newName = $(`#updateName_${id}`).val().trim();
           const newSize = $(`#updateSize_${id}`).val().trim();
           const newSTDName = $(`#updateSTDName_${id}`).val().trim();

           if (!newName || !newSize || !newSTDName) {
               showToast("All fields are required!", "red");
               return;
           }

           PageMethods.UpdateModel(id, newName, newSize, newSTDName,
               function () {
                   showToast("Model updated successfully!", "green");
                   $(".inline-box-row").remove();
                   loadModels();
               },
               function (err) {
                   console.error(err);
                   showToast("Error updating model", "red");
               }
           );
       }

       // Add new model
       function showAddBox() { $("#addBox").removeClass('d-none'); }
       function cancelAdd() { $("#addBox").addClass('d-none'); $("#addInput1, #addInput2, #addInput3").val(''); }

       function saveAdd() {
           const name = $("#addInput1").val().trim();
           const size = $("#addInput2").val().trim();
           const stdName = $("#addInput3").val().trim();
           if (currentRole === "administrator") {
               if (!name || !size || !stdName) {
                   showToast("Please fill all fields", "red");
                   return;
               }

               PageMethods.AddModel(name, size, stdName,
                   function () {
                       showToast("Model added successfully!", "green");
                       cancelAdd();
                       loadModels();
                   },
                   function () { showToast("Error adding model", "red"); }
               );
           }
           else { showToast("Only Admin Add Size"); }
       }

       // Delete model
       function deleteModel(id) {
           if (!confirm("Are you sure you want to delete this model?")) return;

           PageMethods.DeleteModel(id,
               function () {
                   showToast("Model deleted successfully!", "red");
                   loadModels();
               },
               function (err) {
                   console.error(err);
                   showToast("Error deleting model", "red");
               }
           );
       }

       // Select running model
       function selectRunningModel() {
           const modelName = $("#modelDropdown").val();
           const size = $("#SizeDropDown").val();

           if (!modelName || !size) { showToast("Select model and size first", "red"); return; }

           PageMethods.SelectModel(modelName, size,
               function (res) {
                   runningStdName = res;
                   runningSize = size;
                   showToast(`Selected Running Model: ${modelName} - ${size}`, "blue");

                   // Highlight running row
                   $("#modelsTable tbody tr").removeClass('running-row');
                   $("#modelsTable tbody tr").each(function () {
                       const rowModel = $(this).find('td:nth-child(1)').text();
                       const rowSize = $(this).find('td:nth-child(2)').text();
                       if (rowModel === modelName && rowSize === size) {
                           $(this).addClass('running-row');
                           return false;
                       }
                   });
               },
               function () { showToast("Error selecting model", "red"); }
           );
       }

       // Initialize
       $(document).ready(loadModels);

   </script>





</body>
</html>
