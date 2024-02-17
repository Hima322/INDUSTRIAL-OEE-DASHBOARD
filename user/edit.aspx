<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="edit.aspx.cs" Inherits="WebApplication2.user.edit" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Edit User</title>  
    <meta name="viewport" content="width=device-width, initial-scale=1" />  
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
                        Edit User</h5> 
                </div>

                <!--model add form-->

                <div class="row">
                    <div class="col mt-3">
                        <label for="USERID" class="form-label">
                            <b>User Id :</b>
                        </label>
                        <asp:TextBox CssClass="form-control" ID="USERID" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="USERNAME" class="form-label">
                            <b>User Name :</b> 
                        </label>
                        <asp:TextBox CssClass="form-control" ID="USERNAME" runat="server"></asp:TextBox>
                    </div>
                    <div class="col mt-3">
                        <label for="PASSWORD" class="form-label">
                            <b>Password :</b>  
                        </label>
                        <asp:TextBox CssClass="form-control" ID="PASSWORD" runat="server"></asp:TextBox>
                    </div>
                </div>


                <div class="row">
                    <div class="col mt-3">
                        <label for="ROLL" class="form-label">
                            <b>Roll :</b>
                        </label>
                        <select runat="server" id="ROLL" class="form-control"> 
                            <option>Operator</option>
                            <option>Maintenance</option>
                        </select>
                    </div>
                    <div class="col mt-3">
                        <label for="ONSTATION" class="form-label">
                            <b>OnStation :</b>
                        </label>
                        <asp:TextBox CssClass="form-control" ID="ONSTATION" runat="server"></asp:TextBox>
                    </div> 
                </div><br />
                 

                <button type="button" class="btn btn-danger" onclick="history.back()">Cancel</button>
                &nbsp;
                <asp:Button CssClass="btn btn-primary" OnClick="EDIT_USER" Text="Update" runat="server" />
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

