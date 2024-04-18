<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="add.aspx.cs" Inherits="WebApplication2.bom.Add" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin | Add Variant</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="../css/libs/toastify.min.css" />
    <script type="text/javascript" src="../js/libs/toastify-js.js"></script>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>

    <script>
        $(document).ready(function () {
        $("#add_button").click(function() {
            var MODEL = $("#MODEL").val()
            var VARIANT = $("#VARIANT").val()
            var FG_PART_NUMBER = $("#FG_PART_NUMBER").val()  
            var PART_NUMBER = $("#PART_NUMBER").val()
            var DUPLICATE = $("#DUPLICATE").val() 
            var SIDE = $("#SIDE").val() 
            var PART_NAME = $("#PART_NAME").val()
             
            if (!PART_NUMBER) return toast("PART_NUMBER is required.") 
            else if (!SIDE) return toast("SIDE type is required.") 
            else if (!PART_NAME) return toast("PART_NAME is required.")
            else {
                $(this).attr("disabled", true)
                $.ajax({
                    type: "POST",
                    url: "add.aspx/ADD_BOM",
                    data: `{MODEL : '${MODEL}', VARIANT : '${VARIANT}', FG_PART_NUMBER : '${FG_PART_NUMBER}', PART_NUMBER:'${PART_NUMBER}',DUPLICATE:'${DUPLICATE}', SIDE:'${SIDE}',  PART_NAME : '${PART_NAME}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d == "Done") toast("Success")
                        setTimeout(function () {
                            location.replace(`/bom/index.aspx?model=${MODEL}&variant=${VARIANT}&fg=${FG_PART_NUMBER}`)
                        }, 500)
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

                        <!-- Modal body -->
                        <div class="modal-body mt-5 w-50 mx-auto" runat="server">

                            <!--modal title and close button-->
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="modal-title">
                                    <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                                    Add New Bom</h5>
                            </div>  

                            <!--model add form--> 

                                <div class="row">
                                    <div class="col mt-3">
                                        <label for="MODEL" class="form-label">
                                            <b>Model :</b>
                                        </label> 
                                        <input class="form-control" value="<%=Request.Params.Get("model") %>" disabled="disabled" id="MODEL" />
                                    </div>
                                    <div class="col mt-3">
                                        <label for="VARIANT" class="form-label">
                                            <b>Variant :</b>
                                        </label> 
                                        <input class="form-control" value="<%=Request.Params.Get("variant") %>" disabled="disabled" id="VARIANT" />
                                    </div>
                                    <div class="col mt-3">
                                        <label for="FG_PART_NUMBER" class="form-label">
                                            <b>FG Part Number :</b>
                                        </label> 
                                        <input class="form-control" value="<%=Request.Params.Get("fg") %>" disabled="disabled" id="FG_PART_NUMBER" />
                                    </div> 
                                </div>


                                <div class="row">
                                    <div class="col mt-3">
                                        <label for="PART_NUMBER" class="form-label">
                                            <b>Part Number :</b>
                                        </label>  
                                        <input value="E4RNS5-32001" class="form-control" id="PART_NUMBER" />
                                    </div> 
                                    <div class="col mt-3">
                                        <label for="DUPLICATE" class="form-label">
                                            <b>Duplicate Scan :</b>
                                        </label>   
                                        <input class="form-control" id="DUPLICATE" value="True" list="dup" /> 
                                        <datalist>
                                            <option>True</option>
                                            <option>False</option>
                                        </datalist>
                                    </div> 
                                    <div class="col mt-3">
                                        <label for="SIDE" class="form-label">
                                            <b>Side :</b>
                                        </label>   
                                        <input class="form-control" value="<%=Request.Params.Get("side") %>" disabled="disabled" id="SIDE" /> 
                                    </div>  
                                </div>

                               
                                <div class="col mt-3 mb-4">
                                        <label for="PART_NAME" class="form-label">
                                            <b>Part Name :</b>
                                        </label>  
                                        <input value="PYTRO TECHNIC SEAT BELT" class="form-control" id="PART_NAME" />
                                    </div> 

                               <button type="button" class="btn btn-danger" onclick="history.back()">Cancel</button> &nbsp; 
                               <button id="add_button" type="button" class="btn btn-primary" > Submit </button>

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
