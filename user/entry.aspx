<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="entry.aspx.cs" Inherits="WebApplication2.user.Entry" %>

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

    var plcStation = []

    $(document).ready(_ => {
        getAllPlcTagList()
    })

    //setInterval(_ => {
    //    getAllPlcTagList()
    //},1000)

    function UserLogin() { 
        let username = $("#username").val()
        let station = $("#station").val()

        if (!username) return toast("Username is required.");

            $.ajax({
                type: "POST",
                url: "entry.aspx/UserLogin",
                data: `{username : '${username}', station : '${station}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: function (msg) {
                    if (msg.d == "Done") {
                        toast("Success.")
                        setTimeout(_ => location.reload())
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            });

    } 


    //function for write bit task
    const getAllPlcTagList = _ => {
        $.ajax({
            type: "POST",
            url: "entry.aspx/GetAllPlcTagList",
            data: "",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: "true",
            cache: "false",
            success: (res) => {
                if (res.d != "Error") {
                    let data = JSON.parse(res.d)

                    let mes = data.find(e => e.PLCTagName == "MESStation") 

                    let temp = []

                    for (s in mes) {
                        if (mes[s] == "") {
                            temp.push(s)
                        }
                    } 
                     
                    plcStation = temp;
                     
                    $("#station").html(
                        plcStation.map(e => `<option value="${e}">${e}</option> `)
                    ); 
                      

                }
            },
            Error: function (x, e) {
                console.log(e);
            }
        })
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
                        Manual User Login </h5>
                </div>


                <div class=" d-flex align-items-start gap-5 justify-content-center m-auto " style="width: 1000px;">

                    <table class="table table-borderless flex-1" id="userTable">
                        <%--content will be fetch from ajax query--%>
                        <tr class="d-flex justify-content-start gap-2">
                            <td>Station No :
                                <select id="station" class="form-select"> 
                                        
                                </select></td>
                            <td>User Name :
                                <input id="username" class="form-control" /></td>
                            <td>
                                <button type="button" class="btn btn-primary mt-4" onclick="UserLogin()">Login</button></td>
                        </tr>
                    </table>

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
