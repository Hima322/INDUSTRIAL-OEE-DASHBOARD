<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.andon.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Andon Screen</title>
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>  
    <script>
        var currentScreen = "main";

        $(document).ready(function () {
            getCurrentAnonScreen()
        })

        setInterval(_ => {
            getCurrentAnonScreen()
            if (currentScreen != $("#obj").attr("data")) {
                $("#obj").attr("data", currentScreen)
            }
        }, 1000)

        const getCurrentAnonScreen = () => {
            $.ajax({
                type: "POST",
                url: "index.aspx/GetCurrentAnonScreen",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: "true",
                cache: "false",
                success: (res) => {
                    if (res.d != "Error") {
                        currentScreen  = res.d + ".aspx" 
                    } 
                },
                Error: function (x, e) {
                    console.log(e);
                }
            })
        }

    </script>
    <style>
        object{
            position:fixed;
            top:0;
            left:0; 
            width:100%;
            height:100vh !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server"> 
        <object data="../image/empty.png" id="obj"></object> 
    </form>
</body>
</html>
