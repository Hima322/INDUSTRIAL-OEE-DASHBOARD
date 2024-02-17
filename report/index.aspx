<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebApplication2.report.index" %> 
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Station Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="../css/libs/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="../css/libs/font-awesome.min.css" /> 
    <script src="../js/libs/bootstrap.bundle.min.js"></script>  
    <script type="text/javascript" src="../js/libs/jquery.min.js"></script>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
    <div>
        
         
            <%--navbar header--%> 
                <div class="navbar navbar-light d-flex p-3">     
                    <big>
                        <img src="../image/icon/arrow-left.svg" onclick="history.back()" class="btn" />
                        <b>GENERATE REPORT</b>
                    </big>                     
                </div>

        <%--body content--%> 
        <div class="container">            
          <div class="tab-content">

            <%--filter report button group--%> 
            <ul class="nav nav-pills" id="myTab" role="tablist">
                <li class="nav-item" role="presentation">
                  <button class="nav-link active border" id="model-tab" data-bs-toggle="tab" data-bs-target="#model" type="button" role="tab" aria-controls="model" aria-selected="true">Model</button> 
                </li> 

                <li class="nav-item ms-2" role="presentation">
                  <button class="nav-link border" id="day-tab" data-bs-toggle="tab" data-bs-target="#day" type="button" role="tab" aria-controls="day" aria-selected="false">Day</button>
                </li>

                <li class="nav-item ms-2" role="presentation">
                  <button class="nav-link border" id="shift-tab" data-bs-toggle="tab" data-bs-target="#shift" type="button" role="tab" aria-controls="shift" aria-selected="false">Shift</button>
                </li>

                <li class="nav-item ms-2" role="presentation">
                  <button class="nav-link border" id="serial-tab" data-bs-toggle="tab" data-bs-target="#serial" type="button" role="tab" aria-controls="serial" aria-selected="false">Serial</button>
                </li>
            </ul> 

            <%--model wise report code--%> 
            <div class="row mt-3 tab-pane fade show active" id="model">
            <div class="row">
                <div class="col-sm-2">
                    <b>Model :</b>
                    <select class="form-select">
                        <option>PY1B</option>
                        <option>PY2B</option>
                        <option>PY3B</option>
                    </select>
                </div>
                <div class="col-sm-3">
                    <b>Variant :</b>
                    <select class="form-select">
                        <option>Driver</option>
                        <option>Co driver</option>
                        <option>loremsf </option>
                    </select>
                </div>
                <div class="col-sm-2">
                    <b>From :</b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-2">
                    <b>To : </b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-3"> 
                    <br />
                    <button class="btn btn-primary">SHOW</button> &nbsp;
                    <button class="btn btn-primary">DOWNLOAD</button>
                </div> 
            </div>
            </div>

            <%--shift wise report code--%>            
            <div class="mt-3 collapse tab-pane fade" id="shift">
                <div class="row">
                <div class="col-sm-2">
                    <b>Shift :</b>
                    <select class="form-select">
                        <option>A</option>
                        <option>B</option>
                        <option>C</option>
                    </select>
                </div> 
                <div class="col-sm-2">
                    <b>From :</b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-2">
                    <b>To : </b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-3"> 
                    <br />
                    <button class="btn btn-primary">SHOW</button> &nbsp;
                    <button class="btn btn-primary">DOWNLOAD</button>
                </div> 
                </div> 
            </div>

            <%--day wise report code--%>            
            <div class="mt-3 collapse tab-pane fade" id="day">
                <div class="row"> 
                <div class="col-sm-2">
                    <b>From :</b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-2">
                    <b>To : </b>
                    <input type="date" class="form-control"  />
                </div>
                <div class="col-sm-3"> 
                    <br />
                    <button class="btn btn-primary">SHOW</button> &nbsp;
                    <button class="btn btn-primary">DOWNLOAD</button>
                </div> 
                </div> 
            </div>

            <%--serial wise report code--%>
            <div class="mt-3 collapse tab-pane fade" id="serial"> 
                <div class="row">
                <div class="col-sm-4">
                    <b>Serial Number :</b>
                    <input class="form-control" placeholder="eg. 00541291000118XZT70010022073290R" />
                </div> 
                <div class="col-sm-3"> 
                    <br />
                    <button class="btn btn-primary">SHOW</button> &nbsp;
                    <button class="btn btn-primary">DOWNLOAD</button>
                </div> 
                </div> 
            </div>

        </div> 
     </div> 

         
        <div class="container-fluid">      
            <%--code for show reported data--%> 
             
        </div>
         
         
    </div>
    </form>
</body>
</html>