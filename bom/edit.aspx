<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="edit.aspx.cs" Inherits="WebApplication2.bom.edit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Edit Bom</title>
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
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
                            <b>Side :</b>
                        </label>
                        <asp:TextBox CssClass="form-control" ID="SIDE" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="ASSYSTATIONID" class="form-label">
                            <b>AssyStationId :</b>
                        </label>
                        <asp:TextBox CssClass="form-control" ID="ASSYSTATIONID" runat="server"></asp:TextBox>
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
                <asp:Button CssClass="btn btn-primary" OnClick="EDIT_BOM" Text="Update" runat="server" />
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
