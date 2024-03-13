<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="info.aspx.cs" Inherits="WebApplication2.user.Info" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Entry</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" /> 
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <link rel="stylesheet" href="../css/libs/font-awesome.min.css" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" />
    <script type="text/javascript" src="../js/libs/toastify-js.js"></script> 
    <script type="text/javascript" src="../js/libs/moment.min.js"></script> 
</head> 

<script type="text/javascript">   

    $(document).ready(_ => { 
        $("#userList").hide()
    })

    function searchUser() { 
        let date = $("#date").val()
        let station = $("#station").val()

        if (!date) return toast("Date is required.");

            $.ajax({
                type: "POST",
                url: "info.aspx/SEARCH_USER",
                data: `{date : '${date}', station : '${station}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: function (res) {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        $("#userList").show()
                        $("#userList tbody").html(
                            data.map(e => `
                                <tr>
                                    <td>${e.OperatorName}</td>
                                    <td>${moment(e.LoginTime).format("lll")}</td>
                                    <td>${moment(e.LogoutTime).format("lll")}</td> 
                                </tr>
                            `)
                        )
                    } else {
                        toast("User Not Found.")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            });

        } 
</script>
     

<body>
    <form id="form1" runat="server"> 
            
            <!-- USER body -->
            <div class="modal-body mt-5 w-50 mx-auto" runat="server">

                <!--USER title and close button-->
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="modal-title">
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        Search Station Operator </h5>
                </div>


                <div class=" d-flex align-items-start gap-5 justify-content-center m-auto ">

                    <table class="table table-borderless flex-1" id="userTable">
                        <%--content will be fetch from ajax query--%>
                        <tr class="d-flex justify-content-start gap-2">
                            <td>Station No :
                                <select id="station" class="form-select" onchange='$("#userList").hide()' >
                                    <%for(int i =1; i < 26; i++){ %>
                                        <option value="<%=i %>">Station-<%=i %></option>
                                    <%  } %>
                                </select></td>
                            <td>User Name :
                                <input id="date" type="date" class="form-control" onchange='$("#userList").hide()' /></td>
                            <td>
                                <button type="button" class="btn btn-primary mt-4" onclick="searchUser()">Search</button></td>
                        </tr>
                    </table>

                </div>

                <table class="table table-bordered text-center" id="userList">
                    <thead class="table-primary">
                        <tr>
                            <th>User Name</th>
                            <th>Login Time</th>
                            <th>Logout Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>

            </div>
    </form>
    <br />
    <script>
        const toast = txt =>

            Toastify({
                text: txt,
                duration: 3000,
                gravity: "bottom",
                position: "right",
                style: {
                    background: 'gray',
                    fontSize: '20px',
                    borderRadius:'5px'
                }
            }).showToast();

    </script>

</body>
</html>
