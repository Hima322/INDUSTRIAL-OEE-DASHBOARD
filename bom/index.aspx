<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.bom.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Bom</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" /> 
    <link rel="stylesheet" href="../css/libs/bootstrap.min.css" /> 
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

            <%--body part code--%>
            <div class="container mt-3">
                <%--model name lists--%>
                <div class="d-flex justify-content-between align-items-center">
                    <!--modal title and close button-->

                    <big>
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        Bom Details
                    </big>

                    <div class="d-flex justify-content-around align-items-center">
                        <%--button for search--%>
                        <input id="search_box" type="text" placeholder="Search.." class="form-control" /> &ensp;&ensp;
                        <%--button for add new bom--%>
                        <button style="width:150px;" type="button" onclick="location.href = 'add.aspx?model=<%=Request.Params.Get("model") %>&variant=<%=Request.Params.Get("variant") %>&fg=<%=Request.Params.Get("fg") %>'" class="btn btn-secondary">Add Bom</button>
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


                <div class="alert alert-secondary d-flex mt-3 flex-column container ">
                    <span>Model : &ensp;&ensp;&ensp;&nbsp; <strong><%=Request.Params.Get("model") %></strong></span>
                    <span>Variant : &ensp;&ensp;&ensp; <strong><%=Request.Params.Get("variant") %></strong> </span>
                    <span>FG Part No : <strong><%=Request.Params.Get("fg") %></strong></span>
                </div>


                <%--model details table--%>
                <table class="table text-center table-bordered table-hover mt-3">

                    <%if (BomList.Count != 0)
                        { %>
                    <thead class="table-secondary">
                        <tr>
                            <th>Part Name</th>
                            <th>Part No.</th>
                            <th>Side</th>
                            <th>AssyStationId</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <%} %>

                    <tbody id="filter_data">
                        <%foreach (var bom in BomList)
                            {  %>
                        <tr>
                            <td title="<%=bom.PartName %>" data-bs-toggle="tooltip"><%=bom.PartName.Length > 30 ? bom.PartName.Substring(0,20) + "..." : bom.PartName %></td>
                            <td><%=bom.PartNumber %></td>
                            <td><%=bom.Side %></td>
                            <td><%=bom.AssyStationID %></td>
                            <td>
                                <div class="btn-group">
                                    <a class="btn btn-primary btn-sm text-white" href="edit.aspx?id=<%=bom.ID %>">Edit </a>

                                    <button
                                        onclick="handleDelete(<%=bom.ID %>)"
                                        type="button"
                                        class="btn btn-danger btn-sm">
                                            <img src="../image/icon/trash.svg" height="17" />
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>


                        <%if (BomList.Count == 0)
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
    </script>
</body>
</html>
