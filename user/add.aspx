<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="add.aspx.cs" Inherits="WebApplication2.user.add" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard | Add User</title> 
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" />
    <script type="text/javascript" src="../js/libs/toastify-js.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script>

        $(document).ready(function () {
            $("#submit_button").click(function () { 
            var userid = $("#USERID").val()
            var roll = $("#ROLL").val()
            var username = $("#USERNAME").val()
            var password = $("#PASSWORD").val()

                if (!userid) return toast("Userid is required.")
                else if (!roll) return toast("Roll is required.")
                else if (!username) return toast("Username is required.")
                else if (!password) return toast("Password is required.")
                else {
                    $(this).attr("disabled", true)
                    $.ajax({
                        type: "POST",
                        url: "add.aspx/ADD_USER",
                        data: `{userid : '${userid}', roll : '${roll}' ,username:'${username}', password:'${password}'}`,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        async: "true",
                        cache: "false",
                        success: (res) => {
                            if (res.d == "Done") {
                                toast("Success")
                                setTimeout(function () {
                                    location.replace(`/user/index.aspx`)
                                }, 1000)
                            } else {
                                toast(res.d)
                                $(this).attr("disabled", false)
                            }
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
   

                        <!-- USER body -->
                        <div class="modal-body mt-5 w-50 mx-auto" runat="server">

                            <!--USER title and close button-->
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="modal-title">
                                    <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                                    Add New User</h5>
                            </div>

                            <!--USER add form-->  
                            
                                <div class="row">
                                    <div class="col mt-3">
                                        <label for="USERID" class="form-label">
                                            <b>User Id :</b>
                                        </label>  
                                        <input id="USERID" class="form-control" />
                                    </div> 
                                    <div class="col mt-3">
                                        <label for="ROLL" class="form-label">
                                            <b>Roll :</b>
                                        </label>  
                                        <select id="ROLL" class="form-control"> 
                                            <option>Admin</option>
                                            <option>Operator</option>
                                            <option>Maintenance</option>
                                        </select>
                                    </div>  
                                </div> 

                            
                                <div class="row">
                                    <div class="col mt-3">
                                        <label for="USERNAME" class="form-label">
                                            <b>User Name :</b>
                                        </label>  
                                        <input id="USERNAME" class="form-control" />
                                    </div> 
                                    <div class="col mt-3">
                                        <label for="PASSWORD" class="form-label">
                                            <b>Password :</b>
                                        </label> 
                                        <input id="PASSWORD" class="form-control" /> 
                                    </div> 
                                </div>  <br />

                               <button type="button" class="btn btn-danger" onclick="history.back()">Cancel</button> &nbsp; 
                               <button type="button" class="btn btn-primary" id="submit_button">Submit</button>

                        </div>

                    </div> 
    </form>

     <script> 

         // code for check authentication
         if (localStorage.getItem("admin") == null) {
             location.href = "/login.aspx"
         } 
          
    
     </script>
</body>
</html>
