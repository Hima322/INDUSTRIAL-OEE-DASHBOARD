using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.Json;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using S7.Net;
using System.Net.NetworkInformation;
using S7.Net.Interfaces;
using System.Net.Sockets;
using System.Net;
using System.Text;

namespace WebApplication2.station
{
    public partial class Station16 : System.Web.UI.Page
    {
        public static int station_number = 0;
        public static int sequence_number = 0;
        public static long seatDataId = 0;
        public static string CurrentError = "";
        public static string station_name = "";
        public static string station_id = "";
        public static string seat_type = "";
        public static string fg_part_number = "";

        public static int functionCallCount = 0;

        public static Socket DCserver;
        private static bool Subscribed = false;
        private static bool IsDcToolEnable = false;
        private static string CurrentDcToolIp = "";
        private static int CurrentDcToolPort = 0;
        public static bool StartTightening = false;
         

        private void Page_Load(object sender, EventArgs e)
        {

        }
         
        [WebMethod]
        public static string GetDcToolIp(string station)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var torqueIpRes = mdbEntities.STD_TorqueTable.Where(j => j.Station == station).FirstOrDefault();
                    if (torqueIpRes != null)
                    {
                        string val = torqueIpRes.TorqueToolIPAddress;
                        CurrentDcToolIp = val.Split(':')[0];
                        CurrentDcToolPort = int.Parse(val.Split(':')[1]);

                        if (IS_DCTOOL_CONNECTED())
                        {
                            DisableTool();
                        }
                        if (torqueIpRes.TorqueToolIPAddress == "")
                        {
                            return "Error";
                        }
                        else
                        {
                            return CurrentDcToolIp;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error" + ex.Message;
            }
            return "Error";
        }
         
        [WebMethod]
        public static string PING_DCTOOL()
        {
            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(CurrentDcToolIp);

                // check after the ping is n success
                if (PR.Status.ToString() == "Success")
                {
                    return "Done";
                }
            }
            catch
            {
                return "Error";
            }
            return "Error";
        }

