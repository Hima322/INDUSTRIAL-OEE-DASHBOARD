<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="material_delay.aspx.cs" Inherits="WebApplication2.andon.MaterialDelay" %> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Delay Records</title> 
    <meta name="viewport" content="width=device-width, initial-scale=1" />   
    <script src="../js/libs/jquery.min.js"></script> 
    <script>


        $(document).ready(function () {
            getOperatorDelay()
                $("#stationContainer").html( 
                    new Array(25).fill(0).map((e,i) => 
                    `<div>
                         <h1>Staion${i + 1}</h1>
                         <h1>${e || 0}</h1>
                     </div>
                 `))
        })

        setInterval(function () {
            getOperatorDelay()
               
        }, 1000);



        const getOperatorDelay = () => {
            $.ajax({
                type: "POST",
                url: "material_delay.aspx/GetOperatorDelay",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {

                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)    

                        let total_delay = data.map(e => e.DelaySecond).reduce((e, a) => e + a)
                        let total_time = (total_delay / 60).toFixed(2).split(".")
                        let time_text = total_time[0] + " MIN " + Math.round(parseFloat(0 + "." + total_time[1]) * 60) + " SEC "
                        $("#delayLabel").text(time_text)

                        let stationArr = new Array(25).fill(0)
                        data.map(e => (stationArr[e.StationNo - 1] = e.DelaySecond)) 
                        $("#stationContainer").html(
                            stationArr.map((e, i) =>
                                `<div>
                                     <h1>Staion${i + 1}</h1>
                                     <h1>${e || 0}</h1>
                                 </div>
                             `)) 
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
            font-weight:700;
            padding: 0 50px;
            box-sizing: border-box;
        }

        #stationContainer{
            color:yellow;
            display:grid;
            grid-template-columns:1fr 1fr 1fr 1fr 1fr
        }
        #stationContainer div{
            text-align:center;  
        }
        #stationContainer div h1:first-child{
            background:yellow;
            color:black;
            font-size:50px;
        }
        #stationContainer div h1:last-child{  
            padding:5px 0px;
            font-size:50px;
        }
        #stationContainer div.delay{
            background:#ff474c;
        } 
         
</style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            
        <%--header part--%>
        <div class="header">
            <p id="current_date"></p>
            <p>MATERIAL DELAY</p>
            <p>TOTAL : <span id="delayLabel">00</span></p>
        </div>

        <script>
                document.getElementById("current_date").innerHTML = new Date().toLocaleDateString() 
            setInterval(function () {
                document.getElementById("current_date").innerHTML = new Date().toLocaleDateString() 
            }, 1000)
        </script> 
             

        <div id="stationContainer"> 
        </div>

             
        </div>
    </form>
</body>
</html>
