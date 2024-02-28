<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="main.aspx.cs" Inherits="WebApplication2.andon.Main" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ANDON</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />  
    <script src="../js/libs/jquery.min.js"></script>
    <script src="../js/libs/moment.min.js"></script>
    <script>
        var current_shift = "";
        var current_id = 0 
        var total_target = 0;
        var total_production = 0; 
        var total_delay = 0;
        var total_break = 60 * 60;
        var total_reject_seat = 0


        $(document).ready(function () { 
            getCurrentShiftName()
            getAllAndonDetails()
            handleAndon()
            getSeaftyLine()
            getUpcommingSeat()
            getTotalDelay()
            //getTotalBreak()
            getTodayRejectTask()
            handleCalculateOEE() 
            //getCurrentShiftRowId()
        }) 

        setInterval(function () { 
            getCurrentShiftName()
            getAllAndonDetails() 
            handleAndon()
            getUpcommingSeat()
            getTotalDelay()
            //getTotalBreak()
            getTodayRejectTask()
            handleCalculateOEE()
        }, 1000);
         

        //handle delete btn click function 
        const handleAndon = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetShift",
                data: `{ cs : '${current_shift.at(0)}', CurrentShiftRowId : '${current_id}' }`,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        var data = JSON.parse(res.d)

                        for (var i = 0; i < data.length; i++) {

                            let startDateParse = Date.parse(new Date().toISOString().split('T')[0] + " " + String(data[i].HourName.split("-")[0]))
                            let endDateParse = Date.parse(new Date().toISOString().split('T')[0] + " " + String(data[i].HourName.split("-")[1]))

                            if (startDateParse < endDateParse) {
                                if ((Date.now() >= startDateParse) && (Date.now() < endDateParse)) {
                                    current_id = data[i].ID
                                    console.log(current_id)
                                }
                            } else {
                                if ((Date.now() < Date.parse(new Date().toISOString().split('T')[0] + " 23:59:59 ")) && (Date.now() > startDateParse) || (Date.now() > Date.parse(new Date().toISOString().split('T')[0]) && Date.now() < endDateParse)) {
                                    current_id = data[i].ID
                                    console.log(current_id + "<<<")
                                } else {
                                    if ((Date.now() >= startDateParse) && (Date.now() < endDateParse)) {
                                        current_id = data[i].ID
                                        console.log(current_id)
                                    } 
                                }
                            }
                        }

                        document.getElementById("andon_data").innerHTML = 
                            data.map(e => `<tr> 
                                      <td>${e.HourName}</td>  
                                        <td>${e.Target}</td>  
                                        <td data-diff=${e.Target - e.Production < 0 ? '+' + Math.abs(e.Target - e.Production) : e.Target - e.Production} class="production_status
                                        ${(e.ID > current_id) && (current_id != 0) ? 'hide' : ' '}
                                        ${e.Production >= e.Target ? 'green' : 'red'}   
                                        ${e.ID == current_id ? 'current' : ' '}  
                                        ${current_shift.length > 3 ? 'pause_animation' : ' '}  
                                        "> ${e.Production}</td>  
                                    </tr>` 
                            ).join("")
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const getSeaftyLine = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetSeaftyLine",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    $("#seaftyLine").html(res.d)
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const getTodayRejectTask = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GET_TODAY_REJECTED_SEAT",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {  
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        total_reject_seat = data.length
                    } 
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        const getTotalBreak = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetTotalBreak",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 

                    if (res.d != "Error") {
                        let data = JSON.parse(res.d) 
                        total_break = data.map(e => e.DelaySecond).reduce((e, a) => e + a) 
                    } 
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 
        
        const getTotalDelay = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetTotalDelay",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => { 

                    if (res.d != "Error") {
                        let data = JSON.parse(res.d) 
                        total_delay = data.map(e => e.DelaySecond).reduce((e, a) => e + a) 
                    } 
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        } 

        const handleCalculateOEE = _ => {
            let total_second = (Date.now() - (new Date(new Date().toLocaleDateString() + " 06:30 am").getTime())) / 1000

            let a = (total_second - total_delay - total_break) / total_second
            let p = total_production / ((total_second - total_delay - total_break) / 60)
            let q = (total_production - total_reject_seat) / (total_production || 0)
             
            let oee = (a * p * q) * 100
            $("#oeeId").text((oee || 0.0).toFixed(2))
        }
        
        const getUpcommingSeat = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GET_UPCOMMING_SEAT",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)
                        console.log(data)
                        $("#upcomming_seat").html(
                            data.map((e,i) => `
                            <div style="color:${i == 0 ? "limegreen" : "yellow"};">
                                 <big>${e.Variant}</big>
                                <i>${e.SeatType == "DRIVER" ? "DRIVER-LH" : "CO-DRIVER-RH" }</i>
                            </div>
                            `)
                        )
                    }
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }
        
        const getCurrentShiftName = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetCurrentShiftName",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    current_shift = res.d
                    $("#display_current_shift").text(res.d)
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        const getCurrentShiftRowId = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetCurrentShiftRowId",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    console.log(res.d)
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

        //handle get all andon details function 
        const getAllAndonDetails = () => {
            $.ajax({
                type: "POST",
                url: "main.aspx/GetAllAndonDetails",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        let data = JSON.parse(res.d)  

                        let shiftA = data.filter(f => f.ShiftName == "A")
                        let shiftB = data.filter(f => f.ShiftName == "B")
                        let shiftC = data.filter(f => f.ShiftName == "C")

                        let targetA = shiftA.map(m => m.Target).reduce((e, i) => e + i)
                        let targetB = shiftB.map(m => m.Target).reduce((e, i) => e + i)
                        let targetC = shiftC.map(m => m.Target).reduce((e, i) => e + i)

                        let actualA = shiftA.map(m => m.Production).reduce((e, i) => e + i)
                        let actualB = shiftB.map(m => m.Production).reduce((e, i) => e + i)
                        let actualC = shiftC.map(m => m.Production).reduce((e, i) => e + i)

                        total_target = targetA + targetB + targetC;
                        total_production = actualA + actualB + actualC;

                        document.getElementById("shift_details").innerHTML = `
                              <div><span>SHIFT-A </span><i>${actualA}/${targetA}</i><section class="${current_shift.at(0) == "A" ? "high_lighter" : ""}" ></section></div>
                              <div><span>SHIFT-B </span><i>${actualB}/${targetB}</i><section class="${current_shift.at(0) == "B" ? "high_lighter" : ""}" ></section></div>
                              <div><span>SHIFT-C </span><i>${actualC}/${targetC}</i><section class="${current_shift.at(0) == "C" ? "high_lighter" : ""}" ></section></div>  
                          `
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
            height: 65px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 40px;
            font-weight:700;
            padding: 0 95px;
            box-sizing: border-box;
        }

        .shift_div {
            font-size: 38px;
            padding: 9px 90px;
            background: lightblue;
            box-sizing: border-box;
            display: flex;
            justify-content: space-between;
            font-weight:700;
        }

        .main_data_div {
            display: flex;
        }

        table {
            flex: 1;
            font-size: 40px;
            text-align: center;
            color: yellow;
        }

            table thead {
                background: yellow;
            }

                table thead tr {
                    display: flex;
                    justify-content: space-around;
                    align-items: center;
                    height: 62px;
                    font-weight: 700;
                    color: #000;
                }

            table tr {
                display: flex;
                height: 63px;
                font-weight: 700;
            }

                table tr td {
                    flex: 1;
                    position: relative;
                }

                    table tr td.production_status::after {
                        content: attr(data-diff);
                        position: absolute;
                        top: 17px;
                        right: 50px;
                        border-radius: 30px;
                        font-size: 20px;
                        color: black;
                        background: yellow;
                        z-index: 9;
                        width: 30px;
                        height: 30px;
                        opacity: 0;
                        line-height: 28px;
                    }

                    table tr td.production_status.green::after {
                        background: limegreen;
                        opacity: 1;
                    }

                    table tr td.production_status.red::after {
                        background: red;
                        opacity: 1;
                    }

                    table tr td.production_status.current::after {
                        background: yellow;
                        animation: high_lighter 1s infinite ease-out;
                        opacity: 1;
                    }

                    table tr td.production_status.current.pause_animation::after {
                        animation-play-state: paused;
                    }

                    table tr td.production_status.hide::after {
                        opacity: 0;
                    }

                table tr:nth-child(even) {
                    background: rgb(30, 30, 30);
                }

        .main_data_div #shift_details {
            display: flex;
            align-items: center;
            flex-direction: column;
            color: yellow;
            width: 450px;
            margin-top:10px;
        }

            .main_data_div #shift_details div {
                width: 100%;
                height: 100%;
                display: flex;
                justify-content: center;
                align-items: center; 
                gap: 10px;
                font-size:38px;  
            }

                .main_data_div #shift_details div span {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    font-weight:650;
                }


        .high_lighter {
            width: 30px;
            height: 30px;
            border-radius: 30px;
            background: attr(data-color);
            transform: scale(0.3);
            animation: high_lighter 1s infinite ease-out;
            background: limegreen;
        }

        .self_care_text marquee {
            color: #ff474c;
            font-size: 45px;
            font-weight: 600;
            padding: 12px 0;
        }

        @keyframes high_lighter {
            to {
                transform: scale(.9);
            }
        }

        #upcomming_seat div{
            color:yellow;
            font-size:30px;
            text-align:center;  
        }
        
        #upcomming_seat div big{ 
            font-weight:700;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">

        <%--header part--%>
        <div class="header">
            <p id="current_date"></p>
            <p>ANDON</p>
            <p id="current_time"></p>
        </div>
        <script>
            setInterval(function () {
                document.getElementById("current_date").innerHTML = new Date().toLocaleDateString()
                document.getElementById("current_time").innerHTML = new Date().toLocaleTimeString('en-US', { hour12: false, })
            }, 1000)
        </script>

        <%--show current shift--%>
        <div class="shift_div">
            <span>Shift : <span id="display_current_shift"></span></span>
            <span>Indexing Mode</span>
            <span>OEE : <span id="oeeId">00</span>%</span>
        </div>

        <div class="main_data_div">
            <%--to show out data--%>

            <table cellspacing="0">
                <thead>
                    <tr>
                        <td>TIMING</td>
                        <td>TARGET</td>
                        <td>ACTUAL</td>
                    </tr>
                </thead>
                <tbody id="andon_data">
                    <%--data will be show from ajax--%>
                </tbody>
            </table>

            <%--previous shift data--%>
            <div style="display:flex;justify-content:space-between;flex-direction:column;margin-bottom:15px;"> 
                <div id="shift_details"></div>
                &nbsp;
                <div style="background:yellow;font-size:30px;font-weight:700;text-align:center;padding:5px;">UPCOMMING VARIANTS</div>
                <div id="upcomming_seat"></div> 
            </div>


        </div>
        <hr />

        <div class="self_care_text">
            <marquee id="seaftyLine">
            </marquee>
        </div>

    </form>
</body>
</html>
