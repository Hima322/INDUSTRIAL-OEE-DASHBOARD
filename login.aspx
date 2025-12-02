<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="WebApplication2.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ebco pvt ltd</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="stylesheet" href="css/libs/bootstrap.min.css" />
    <link rel="stylesheet" href="css/libs/font-awesome.min.css" />
    <link rel="stylesheet" href="css/libs/toastify.min.css" />
    <script src="js/libs/jquery.min.js"></script>
    <script src="js/libs/bootstrap.bundle.min.js"></script>
    <script src="js/libs/toastify-js.js"></script>

    <style>
        body {
            background: linear-gradient(135deg, #007bff, #6610f2);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            margin: 0;
            padding: 15px;
        }

        .login-wrapper {
            width: 100%;
            max-width: 420px;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.25);
            padding: 35px 30px;
            animation: fadeIn 0.6s ease-in-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(15px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo {
            display: block;
            margin: 0 auto 15px auto;
            height: 65px;
        }

        .company-name {
            text-align: center;
            font-size: 22px;
            font-weight: 700;
            color: #007bff;
            letter-spacing: 0.5px;
            margin-bottom: 15px;
        }

        h3 {
            text-align: center;
            font-weight: 700;
            color: #333;
            margin-bottom: 25px;
        }

        label {
            font-weight: 600;
            color: #444;
        }

        .form-control {
            border-radius: 10px;
            height: 45px;
        }

        .btn-primary {
            background: linear-gradient(90deg, #007bff, #6610f2);
            border: none;
            height: 45px;
            border-radius: 10px;
            width: 100%;
            font-weight: 600;
            letter-spacing: 0.5px;
            transition: transform 0.2s ease;
        }

            .btn-primary:hover {
                transform: scale(1.02);
            }

        .footer-text {
            text-align: center;
            font-size: 13px;
            color: gray;
            margin-top: 15px;
        }

        /* Mobile optimization */
        @media (max-width: 576px) {
            .login-wrapper {
                padding: 25px 20px;
            }

            .company-name {
                font-size: 20px;
            }

            .logo {
                height: 55px;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="login-wrapper">
            <div class="company-name">
                <img src="../image/companyLogo.jpg" alt="Company Logo" style="height: 30px; vertical-align: middle; margin-right: 8px;">
                ebco pvt ltd
            </div>

            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <input id="username" class="form-control" placeholder="Enter your username" />
            </div>

            <div class="mb-3 position-relative">
                <label for="password" class="form-label">Password</label>
                <div class="input-group">
                    <input id="password" class="form-control" type="password" placeholder="Enter your password" />
                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                        <i class="fa fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="button" class="btn btn-primary mt-3" id="loginBtn" onclick="AdminLogin()">
                Login
            </button>

            <div class="footer-text">
                © 2025 AB-VISION CONTROL SYSTEM. All Rights Reserved.
            </div>
        </div>
    </form>

    <script>
        //// Redirect if already logged in
        //if (localStorage.getItem("admin") != null) {
        //    location.href = "index.aspx";
        //}

        const toast = txt => Toastify({
            text: txt,
            duration: 3000,
            gravity: "bottom",
            position: "right",
            style: {
                background: "linear-gradient(to right, #007bff, #6610f2)"
            }
        }).showToast();

        $("#togglePassword").on("click", function () {
            const input = $("#password");
            const icon = $(this).find("i");
            if (input.attr("type") === "password") {
                input.attr("type", "text");
                icon.removeClass("fa-eye").addClass("fa-eye-slash");
            } else {
                input.attr("type", "password");

                icon.removeClass("fa-eye-slash").addClass("fa-eye");
            }
        });

        function AdminLogin() {
            const username = $("#username").val().trim();
            const password = $("#password").val().trim();

            if (username === "") return toast("Username is required.");
            if (password === "") return toast("Password is required.");

            $.ajax({
                type: "POST",
                url: "login.aspx/LoginMe",
                data: JSON.stringify({ username: username, password: password }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (res.d.Success) {
                        localStorage.clear();
                        toast("Login Successful! Welcome " + res.d.UserName);
                        localStorage.setItem("admin", res.d.UserName);
                        localStorage.setItem("role", res.d.Role);

                        // ✅ Redirect after success
                        setTimeout(() => {
                            window.location.href = "index.aspx";
                        }, 1000);
                    } else {
                        toast("Invalid username or password.");
                    }
                },
                error: function () {
                    toast("Server error. Please try again later.");
                }
            });
        }

    </script>
</body>
</html>