        public static bool IS_DCTOOL_CONNECTED()
        {
            if (DCserver.Connected == false)
            {
                DCserver = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                DCserver.Connect(IPAddress.Parse(CurrentDcToolIp), CurrentDcToolPort);

                byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x30, 0x31, 0x30, 0x30, 0x33, 0x30, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x0 };
                int sent = DCserver.Send(byteData, SocketFlags.None);
                byte[] byteFrom = new byte[1025];
                int iRx = DCserver.Receive(byteFrom);
                string ResultCheck = System.Text.Encoding.ASCII.GetString(byteFrom);
                string ResultCheck1 = ResultCheck.Substring(4, 4);
                if (ResultCheck1 == "0002")
                {
                    return true;
                }
                else
                { return false; }
            }
            else
            {
                return true;
            }
        }

        [WebMethod]
        public static string GetStationInfo(string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var d = db.StationAssignments.Where(i => i.StationNameID == station).FirstOrDefault();
                    if (d != null)
                    {
                        station_name = d.Station_Name;
                        station_id = d.StationNameID;
                    }
                }

            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
            return station_name;
        }

        [WebMethod]
        public static string UserLogin(string Userid = "", string Station = "")
        {
            using (TMdbEntities db = new TMdbEntities())
            {
                var d = db.USERs.Where(i => i.UserID == Userid).FirstOrDefault();
                if (d != null)
                {
                    if (d.Authenticated == 1)
                    { return "Already login at station " + d.WorkingAtStationID; }
                    else
                    {
                        d.WorkingAtStationID = Station;
                        d.Authenticated = 1;

                        //add data inside operator work time 
                        OperatorWorkTime operatorWorkTime = new OperatorWorkTime
                        {
                            StationNameID = Station,
                            OperatorName = Userid,
                            LoginTime = DateTime.Now
                        };

                        db.OperatorWorkTimes.Add(operatorWorkTime);
                        db.SaveChanges();
                        return "success";
                    }
                }
                else
                { return "User is not Available"; }
            }
        }

        [WebMethod]
        public static string UserLogout(string Userid, string Station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var d = db.USERs.Where(i => i.UserID == Userid).FirstOrDefault();
                    if (d != null)
                    {
                        d.WorkingAtStationID = "";
                        d.Authenticated = 0;

                        //update logout time inside operator work time  
                        var owtRes = db.OperatorWorkTimes.Where(i => i.OperatorName == Userid && i.StationNameID == Station && i.LogoutTime == null).FirstOrDefault();
                        if (owtRes != null)
                        {
                            owtRes.LogoutTime = DateTime.Now;
                        }
                        db.SaveChanges();
                        return "success";
                    }
                    else
                    { return "User Unavailable."; }
                }

            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string GetCurrentUser(string station)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var user = mdbEntities.USERs.Where(i => i.WorkingAtStationID == station).FirstOrDefault();
                    if (user != null)
                    {
                        return JsonSerializer.Serialize(user);
                    }
                    else
                    {
                        return "USER_NULL";
                    }
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string GetBomList(string fgpart)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var task = mdbEntities.BOMs.Where(i => i.FG_PartNumber == fgpart).ToList();
                    if (task != null)
                    {
                        return JsonSerializer.Serialize(task);
                    }
                    else
                    {
                        return "Error";
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
        }

        [WebMethod]
        public static string GetTorqueGroupList(string fgpart)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var modelDetailsRes = mdbEntities.MODEL_DEATILS.Where(i => i.FG_PartNumber == fgpart).FirstOrDefault();
                    if (modelDetailsRes != null)
                    {
                        var torqueList = mdbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where TaskType = 'Torque' and " + modelDetailsRes.ModelVariant + "= '1'").ToList();
                        if (torqueList != null)
                        {
                            return JsonSerializer.Serialize(torqueList);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            return "Error";
        }
         
        [WebMethod]
        public static string IsQRValid(string build_ticket)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    var seatRes = dbEntities.SEAT_DATA.Where(i => i.BuildLabelBarcode == build_ticket).OrderByDescending(o => o.ID).FirstOrDefault();
                    if (seatRes != null)
                    {
                        seatDataId = seatRes.ID;

                        if (seatRes.STAUS == "REJECT")
                        {
                            return "Rejected";
                        }

                        var res = dbEntities.ReworkTables.Where(i => i.SeatID == seatRes.ID.ToString() && i.SeatStatus == "NG").ToList();
                        if (res.Count > 0)
                        {
                            seatRes.StationNo = 13;
                            dbEntities.SaveChanges();

                            return JsonSerializer.Serialize(res);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            return "Error";
        }

        [WebMethod]
        public static string ScanExecuteTask(string bom, string val)
        {
            UpdateSeatData(seatDataId, bom, val);
            return "Done";
        }



        [WebMethod]
        public static string UPDATE_REWORK_TASK(int id, string status)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    var res = dbEntities.ReworkTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        res.SeatStatus = status;
                        dbEntities.SaveChanges();
                        return "Done";
                    }
                    return "Something went wrong.";
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }


        public static bool Subscribe()
        {
            byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x36, 0x30, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x00 };
            try
            {
                if (DCserver.Connected)
                {
                    if (EnableTool())
                    {
                        int sent = DCserver.Send(byteData, SocketFlags.None);
                        byte[] buffer = new byte[1024];
                        int bytesRead = DCserver.Receive(buffer);
                        string receivedData = Encoding.UTF8.GetString(buffer);
                        if (receivedData.Substring(4, 4) == "0005")
                        {

                            StartTightening = true;
                            Subscribed = true;
                            return true;
                        }
                        else
                        {
                            Subscribed = false;
                        }
                    }
                    else { Subscribed = false; return false; }
                }
                return false;
            }
            catch (Exception ex)
            {
                CurrentError = "Subs " + ex.ToString();
                return false;
            }

        }

        public static void UnSubscribe()
        {
            byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x36, 0x33, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x00 };
            try
            {
                int sent = DCserver.Send(byteData, SocketFlags.None);
                byte[] buffer = new byte[1024];
                int bytesRead = DCserver.Receive(buffer);
                string receivedData = Encoding.UTF8.GetString(buffer);
                if (receivedData.Substring(4, 4) == "0005")
                {
                    Subscribed = false;
                }
                else
                {
                    Subscribed = true;
                }
            }
            catch (Exception ex)
            {
                CurrentError = "UnSubs " + ex.ToString();
            }

        }

        public static void AcknolegeToPF()
        {
            byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x36, 0x32, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x00 };
            try
            {
                int sent = DCserver.Send(byteData, SocketFlags.None);
            }
            catch (Exception ex)
            {
                CurrentError = "Ack : " + ex.ToString();
            }

        }


        public static void DisableTool()
        {
            byte[] byteFrom = new byte[1025];
            byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x34, 0x32, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x00 };
            try
            {
                if (DCserver.Connected)
                {
                    int sent = DCserver.Send(byteData, SocketFlags.None);
                    int p = DCserver.Receive(byteFrom, SocketFlags.None);
                    IsDcToolEnable = false;
                }
            }
            catch (Exception ex)
            {
                IsDcToolEnable = true;
                CurrentError = "Dis: " + ex.ToString();
            }

        }

        [WebMethod]
        public static bool EnableTool()
        {
            byte[] byteFrom = new byte[1025];
            byte[] byteData = { 0x30, 0x30, 0x32, 0x30, 0x30, 0x30, 0x34, 0x33, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x00 };
            try
            {
                if (DCserver.Connected)
                {
                    int sent = DCserver.Send(byteData, SocketFlags.None);
                    int p = DCserver.Receive(byteFrom, SocketFlags.None);
                    string receivedData = Encoding.UTF8.GetString(byteFrom);
                    if (receivedData.Substring(4, 4) == "0005")
                    {
                        IsDcToolEnable = true;
                        return true;
                    }
                    else
                    {
                        IsDcToolEnable = false;
                    }
                }
                return false;
            }
            catch (Exception ex)
            {
                CurrentError = "Ena : " + ex.ToString();
                IsDcToolEnable = false;
                return false;
            }
        }

        public static void SelectPset(int PsetNo)
        {
            byte i = 0x00;
            if (PsetNo == 1)
            { i = 0x31; }
            else if (PsetNo == 2)
            { i = 0x32; }
            else if (PsetNo == 3)
            { i = 0x33; }
            else if (PsetNo == 4)
            { i = 0x34; }
            else if (PsetNo == 5)
            { i = 0x35; }
            else if (PsetNo == 6)
            { i = 0x35; }
            else if (PsetNo == 7)
            { i = 0x37; }
            else if (PsetNo == 8)
            { i = 0x38; }
            else if (PsetNo == 9)
            { i = 0x39; }
            byte[] byteFrom = new byte[1025];
            byte[] byteData = { 0x30, 0x30, 0x32, 0x33, 0x30, 0x30, 0x31, 0x38, 0x30, 0x30, 0x31, 0x30, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x20, 0x20, 0x30, 0x30, i, 0x00 };
            try
            {
                if (DCserver.Connected)
                {
                    int sent = DCserver.Send(byteData, SocketFlags.None);
                    int p = DCserver.Receive(byteFrom, SocketFlags.None);
                }
            }
            catch (Exception ex)
            {
                CurrentError = "pset : " + ex.ToString();
            }
        }

        [WebMethod]
        public static string TorqueExecuteTask(string torque_seq, string username, long seat_data_id, string station)
        {
            seatDataId = seat_data_id;

            bool isTGood = false;
            bool isAGood = false;
            bool isTAGood = false;
            int pset = 1;

            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var psetRes = db.TorquePsets.Where(i => i.TorqueName == torque_seq).FirstOrDefault();
                    if (psetRes != null) { pset = Convert.ToInt16(psetRes.Pset); }
                }

                // Assume a buffer size of 1024, adjust as needed
                byte[] buffer = new byte[1024];

                // Use ReceiveAsync to asynchronously receive data 
                if (IS_DCTOOL_CONNECTED())
                {
                    int bytesRead = 0;

                    SelectPset(pset);

                    while (Subscribe())
                    {
                        bytesRead = DCserver.Receive(buffer);
                        StartTightening = false;

                        if (bytesRead > 0)
                        {
                            AcknolegeToPF();
                            if (bytesRead > 230)
                            {
                                string receivedData = Encoding.UTF8.GetString(buffer, 0, bytesRead);
                                var t = "T" + receivedData.Substring(142, 2) + "." + receivedData.Substring(144, 2);
                                var a = "A" + receivedData.Substring(171, 3) + ".0";
                                var TA = t + a;

                                if (receivedData.Substring(107, 1) == "1") { isTAGood = true; }
                                if (receivedData.Substring(110, 1) == "1") { isTGood = true; }
                                if (receivedData.Substring(113, 1) == "1") { isAGood = true; }

                                //update torque value inside database 

                                if (isTAGood)
                                {
                                    //insert JITLineSeatMfgReport value
                                    InsertJITLineSeatMfgReport(station, torque_seq, TA, "OK,OK", username);
                                    DisableTool();
                                    DCserver.Close();
                                    return "Done:" + TA;
                                }
                                else
                                {
                                    //insert JITLineSeatMfgReport value
                                    if (isTGood && !isAGood)
                                    {
                                        InsertJITLineSeatMfgReport(station, torque_seq, TA, "OK,NG", username);
                                    }
                                    else if (!isTGood && isAGood)
                                    {
                                        InsertJITLineSeatMfgReport(station, torque_seq, TA, "NG,OK", username);
                                    }
                                    else
                                    {
                                        InsertJITLineSeatMfgReport(station, torque_seq, TA, "NG,NG", username);
                                    }

                                    DisableTool();
                                    DCserver.Close();
                                    return "Error:" + TA;
                                }
                            }

                        }
                        else { DisableTool(); }
                    }
                }
                DCserver.Close();
            }
            catch (Exception ex)
            {
                StartTightening = false;
                DisableTool();
                DCserver.Close();
                return ex.Message;
            }

            return "";
        }

        [WebMethod]
        public static string ToolStatus()
        {
            try
            {
                return "Conn: " + DCserver.Connected + ", Ena: " + IsDcToolEnable.ToString() + ", Sub: " + Subscribed.ToString() + ", Tigh: " + StartTightening.ToString();
            }
            catch (Exception ex) { Console.Write(ex.ToString()); return "false"; }
        }
           
        public static void UpdateSeatData(long id, string key, string value)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        switch (key)
                        {
                            case "Shift":
                                res.Shift = value; break;
                            case "Model":
                                res.Model = value; break;
                            case "Variant":
                                res.Variant = value; break;
                            case "BOM1":
                                res.SCAN_BOM1 = value;
                                res.SCAN_BOM1_DATETIME = DateTime.Now;
                                break;
                            case "BOM2":
                                res.SCAN_BOM2 = value;
                                res.SCAN_BOM2_DATETIME = DateTime.Now;
                                break;
                            case "BOM3":
                                res.SCAN_BOM3 = value;
                                res.SCAN_BOM3_DATETIME = DateTime.Now;
                                break;
                            case "BOM4":
                                res.SCAN_BOM4 = value;
                                res.SCAN_BOM4_DATETIME = DateTime.Now;
                                break;
                            case "BOM5":
                                res.SCAN_BOM5 = value;
                                res.SCAN_BOM5_DATETIME = DateTime.Now;
                                break;
                            case "BOM6":
                                res.SCAN_BOM6 = value;
                                res.SCAN_BOM6_DATETIME = DateTime.Now;
                                break;
                            case "BOM7":
                                res.SCAN_BOM7 = value;
                                res.SCAN_BOM7_DATETIME = DateTime.Now;
                                break;
                            case "BOM8":
                                res.SCAN_BOM8 = value;
                                res.SCAN_BOM8_DATETIME = DateTime.Now;
                                break;
                            case "BOM9":
                                res.SCAN_BOM9 = value;
                                res.SCAN_BOM9_DATETIME = DateTime.Now;
                                break;
                            case "BOM10":
                                res.SCAN_BOM10 = value;
                                res.SCAN_BOM10_DATETIME = DateTime.Now;
                                break;
                            case "BOM11":
                                res.SCAN_BOM11 = value;
                                res.SCAN_BOM11_DATETIME = DateTime.Now;
                                break;
                            case "BOM12":
                                res.SCAN_BOM12 = value;
                                res.SCAN_BOM12_DATETIME = DateTime.Now;
                                break;
                            case "BOM13":
                                res.SCAN_BOM13 = value;
                                res.SCAN_BOM13_DATETIME = DateTime.Now;
                                break;
                            case "BOM14":
                                res.SCAN_BOM14 = value;
                                res.SCAN_BOM14_DATETIME = DateTime.Now;
                                break;
                            case "BOM15":
                                res.SCAN_BOM15 = value;
                                res.SCAN_BOM15_DATETIME = DateTime.Now;
                                break;
                            default: break;
                        }
                        db.SaveChanges();
                    }
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
        }

        public static void InsertJITLineSeatMfgReport(string station, string parameter_desc, string value, string status, string username)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //seat data id already assigned during scan built ticket so
                    var station_desc = "";

                    var station_res = db.StationAssignments.Where(i => i.StationNameID == station).FirstOrDefault();

                    if (station_res != null) { station_desc = station_res.Station_Name; }

                    var seat_data_res = db.SEAT_DATA.Where(i => i.ID == seatDataId).FirstOrDefault();

                    if (seat_data_res != null)
                    {
                        string currentStation = seat_data_res.StationNo + "0";
                        if (station == "Station-16")
                        {
                            currentStation = "rework";
                        }
                        JITLineSeatMfgReport jITLineSeatMfgReport = new JITLineSeatMfgReport
                        {
                            Date = DateTime.Now.Date,
                            Time = DateTime.Now.TimeOfDay,
                            Shift = seat_data_res.Shift,
                            BuildLabelNumber = seat_data_res.BuildLabelBarcode,
                            StationNo = currentStation,
                            StationDescription = station_desc,
                            ParameterDescription = parameter_desc,
                            DataValues = value,
                            OverallStatus = status,
                            OperatorName = username
                        };
                        db.JITLineSeatMfgReports.Add(jITLineSeatMfgReport);
                        db.SaveChanges();
                    }

                }

            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
        }
         

    }
}