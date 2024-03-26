<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="edit.aspx.cs" Inherits="WebApplication2.bom.edit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Edit Bom</title>
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" />
    <script type="text/javascript" src="../js/libs/toastify-js.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    
    <script>
        $(document).ready(function () {
            $("#EDIT_BOM").click(function () {   
                var MODEL = $("#MODEL").val()
                var VARIANT = $("#VARIANT").val()
                var FG_PART_NUMBER = $("#FG_PART_NUMBER").val()
                var PART_NUMBER = $("#PART_NUMBER").val()
                var SIDE = $("#SIDE").val()
                var PART_NAME = $("#PART_NAME").val()

                if (!PART_NUMBER) return toast("PART_NUMBER is required.")
                else if (!SIDE) return toast("SIDE type is required.")
                else if (!PART_NAME) return toast("PART_NAME is required.")
                else {
                    $(this).attr("disabled", true)
                    $.ajax({
                        type: "POST",
                        url: "edit.aspx/EDIT_BOM",
                        data: `{ id: <%=Request.Params.Get("id") %>, PART_NUMBER:'${PART_NUMBER}', SIDE:'${SIDE}',  PART_NAME : '${PART_NAME}'}`,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: "true",
                        cache: "false",
                        success: (res) => {
                            if (res.d == "Done") toast("Success")
                            setTimeout(function () {
                                history.back() 
                            }, 2000)
                        },
                        Error: function (x, e) {
                            console.log(e);
                        }
                    })
                }
            })
        })


        //alert toast function for notification 
        const toast = txt =>
            Toastify({
                text: txt,
                duration: 3000,
                gravity: "bottom",
                position: "right",
                style: {
                    background: 'lightgray',
                    color: 'black',
                    fontSize: '20px',
                    borderRadius: '5px'
                }
            }).showToast();

    </script>

</head>
<body>
    <form id="form1" runat="server"> 
        <div>

            <% if (CurrentError != "")
                { %>
            <div id="toast" class="toast <%=CurrentError == "" ? "" : "show" %> bg-white" style="position: fixed; top: 20px; right: 20px;z-index:9999;">
                <div class="d-flex p-2 bg-secondary toast-body text-white">
                    <big class="me-auto ps-2"><%=CurrentError %></big>
                    <button type="button" class="btn-close text-white" data-bs-dismiss="toast"></button>
                </div>
            </div>
            <% } %>

            <!-- Modal body -->
            <div class="modal-body mt-5 w-50 mx-auto">

                <!--modal title and close button-->
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="modal-title"> 
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        Edit Bom</h5> 
                </div>

                <!--model add form-->

                <div class="row">
                    <div class="col mt-3">
                        <label for="MODEL" class="form-label">
                            <b>Model :</b> (readonly)
                        </label>
                        <asp:TextBox ReadOnly="true" CssClass="form-control" ID="MODEL" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="VARIANT" class="form-label">
                            <b>Variant :</b> (readonly)
                        </label>
                        <asp:TextBox ReadOnly="true" CssClass="form-control" ID="VARIANT" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="FG_PART_NUMBER" class="form-label">
                            <b>FG Part Number :</b> (readonly)
                        </label>
                        <asp:TextBox ReadOnly="true" CssClass="form-control" ID="FG_PART_NUMBER" runat="server"></asp:TextBox>
                    </div>
                </div>


                <div class="row">
                    <div class="col mt-3">
                        <label for="PART_NUMBER" class="form-label">
                            <b>Part Number :</b>
                        </label>
                        <asp:TextBox CssClass="form-control" ID="PART_NUMBER" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="SIDE" class="form-label">
                            <b>Side :</b>  (readonly)
                        </label>
                        <asp:TextBox ReadOnly="true" CssClass="form-control" ID="SIDE" runat="server"></asp:TextBox>
                    </div> 
                </div>


                <div class="col mt-3 mb-4">
                    <label for="PART_NAME" class="form-label">
                        <b>Part Name :</b>
                    </label>
                    <asp:TextBox CssClass="form-control" ID="PART_NAME" runat="server"></asp:TextBox>
                </div>

                <button type="button" class="btn btn-danger" onclick="history.back()">Cancel</button>
                &nbsp;
                <button type="button" class="btn btn-primary" id="EDIT_BOM">Edit Bom</button> 
            </div>

        </div>
    </form>
    
    <script>

        // code for check authentication
        if (localStorage.getItem("admin") == null) {
            location.href = "/login.aspx"
        } 

        //code for toast auto close  
        if (document.getElementById("toast").classList.value.split(" ").includes("show")) {
            setTimeout(function () { document.getElementById("toast").classList.remove("show") }, 5000)
        }

    </script>
</body>
</html>
