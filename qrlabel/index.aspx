<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.qrlabel.Index" %>

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


    <script type="text/javascript">   
        var currId = ""

        $(document).ready(_ => {
            var font = document.querySelectorAll(".finel-ticket-body font");
            console.log(font)

            font.forEach(e => {
                e.onclick = () => {
                    currId = e.id
                }
            }) 

        })

        function goTop() {
            $(`#${currId}`).css({
                left: ev.offsetX * 0.2 + "mm",
                top: ev.offsetY * 0.2 + "mm"
            })
        }


    </script>

    <style> 

        .finel-ticket-body, 
        .built-ticket-body{
            user-select: none;
            position: relative;
            border: 1px solid gray;
            border-radius: 5px;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">

            <!-- USER body -->
            <div class="modal-body mt-4 container">

                <!--USER title and close button-->
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="modal-title">
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        QR Label Details </h5>
                </div>

                <div class="d-flex justify-content-around">

                    <div class="tab-content mt-3">
                        <%--all qr ticket group--%>
                        <ul class="nav nav-pills mt-2 mb-4" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active border" id="finel-tab" data-bs-toggle="tab" data-bs-target="#finel" type="button" role="tab" aria-controls="finel" aria-selected="true">FINEL TICKET QR</button>
                            </li>

                            <li class="nav-item" role="presentation">
                                <button class="nav-link ms-2 border" id="built-tab" data-bs-toggle="tab" data-bs-target="#built" type="button" role="tab" aria-controls="built" aria-selected="true">BUILT TICKET QR</button>
                            </li>
                        </ul>

                        <div class="mt-3 tab-pane fade show active" id="finel">
                            <div class="finel-ticket-body" style="height: 25mm; width: 100mm;">

                                <font id="f0" style="font-size: 8pt; position: absolute; top: 2.5mm; left: 3mm;" color="red">
                                    <img src="../image/icon/qr-code.svg" style="height: 19mm;width:19mm;" />
                                </font>
                                <font id="f1" style="font-size: 8pt; position: absolute; top: 2.3mm; left: 25mm;" color="red"><b>PY1B</b></font>
                                <font id="f2" style="font-size: 8pt; position: absolute; top: 2.3mm; left: 45mm;" color="blue"><b>26-10-2023 10:03</b></font>
                                <font id="f3" style="font-size: 8pt; position: absolute; top: 7mm; left: 25mm;" color="green"><b>MID MT</b></font>
                                <font id="f4" style="font-size: 8pt; position: absolute; top: 7mm; left: 40mm;" color="gray"><b>4W</b></font>
                                <font id="f5" style="font-size: 8pt; position: absolute; top: 7mm; left: 50mm;" color="skyblue"><b>DRIVER SEAT</b></font>
                                <font id="f6" style="font-size: 8pt; position: absolute; top: 12mm; left: 25mm;" color="darkyellow"><b>87050 6VC2A</b></font>
                                <font id="f7" style="font-size: 8pt; position: absolute; top: 12mm; left: 50mm;" color="orange"><b>HOLD</b></font>
                                <font id="f8" style="font-size: 8pt; position: absolute; top: 17mm; left: 25mm;" color="black"><b>E4RNS5-10000-00001260620231003</b> </font>
                            </div> <br />
                            
                        <label>
                           Label Height :
                    <input class="form-control" type="number" step="0.1" />
                        </label>  
                        <label>
                           Label Width :
                    <input class="form-control" type="number" step="0.1" />
                        </label> <br />


                        </div>

                        <div class="mt-3 tab-pane fade active show" id="built">
                            <div class="built-ticket-body" style="height: 15mm; width: 50mm;">  
                                <font id="b0" style="font-size: 8pt; position: absolute; top: 2mm; left: 2.5mm;" color="red">
                                    <img src="../image/icon/qr-code.svg" style="height: 10mm;width:10mm;" />
                                </font>
                                <font id="b1" style="font-size: 8pt; position: absolute; top: 1.2mm; left: 15.5mm;" color="black"><b>E4RNS5-10000-00001</b> </font>
                                <font id="b2" style="font-size: 8pt; position: absolute; top: 5.2mm; left: 15.5mm;" color="green"><b>MID MT</b></font>
                                <font id="b3" style="font-size: 8pt; position: absolute; top: 5.2mm; left: 30.5mm;" color="skyblue"><b>DRIVER</b></font> 
                                <font id="b4" style="font-size: 8pt; position: absolute; top: 9mm; left: 15.5mm;" color="red"><b>PY1B</b></font> 
                                <font id="b5" style="font-size: 8pt; position: absolute; top: 9mm; left: 25.5mm;" color="gray"><b>23-10-2023</b></font> 
                            
                            </div> 
                            <br />

                            <label>
                                Label Height :
                                <input class="form-control" type="number" step="0.1" />
                            </label>
                            <label>
                                Label Width :
                                <input class="form-control" type="number" step="0.1" />
                            </label>
                            <br />


                        </div>

                    </div>


                    <div id="sizeControl" class="mt-4">
                        <h5>PY1B</h5>  
                        <span>Alignment : </span>
                        <br />
                        <button class="btn btn-primary" type="button">&larr;</button> 
                        <button class="btn btn-primary" type="button">&uarr;</button> 
                        <button class="btn btn-primary" type="button">&rarr;</button> 
                        <button class="btn btn-primary" type="button">&darr;</button> 
                        <br />
                        <br />
                        <label>
                            Font Size :
                    <input class="form-control" type="number" step="0.1" />
                        </label>
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
                    borderRadius: '5px'
                }
            }).showToast();

    </script>

</body>
</html>
