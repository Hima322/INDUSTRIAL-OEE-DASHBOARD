<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="add.aspx.cs" Inherits="WebApplication2.variant.Add" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin | Add Variant</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <script src="../js/libs/bootstrap.bundle.min.js"></script> 
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css" />
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />  
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
    <script>
        function handleAddVariant() {
            var VARIANT = $("#VARIANT").val()
            var C5S_7F = $("#C5S_7F").val()
            var SEAT = $("#SEAT").val()
            var CustPartNumber = $("#CustPartNumber").val()
            var FGPartNUMBER = $("#FGPartNUMBER").val()
            var FEATURES = $("#FEATURES").val()
            var PART_NAME = $("#PART_NAME").val()

            if (!VARIANT) return toast("VARIANT is required.")
            else if (!C5S_7F) return toast("C5S_7F is required.")
            else if (!CustPartNumber) return toast("CustPartNumber is required.")
            else if (!SEAT) return toast("SEAT type is required.")
            else if (!FGPartNUMBER) return toast("FGPartNUMBER is required.")
            else if (!FEATURES) return toast("FEATURES is required.")
            else if (!PART_NAME) return toast("PART_NAME is required.")
            else {
                $("#submit_button").attr("disabled",true)
                $.ajax({
                    type: "POST",
                    url: "add.aspx/ADD_VARIANT",
                    data: `{MODEL : '<%=Request.Params.Get("model") %>', VARIANT : '${VARIANT}', C5S_7F : '${C5S_7F}' ,SEAT:'${SEAT}', CustPartNumber:'${CustPartNumber}', FGPartNUMBER : '${FGPartNUMBER}', FEATURES : '${FEATURES}', PART_NAME : '${PART_NAME}'}`,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: "true",
                    cache: "false",
                    success: (res) => {
                        if (res.d == "Done") toast("Success")
                        setTimeout(function () { 
                            location.replace(`/index.aspx?model=<%=Request.Params.Get("model") %>`) 
                        }, 3000)
                    },
                    Error: function (x, e) {
                        console.log(e);
                    }
                }) 
            }
        }


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
            <div class="modal-body mt-5 w-50 mx-auto">

                <!--modal title and close button-->
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="modal-title">
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        Add New Variant</h5>
                    <!--<button type="button" class="btn-close btn-sm" data-bs-dismiss="modal"></button>-->
                </div>

                <!--model add form--> 

                <div class="alert alert-secondary mt-3">
                    Model : <b><%=Request.Params.Get("model") %></b>
                </div>

                    <div class="row">
                        <div class="col mt-3">
                            <label for="VARIANT" class="form-label">
                                <b>Variant :</b>
                            </label> 
                            <input class="form-control" id="VARIANT" />
                        </div>
                        <div class="col mt-3">
                            <label for="C5S_7F" class="form-label">
                                <b>C5S_7F :</b>
                            </label>
                            <input class="form-control" id="C5S_7F" />
                        </div>
                        <div class="col mt-3">
                            <label for="SEAT" class="form-label">
                                <b>Seat :</b>
                            </label>
                            <select class="form-control" id="SEAT" >
                                <option>DRIVER</option>
                                <option>CO-DRIVER</option>
                            </select>
                        </div>
                    </div>


                    <div class="row">
                        <div class="col mt-3">
                            <label for="CustPartNumber" class="form-label">
                                <b>Customer Part Number :</b>
                            </label>
                            <input class="form-control" id="CustPartNumber" /> 
                        </div>
                        <div class="col mt-3">
                            <label for="FGPartNUMBER" class="form-label">
                                <b>FG_Part No. :</b>
                            </label> 
                            <input class="form-control" id="FGPartNUMBER" /> 
                        </div>
                        <div class="col mt-3">
                            <label for="FEATURES" class="form-label">
                                <b>Features :</b>
                            </label> 
                            <input class="form-control" id="FEATURES" /> 
                        </div>
                    </div>


                    <div class="col mt-3 mb-4">
                        <label for="PART_NAME" class="form-label">
                            <b>Part Name :</b>
                        </label> 
                            <input class="form-control" id="PART_NAME" /> 
                    </div>

                    <button type="button" class="btn btn-danger" onclick="history.back()">CANCEL</button>
                    &nbsp; 
                    <button type="button" class="btn btn-primary" onclick="handleAddVariant()" id="submit_button">SUBMIT</button>
                
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
