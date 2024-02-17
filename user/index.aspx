<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.user.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Manage User</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />  
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>   
    <script>
        //handle delete btn click function 
        const handleDelete = id => {
            var sure = confirm("Are you sure want to delete?")
            if (sure) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/HandleDelete",
                    data: `{ id: '${id}' }`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        console.log(res)
                        if (res.d) {
                            window.location.reload()
                        } else {
                            console.log("Something went wrong")
                        }
                    },
                    Error: function (x, e) {
                        console.log(e);
                    }
                })
            }
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>

               <% if(CurrentError != "")
                 { %>
              <div id="toast" class="toast <%=CurrentError == "" ? "" : "show" %> bg-white" style="position:fixed;bottom:20px;right:20px;z-index:999;">
                <div class="d-flex p-2 bg-secondary toast-body text-white">
                  <big class="me-auto ps-2"><%=CurrentError %></big> 
                </div> 
              </div>  
               <% } %> 

            <%--body part code--%>
            <div class="container mt-3">
                <%--model name lists--%>
                <div class="d-flex justify-content-between align-items-center">
                    <!--modal title and close button-->

                    <big> 
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        User Details
                    </big>

                    <%--button for add new bom--%>
                    <div class="d-flex justify-content-around align-items-center">
                        <input id="search_box" type="text" placeholder="Search.." class="form-control" /> &ensp;&ensp;
                    <button style="width:170px;" type="button" onclick="location.href = 'add.aspx'" class="btn btn-secondary">Add User</button> 
                    </div>
                </div>
                                
                <%--search js--%> 
                <script>
                    $(document).ready(function () {
                        $("#search_box").on("keyup", function () {
                            var value = $(this).val().toLowerCase().trim();
                            $("#filter_data tr").filter(function () {
                                $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
                            });
                        }); 
                    });
                </script>


                <%--model details table--%>
                <table class="table text-center table-bordered mt-3">

                    <%if (UserList.Count != 0)
                        { %>
                    <thead class="table-secondary">
                        <tr>
                            <th>UserId</th>
                            <th>UserName</th>
                            <th>Password</th> 
                            <th>Roll</th>
                            <th>OnStation</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <%} %>

                    <tbody id="filter_data">
                        <%foreach (var user in UserList)
                            {  %>
                        <tr class="<%=user.Authenticated == 1 ? "table-success" : "" %>"table-success"> 
                            <td><%if (user.Authenticated == 1)
                                    { %>
                                <font color="green" class="fa fa-circle"></font>
                                    <% } %> &nbsp;
                                <%=user.UserID %></td> 
                            <td><%=user.UserName %></td> 
                            <td><%=user.Password %></td>  
                            <td><%=user.Roll %></td> 
                            <td><%=user.WorkingAtStationID %></td> 
                            <td>
                                <div class="btn-group">
                                    <a class="btn btn-primary btn-sm text-white" href="edit.aspx?id=<%=user.ID %>">Edit </a>
                                    
                                    <button
                                        onclick="handleDelete(<%=user.ID %>)"
                                        type="button"
                                        class="btn btn-danger btn-sm">
                                         <img src="../image/icon/trash.svg" height="20" />
                                    </button>

                                </div>
                            </td>
                        </tr>
                        <% } %>


                        <%if (UserList.Count == 0)
                            { %>
                        <tr>
                            <td colspan="5">
                                <img style="height: 200px; margin: 50px auto;" src="https://cdn.icon-icons.com/icons2/2483/PNG/512/empty_data_icon_149938.png" alt="error" />
                            </td>
                        </tr>
                        <%} %>
                    </tbody>
                </table>
                <br />
            </div>

        </div>
    </form>


    <script>

        // code for check authentication
        if (localStorage.getItem("admin") == null) {
            location.href = "/login.aspx"
        } 

        // Initialize tooltips in bootstraph
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        })

        //code for toast auto close  
        if (document.getElementById("toast").classList.value.split(" ").includes("show")) {
            setTimeout(function () { document.getElementById("toast").classList.remove("show") }, 5000)
        }  
    </script>
</body>
</html>
