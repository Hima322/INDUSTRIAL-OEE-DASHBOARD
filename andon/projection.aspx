<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="projection.aspx.cs" Inherits="WebApplication2.andon.Projection" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Delay Records</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script src="../js/libs/jquery.min.js"></script>
    <script>

        $(document).ready(function () {
            getProductionRejection()
        })

        setInterval(function () {
            getProductionRejection()
        }, 1000)

        //function for get left seat data in database 
        function getProductionRejection() {
            $.ajax({
                type: "POST",
                url: "projection.aspx/PRODUCTION_REJECTION",
                data: ``,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d) 

                        let prod = data.filter(f => f.STAUS == "OK").length 
                        let reject = data.filter(f => f.STAUS == "REJECT").length 
                        let hold = data.filter(f => f.STAUS == "HOLD").length 

                        $("#total_prod").text(prod)
                        $("#total_reject").text(reject)
                        $("#total_hold").text(hold)

                        let model = [...new Set(data.map(e => e.Model))]
                        let mdlVrt = [...new Set(data.map(e => e.ModelVariant))]


                        let mdlVrtArr = []
                        mdlVrt.forEach(e => mdlVrtArr.push({
                            model: data.filter(f => f.ModelVariant == e)[0].Model,
                            variant: data.filter(f => f.ModelVariant == e)[0].Variant,
                            prod: data.filter(f => f.STAUS == "OK" && f.ModelVariant == e).length,
                            reject: data.filter(f => f.STAUS == "REJECT" && f.ModelVariant == e).length,
                            hold: data.filter(f => f.STAUS == "HOLD" && f.ModelVariant == e).length,
                        }))


                        let finelArr = []
                        model.forEach(e => finelArr.push(
                            mdlVrtArr.filter(f => f.model == e)
                        ))

                        $("#dataContainer").html("")

                        finelArr.forEach((e, i) => {
                            $("#dataContainer").append(

                            `<div class="model_name_container" data-text="${e[0].model}"> 
                                <div class="rowContainer" id="${e[0].model}">  
                                </div>
                            </div> 
                            `)

                            e.forEach(j =>
                                $(`#${e[0].model}`).append(`
                                    <div class="main_row_container"> 
                                        <div>${j.variant}</div>
                                        <div>${j.prod}</div>
                                        <div>${j.reject}</div>
                                        <div>${j.hold}</div>
                                    </div>    
                                `) 
                            )
                        })  
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }


    </script>
    <style>
        * {
            margin: 0;
            padding: 0;
        }

        body {
            background: rgb(0,0,0);
            font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,Noto Sans,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol,Noto Color Emoji;
        }

        .header {
            width: 100%;
            background: blue;
            color: yellow;
            height: 70px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 40px;
            font-weight: 700;
            padding: 0 50px;
            box-sizing: border-box;
        }
         
        #dataContainer{
            display:flex;
            flex-direction:column;
            justify-content:space-around; 
            margin-left:60px;
        }

        .data_header{
            display:flex;
            justify-content:space-around;
            align-items:center;
            height:65px;
            background:lightblue; 
            padding-left:60px;
        }

        .data_header span{
            font-size:40px;
            font-weight:700;
        }

        .model_name_container h3{
            background: yellow; 
            height:55px; 
            font-size:38px;
            font-weight:700;
            padding-top:5px;
            text-align:center;
        }

        .rowContainer div{
            height:70px; 
            display:flex;
            justify-content:space-around;
            align-items:center;
        }

        .rowContainer .main_row_container:nth-child(even) {
            background: rgb(30, 30, 30);
        } 

        .rowContainer div div{
            font-size:50px;
            font-weight:700;  
            color:yellow;  
            flex:1; 
        }

        .rowContainer div:nth-child(2){
            color:limegreen;
        }
         
        .rowContainer div:nth-child(3){
            color:red;
        }
         
        .rowContainer div:nth-child(1){
            font-size:35px;
        }

        .model_name_container{ 
            position:relative;  
            min-height:100px;
        }

        .model_name_container::before{
            content:attr(data-text);
            position:absolute;
            top:0;
            left:-60px;
            background:yellow;
            height:100%;
            width:70px;
            font-size:40px;
            font-weight:700; 
            writing-mode:vertical-rl;
            display:grid; 
            place-items:center;
        }
          
        .model_name_container:nth-child(even)::after{
            content:"";
            position:absolute;
            width:100%; 
            top:0;
            left:0; 
            border-top:2px solid lightblue;
        }
         
        .model_name_container:nth-child(even)::before{
            background:lightblue;
        } 
 
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>

            <%--header part--%>
            <div class="header">
                <p id="current_date"></p>
                <p>ACTUAL : <span id="total_prod">0</span></p>
                <p>REJECT : <span id="total_reject">0</span></p>
                <p>HOLD : <span id="total_hold">0</span></p>
            </div>

            <script>
                document.getElementById("current_date").innerHTML = new Date().toLocaleDateString()
                setInterval(function () {
                    document.getElementById("current_date").innerHTML = new Date().toLocaleDateString()
                }, 1000)
            </script>

            <div id="main_data_div"> 
                
                <div class="data_header"> 
                    <span>Variant</span>
                    <span>Actual</span>
                    <span>Reject</span>
                    <span> &nbsp; Hold &nbsp;</span>
                </div>


                <div id="dataContainer"> 
                    <%--<div class="model_name_container">
                        <h3>BBA</h3>
                        <div id="rowContainer">
                            <div class="main_row_container">
                                <div>Mid Mt</div>
                                <div>34</div>
                                <div>11</div>
                                <div>2</div>
                            </div>    
                        </div>
                    </div>--%>
                </div>

            </div>

        </div>
    </form>
</body>
</html>
