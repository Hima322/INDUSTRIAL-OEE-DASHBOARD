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
        var prnData = []


        $(document).ready(_ => {
            getPrnFile()  
            $("#control").hide()

            var font = document.querySelectorAll(".tab-pane font"); 

            font.forEach(e => {
                e.onclick = () => {  
                    let curr = prnData.find(f => f.Label == e.id)

                    $("#control").show()
                    $("#control").html(`
                        <h5>${e.innerText}</h5>   
                        <br /> 
                        Left - Right 
                        <input class="form-range" onchange="updatePrn(${curr.ID},'left',this.value)" type="range" step="0.1" min="1" value="${curr.Left}" />   <br/>
                        Top - Down
                        <input class="form-range" onchange="updatePrn(${curr.ID},'top',this.value)" type="range" step="0.1" min="1" max="50" value="${curr.Top}" />   <br />
                        Font Size
                        <input class="form-range" onchange="updatePrn(${curr.ID},'width',this.value)" type="range" step="0.1" min="1" max="7" value="${curr.Width}" />   
                        <br /> 
                    `)

                }
            }) 


            $("#Finel0").click(() => {
                let curr = prnData.find(f => f.Label == "Finel0")
                $("#control").show()
                $("#control").html(`
                        <h5>Barcode Image</h5>
                        Left - Right
                        <input class="form-range" onchange="updatePrn(${curr.ID},'left',this.value)" type="range" step="0.1" min="1" value="${curr.Left}" />   <br/>
                        Top - Down
                        <input class="form-range" onchange="updatePrn(${curr.ID},'top',this.value)" type="range" step="0.1" min="1" max="50" value="${curr.Top}" />   <br /><br />
                         
                        <label>
                            Width <small>mm</small>:
                            <input min="1" onkeyup="updatePrn(${curr.ID},'width',this.value)" class="form-control" value="${curr.Width}" type="number" step="0.1" id="fontSize" />
                        </label>
                        <label>
                            Height <small>mm</small>:
                            <input min="1" onkeyup="updatePrn(${curr.ID},'height',this.value)" class="form-control" value="${curr.Height}" type="number" step="0.1" id="fontSize" />
                        </label>
                    `)
            })
            

            $("#Built0").click(() => {
                let curr = prnData.find(f => f.Label == "Built0")
                $("#control").show()
                $("#control").html(`
                        <h5>Barcode Image</h5>
                        Left - Right
                        <input class="form-range" onchange="updatePrn(${curr.ID},'left',this.value)" type="range" step="0.1" min="1" value="${curr.Left}" />   <br/>
                        Top - Down
                        <input class="form-range" onchange="updatePrn(${curr.ID},'top',this.value)" type="range" step="0.1" min="1" max="50" value="${curr.Top}" />   <br /><br />
                         
                        <label>
                            Width <small>mm</small>:
                            <input min="1" onkeyup="updatePrn(${curr.ID},'width',this.value)" class="form-control" value="${curr.Width}" type="number" step="0.1" id="fontSize" />
                        </label>
                        <label>
                            Height <small>mm</small>:
                            <input min="1" onkeyup="updatePrn(${curr.ID},'height',this.value)" class="form-control" value="${curr.Height}" type="number" step="0.1" id="fontSize" />
                        </label>
                    `)
            })

        })

        function getPrnFile() {
            $.ajax({
                type: "POST",
                url: "index.aspx/GET_PRN_FILE",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        prnData = data

                        let finelLabelWidth = data[0].Width
                        let finelLabelHeight = data[0].Height

                        let builtLabelWidth = data[1].Width
                        let builtLabelHeight = data[1].Height
                         
                        data.forEach((e, i) => {
                            if (e.Label == "Finel0" || e.Label == "Built0") {
                                $(`#${e.Label}`).css({
                                    "top": `${e.Top}mm`,
                                    "left": `${e.Left}mm`,
                                    "width": `${e.Width}mm`,
                                    "height": `${e.Height}mm`
                                })
                            } else {
                                $(`#${e.Label}`).css({
                                    "top": `${e.Top}mm`,
                                    "left": `${e.Left}mm`,
                                    "fontSize": `${e.Width}mm`
                                })
                            }
                        })

                        $("#finel-ticket-body").css({ "width": `${finelLabelWidth}mm`, "height": `${finelLabelHeight}mm`})
                        $("#built-ticket-body").css({ "width": `${builtLabelWidth}mm`, "height": `${builtLabelHeight}mm` })

                        $("#FinelLabelHeight").val(finelLabelHeight)
                        $("#FinelLabelWidth").val(finelLabelWidth)

                        $("#BuiltLabelWidth").val(builtLabelWidth)
                        $("#BuiltLabelHeight").val(builtLabelHeight)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        function updatePrn(id,key,value) {
            $.ajax({
                type: "POST",
                url: "index.aspx/UPDATE_PRN_FILE",
                data: `{id:'${id}',key:'${key}',value:'${value}'}`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d == "Done") {
                        getPrnFile()
                    } else {
                        toast(res.d)
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 


    </script>

    <style> 

        #finel-ticket-body, 
        #built-ticket-body{ 
            position: relative;
            border: 1px solid gray;
            border-radius: 5px;
        }
        font,#Finel0,#Built0{
            position:absolute;
            cursor:pointer;
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

                <div style="display:flex;gap:100px;">

                    <div class="tab-content mt-3">
                        <%--all qr ticket group--%>
                        <ul class="nav nav-pills mt-2 mb-4" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active border" id="finel-tab" data-bs-toggle="tab" data-bs-target="#finel" type="button" role="tab" aria-controls="finel" aria-selected="true" onclick='$("#control").hide()'>FINEL TICKET QR</button>
                            </li>

                            <li class="nav-item" role="presentation">
                                <button class="nav-link ms-2 border" id="built-tab" data-bs-toggle="tab" data-bs-target="#built" type="button" role="tab" aria-controls="built" aria-selected="true" onclick='$("#control").hide()'>BUILT TICKET QR</button>
                            </li>
                        </ul>

                        <div class="mt-3 tab-pane fade show active" id="finel">
                            <div id="finel-ticket-body"> 
                                <img id="Finel0" src="../image/icon/qr-code.svg" /> 
                                <font id="Finel1" color="red"><b>PY1B</b></font>
                                <font id="Finel2" color="blue"><b>26-10-2023 10:03</b></font>
                                <font id="Finel3" color="green"><b>MID MT</b></font>
                                <font id="Finel4" color="gray"><b>4W</b></font>
                                <font id="Finel5" color="skyblue"><b>DRIVER SEAT</b></font>
                                <font id="Finel6" color="darkyellow"><b>87050 6VC2A</b></font>
                                <font id="Finel7" color="orange"><b>HOLD</b></font>
                                <font id="Finel8" color="black"><b>E4RNS5-10000-00001260620231003</b> </font>
                            </div> <br /><br />
                            
                        <label>
                           Label Height <small>mm</small>:
                    <input min="1" onkeyup="updatePrn(1,'height',this.value)" id="FinelLabelHeight" class="form-control" type="number" step="0.1" />
                        </label>  
                        <label>
                           Label Width <small>mm</small>:
                    <input min="1" onkeyup="updatePrn(1,'width',this.value)" id="FinelLabelWidth" class="form-control" type="number" step="0.1" />
                        </label> <br />


                        </div>

                        <div class="mt-3 tab-pane fade" id="built">
                            <div id="built-ticket-body">   
                                <img id="Built0" src="../image/icon/qr-code.svg"  /> 
                                <font id="Built1" color="black"><b>E4RNS5-10000-00001</b> </font>
                                <font id="Built2" color="green"><b>MID MT</b></font>
                                <font id="Built3" color="skyblue"><b>DRIVER</b></font> 
                                <font id="Built4" color="red"><b>PY1B</b></font> 
                                <font id="Built5" color="gray"><b>23-10-2023</b></font> 
                            
                            </div> 
                            <br /><br />

                            <label>
                                Label Height <small>mm</small>:
                                <input min="1" onkeyup="updatePrn(2,'height',this.value)" id="BuiltLabelHeight" class="form-control" type="number" step="0.1" />
                            </label>
                            <label>
                                Label Width <small>mm</small>:
                                <input min="1" onkeyup="updatePrn(2,'width',this.value)" id="BuiltLabelWidth" class="form-control" type="number" step="0.1" />
                            </label>
                            <br />


                        </div>

                    </div>


                    <div id="control" class="mt-4" style="min-width:400px;">
                        
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
