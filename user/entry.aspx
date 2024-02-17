<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="entry.aspx.cs" Inherits="WebApplication2.user.entry" %>

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
</head> 

<script type="text/javascript">   
    //Called this method on any button click  event for Testing
    function UserLogin(i) {
        if ($("#userid" + i).val() == "") {
            toast("Userid is required.")
        } else if ($("#password" + i).val() == "") {
            toast("Password is required.")
        } else {
            $.ajax({
                type: "POST",
                url: "entry.aspx/UserLogin",
                data: "{ Userid: '" + $("#userid" + i).val() + "',Password: '" + $("#password" + i).val() + "',Station: '" + i + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: function (msg) {
                    toast(msg.d)
                    if (msg.d == "success") { location.reload() }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            });
        }
    } 
</script>


    <%--script for check already user loggedin--%>
        <script>
            $.ajax({
                type: "POST",
                url: "entry.aspx/GetAthenticatedUser",
                //data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: function (msg) {  
                    var users = msg.d.split("/") 
                    if (msg.d.length < 100) {
                        return toast(msg.d)
                    }

                    users.splice(15, 0, users.at(-1))
                    users = users.slice(0, users.length - 1)

                    users.map(e =>
                    document.getElementById("userTable").innerHTML +=
                            `<tr class="d-flex justify-content-start gap-2" id="station${e.split(",")[0]}">
                            <th>
                                <div class="alert alert-sm mt-1 alert-secondary">${e.split(",")[0] == 0 ? 'Built Tkt' : e.split(",")[0] == 16 ? 'Rework &ensp;' : 'Station' + e.split(",")[0]}</div>
                            </th> 
                                ${e.split(",")[1] != 'nouser'
                                ? `<td>
                                <div style="width:525px;border:2px #afe1af solid; padding:18px;" class="rounded">
                                    <b>${e.split(",")[1]}</b> is working on this station. ID <b>${e.split(",")[2]}</b>
                                </div>
                                </td>`
                                : `<td>User Id : <input id="userid${e.split(",")[0]}" class="form-control" /></td>
                                <td>Password : <input id="password${e.split(",")[0]}" class="form-control" /></td>
                                <td><button type="button" class="btn btn-primary mt-4" onclick="UserLogin(${e.split(",")[0]})">Enter</button></td>`
                                    }
                            </tr>`)
                }
                });
            

        </script>

<body>
    <form id="form1" runat="server">
        <div>
            <%--navbar header--%>
            <div class="navbar navbar-light d-flex px-5 mb-4" style="background: lightgray;">
                <!--header logo-->
                <img src="../image/logo.png" alt="error" height="45" />

                <big>Manage your entry by station numbers</big>
            </div>

            <div class=" d-flex align-items-start gap-5 justify-content-center m-auto " style="width: 1000px;">
                                                
                <table class="table table-borderless flex-1" id="userTable">
                    <%--content will be fetch from ajax query--%> 
                </table>

                <div style="position: sticky; top: 10px;">
                    <h4>Get your Station</h4>
                    <div style="display: flex; gap: 5px; flex-wrap: wrap;">
                        <%int[] stArr = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14,16,15 };
                            foreach (var i in stArr) { %> 
                           <% if (i == 0) { %>
                        <button type="button" class="btn btn-light" onclick="location.href = 'entry.aspx#station<%=i %>'">Built Ticket Station</button>
                           <%  } else if (i == 16) {  %>
                        <button type="button" class="btn btn-light" onclick="location.href = 'entry.aspx#station<%=i %>'">Rework Station</button>
                           <% } else { %>
                        <button type="button" class="btn btn-light" onclick="location.href = 'entry.aspx#station<%=i %>'"><%=i.ToString("00") %></button>
                           <% } %> 
                        <% } %>
                    </div>
                </div>

            </div>

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
