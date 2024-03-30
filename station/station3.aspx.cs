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
using System.Diagnostics;
using System.Net.Sockets;
using System.Net;
using System.Drawing;
using System.Text;
using System.Threading;
using System.IO;

namespace WebApplication2.station
{
    public partial class Station3 : Page
    {
        public static int station_number = 0;
        public static int sequence_number = 0;
        public static string CurrentError = "";
        public static string station_name = "";
        public static string station_id = "";
        public static string seat_type = "";
        public static string fg_part_number = "";

        public static int functionCallCount = 0;
        public static string plcIpAddress = "";
        public static string plcReadTAg = "";
        public static string CurrentStation = null;
        public string pwd = "";

        public static string CurrentDcToolIp = "";
        private static bool Subscribed = false;
        private static bool IsDcToolEnable = false;

        private static Plc plc;
        public static Socket DCserver;
        public static bool StartTightening = false;

        private void Page_Load(object sender, EventArgs e)
        {
            PAGE_LOAD_FUNCTION();
        }

        public static void PAGE_LOAD_FUNCTION()
        {
            GET_PLCIP_ADDRESS();
            plc = new Plc(CpuType.S71500, plcIpAddress, 0, 0);
            DCserver = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        }

        public static void GET_PLCIP_ADDRESS()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //this code for plc ip address fetching 
                    var plcIpRes = db.VarTables.Where(i => i.VarName == "PlcIp").FirstOrDefault();
                    {
                        if (plcIpRes != null)
                            plcIpAddress = plcIpRes.VarValue;
                    }
                }
            }
            catch { }
        }

        public static bool IS_DCTOOL_CONNECTED()
        {
            try
            {
                if (DCserver.Connected == false)
                {
                    DCserver = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    DCserver.Connect(IPAddress.Parse(CurrentDcToolIp), 4545);

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
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }

        [WebMethod]
        public static bool IS_PLC_CONNECTED()
        {

            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(plcIpAddress);

                // check after the ping is n success
                if (PR.Status.ToString() != "Success")
                {
                    return false;
                }
                else
                {
                    if (!plc.IsConnected)
                    {
                        if (plc.Open() == ErrorCode.NoError)
                        {
                            return true;
                        }
                        else
                        {
                            return false;
                        }
                    }
                    else
                    {
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
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
                        CurrentDcToolIp = torqueIpRes.TorqueToolIPAddress;
                        if (IS_DCTOOL_CONNECTED())
                        {
                            DisableTool();
                        }
                        return torqueIpRes.TorqueToolIPAddress;
                    }
                }
            }
            catch
            {
                return "Error";
            }
            return "Error";
        }

        [WebMethod]
        public static bool PING_DCTOOL(string ip)
        {
            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(ip);

                // check after the ping is n success
                if (PR.Status.ToString() == "Success")
                {
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
            return false;
        }

        [WebMethod]
        public static string GetStationInfo(string station)
        {
            CurrentStation = station;
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
        public static int GET_JOB_COUNT(int station)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.SEAT_DATA.Where(i => i.StationNo > station && i.BuildNoDatetime > DateTime.Today).ToList();
                    if (res.Count > 0)
                    {
                        return res.Count;
                    }
                }
            }
            catch
            {
                return 0;
            }
            return 0;
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
        public static string GetAllPlcTagList()
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var user = mdbEntities.PLCAddressLists.ToList();
                    if (user != null)
                    {
                        return JsonSerializer.Serialize(user);
                    }
                }
            }
            catch
            {
                return "Error";
            }
            return "Error";
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
            catch
            {
                return "USER_NULL";
            }
        }

        [WebMethod]
        public static string GetModelAndTaskList(string fgpart, string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var md = db.MODEL_DEATILS.Where(i => i.FG_PartNumber == fgpart).FirstOrDefault();
                    if (md != null)
                    {
                        var model = db.MODELs.Where(i => i.ModelName == md.Model).FirstOrDefault();

                        var resTaskList = db.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + station + "' and " + md.ModelVariant + "= '1'").ToList();
                        var bomRes = db.BOMs.Where(i => i.FG_PartNumber == fgpart).ToList();

                        var taskList = JsonSerializer.Serialize(resTaskList);
                        var bomList = JsonSerializer.Serialize(bomRes);

                        var res = new Dictionary<string, string>
                                    {
                                        {"model",JsonSerializer.Serialize(md) },
                                        {"customer",model.CustomerName },
                                        {"taskList",taskList },
                                        {"bomList",bomList },
                                    };
                        return JsonSerializer.Serialize(res);
                    }
                    else { return null; }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message.ToString());
                return ex.Message;
            }
        }

        [WebMethod]
        public static string IsQRValid(string build_ticket, int station, string plcStation)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    var res = dbEntities.SEAT_DATA.Where(i => i.BuildLabelBarcode == build_ticket).OrderByDescending(o => o.ID).FirstOrDefault();
                    if (res != null)
                    {
                        if (res.STAUS == "REJECT")
                        {
                            return "Rejected";
                        }
                        if (res.StationNo == station)
                        {
                            if (IS_PLC_CONNECTED())
                            {
                                plcReadTAg = ReadTagNameInPlc(plcStation);
                                WriteTagValueInPlc(plcStation, "ScanBit");
                                return res.ID.ToString();
                            }
                            else
                            {
                                return "plcDiconnected";
                            }

                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message.ToString());
                return "0";
            }
            return "0";
        }

        public static bool builtTicketEntry = true;

        [WebMethod]
        public static string BuildTicketExecuteTask(int id, string val, long seat_data_id, string model_variant)
        {

            try
            {

                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    //update seat data from varmodel 
                    var varTableRes = dbEntities.VarTables.Where(i => i.VarName == "Shift").FirstOrDefault();
                    if (varTableRes != null)
                    {
                        UpdateSeatData(seat_data_id, "Shift", varTableRes.VarValue);
                    }

                    bool Update = false;
                    var res = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        res.TaskCurrentValue = val;
                        res.TaskStatus = "Done";
                        Update = true;
                    }

                    dbEntities.SaveChanges();

                    //update next row status to running  
                    if (Update == true)
                    {
                        if (IsRunningTask(res.StationNameID, model_variant))
                        {
                            var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                            if (nextRow != null)
                            {
                                nextRow.TaskStatus = "Running";
                            }
                            Update = false;
                            dbEntities.SaveChanges();
                            return "Done";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }

            return string.Empty;
        }

        [WebMethod]
        public static string ScanExecuteTask(int id, string fgpart, string bom, string val, string model_variant, long seat_data_id)
        {
            try
            {

                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    //update seat data table 
                    var BomFromTask = dbEntities.TaskListTables.Where(i => i.StationNameID == CurrentStation && (i.TaskStatus == "Running" || i.TaskStatus == "Error")).FirstOrDefault();
                    if (BomFromTask != null)
                    { bom = BomFromTask.BomSeq; }
                    var bom_res = dbEntities.BOMs.Where(i => i.FG_PartNumber == fgpart && i.ScanSequence == bom && val.Contains(i.PartNumber)).FirstOrDefault();
                    if (bom_res != null)
                    {
                        if ((bool)bom_res.IsDuplicate)
                        {
                            var res1 = dbEntities.SEAT_DATA.SqlQuery("select * from SEAT_DATA where SCAN_" + bom + " = '" + val + "'");
                            if (res1 != null)
                            { return "Already"; }
                        }

                        var res = dbEntities.TaskListTables.Where(i => i.StationNameID == CurrentStation && (i.TaskStatus == "Running" || i.TaskStatus == "Error")).FirstOrDefault();
                        if (res != null)
                        {
                            res.TaskCurrentValue = val;
                            res.TaskStatus = "Done";
                            dbEntities.SaveChanges();
                            UpdateSeatData(seat_data_id, bom, val);

                            var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                            if (nextRow != null)
                            {
                                nextRow.TaskStatus = "Running";
                            }
                            dbEntities.SaveChanges();
                        }
                        id = 0; bom = ""; val = "";
                        return "Done";
                    }
                    else
                    {
                        var res = dbEntities.TaskListTables.Where(i => i.StationNameID == CurrentStation && (i.TaskStatus == "Running" || i.TaskStatus == "Error")).FirstOrDefault();
                        if (res != null)
                        {
                            res.TaskCurrentValue = val;
                            res.TaskStatus = "Error";
                            dbEntities.SaveChanges();

                        }
                    }
                }
                id = 0; bom = ""; val = "";
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
            return string.Empty;
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

        [WebMethod]
        public static string ToolStatus()
        {
            try
            {
                return "Conn: " + DCserver.Connected.ToString() + ", Ena: " + IsDcToolEnable.ToString() + ", Sub: " + Subscribed.ToString() + ", Tigh: " + StartTightening.ToString();
            }
            catch (Exception ex) { Console.Write(ex.ToString()); return "false"; }
        }

        public static int PrevID = 0;

        public static bool UpdateStatus(string status, string Val, int ID)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var taskRes = db.TaskListTables.Where(i => i.ID == ID).FirstOrDefault();
                    if (taskRes != null)
                    {
                        taskRes.TaskCurrentValue = Val;
                        taskRes.TaskStatus = status;
                        db.SaveChanges();
                        if (status == "Done")
                        {
                            PrevID = ID;
                        }
                        return true;
                    }
                    else { return false; }
                }
            }
            catch { return false; }
        }

        public static bool IsRunningTask(string station, string ModelVar)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var nextRow1 = db.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + station + "' and " + ModelVar + " = '1' and (TaskStatus = 'Running' or TaskStatus = 'Error')").FirstOrDefault();
                    if (nextRow1 == null)
                    { return true; }
                    else { return false; }
                }
            }
            catch { return false; }
        }

        public static bool UpdateNextTask(string station, string ModelVar)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var nextRow = db.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + station + "' and " + ModelVar + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                    if (nextRow != null)
                    {
                        nextRow.TaskStatus = "Running";
                        db.SaveChanges();
                        return true;
                    }
                    else { return false; }
                }
            }
            catch { return false; }
        }

        [WebMethod]
        public static string TorqueExecuteTask(int id, string torque_seq, string model_variant, string username, long seat_data_id, string station, string plcStation)
        {
            bool isTGood = false;
            bool isAGood = false;
            bool isTAGood = false;
            int pset = 1;

            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var psetRes = db.STD_TorqueTable.Where(i => i.Station == station && i.TorqueName == torque_seq).FirstOrDefault();
                    if (psetRes != null) { pset = Convert.ToInt16(psetRes.Pset); }
                }

                // Assume a buffer size of 1024, adjust as needed
                byte[] buffer = new byte[1024];

                // Use ReceiveAsync to asynchronously receive data 
                if (IS_DCTOOL_CONNECTED())
                {

                    int bytesRead = 0;

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
                                var TA = t + "-" + a;

                                if (receivedData.Substring(107, 1) == "1") { isTAGood = true; }
                                if (receivedData.Substring(110, 1) == "1") { isTGood = true; }
                                if (receivedData.Substring(113, 1) == "1") { isAGood = true; }

                                //update torque value inside database 

                                if (isTAGood)
                                {
                                    if (id == PrevID)
                                    { id += 1; }

                                    if (UpdateStatus("Done", TA, id))
                                    {
                                        if (IsRunningTask(station, model_variant))
                                        {
                                            //update next row status to running
                                            if (UpdateNextTask(station, model_variant))
                                            {
                                                //insert JITLineSeatMfgReport value
                                                InsertJITLineSeatMfgReport(seat_data_id, plcStation, torque_seq, TA, "OK,OK", username);
                                                DisableTool();
                                                DCserver.Close();
                                                return "Done";
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if (id == PrevID)
                                    { id += 1; }

                                    UpdateStatus("Error", TA, id);

                                    //insert JITLineSeatMfgReport value
                                    if (isTGood && !isAGood)
                                    {
                                        InsertJITLineSeatMfgReport(seat_data_id, station, torque_seq, TA, "OK,NG", username);
                                    }
                                    else if (!isTGood && isAGood)
                                    {
                                        InsertJITLineSeatMfgReport(seat_data_id, station, torque_seq, TA, "NG,OK", username);
                                    }
                                    else
                                    {
                                        InsertJITLineSeatMfgReport(seat_data_id, station, torque_seq, TA, "NG,NG", username);
                                    }
                                    DisableTool();
                                    DCserver.Close();
                                    return "Error";
                                }
                            }

                        }
                    }
                }
                DisableTool();
                DCserver.Close();
            }
            catch (Exception ex)
            {
                StartTightening = false;
                DCserver.Close();
                return ex.Message;
            }
            return "";
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

        [WebMethod]
        public static string WriteBitExecuteTask(int id, string model_variant, string plc_station)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {

                    var res = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        if (IS_PLC_CONNECTED())
                        {
                            WriteTagValueInPlc(plc_station, "WriteBit");
                            res.TaskCurrentValue = "1";
                            res.TaskStatus = "Done";

                            //update next row status to running
                            var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                            if (nextRow != null)
                            {
                                nextRow.TaskStatus = "Running";

                            }
                            dbEntities.SaveChanges();


                        }
                    }
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
            return string.Empty;
        }

        [WebMethod]
        public static string ReadBitExecuteTask(int id, string plcStation)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    if (IS_PLC_CONNECTED())
                    {

                        var taskRes = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                        if (taskRes != null)
                        {
                            if ((bool)plc.Read(plcReadTAg))
                            {
                                WriteTagValueInPlc(plcStation, "WriteBit", false);
                                WriteTagValueInPlc(plcStation, "ScanBit", false);
                                taskRes.TaskCurrentValue = "1";
                                taskRes.TaskStatus = "Done";
                                dbEntities.SaveChanges();
                            }
                        }

                    }
                    return "Done";
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static bool FinishTask(string station, long seat_data_id)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    var seatDataRes = dbEntities.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                    if (seatDataRes != null)
                    {
                        seatDataRes.StationNo = Convert.ToInt32(station.Split('-')[1]) + 1;
                    }
                    dbEntities.SaveChanges();
                    ResetTaskStatusAndValue(station);
                    return true;
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
            return false;
        }

        [WebMethod]
        public static bool RejectTask(int seat_data_id, string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                    res.STAUS = "REJECT";

                    db.SaveChanges();
                    ResetTaskStatusAndValue(station);
                    return true;
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
                return false;
            }
        }

        public static void ResetTaskStatusAndValue(string station)
        {
            using (TMdbEntities db = new TMdbEntities())
            {
                db.Database.ExecuteSqlCommand($"update TaskListTable set TaskCurrentValue = '', TaskStatus = 'Pending' where StationNameID = '{station}'");
                db.SaveChanges();
                db.Database.ExecuteSqlCommand($"update TaskListTable set TaskStatus = 'Running' where ImageSeq = 1 and StationNameID = '{station}'");
                db.SaveChanges();
            }
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
                Console.Write(ex.ToString());
            }
        }

        public static void InsertJITLineSeatMfgReport(long seat_data_id, string station, string parameter_desc, string value, string status, string username)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //seat data id already assigned during scan built ticket so
                    var station_desc = "";

                    var station_res = db.StationAssignments.Where(i => i.StationNameID == station).FirstOrDefault();

                    if (station_res != null) { station_desc = station_res.Station_Name; }

                    var seat_data_res = db.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();

                    if (seat_data_res != null)
                    {
                        JITLineSeatMfgReport jITLineSeatMfgReport = new JITLineSeatMfgReport
                        {
                            Date = DateTime.Now.Date,
                            Time = DateTime.Now.TimeOfDay,
                            Shift = seat_data_res.Shift,
                            BuildLabelNumber = seat_data_res.BuildLabelBarcode,
                            StationNo = seat_data_res.StationNo + "0",
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

        public static void WriteTagValueInPlc(string station, string tag, bool val = true)
        {

            using (TMdbEntities db = new TMdbEntities())
            {
                //code for plc write bit enable
                var plcRes = db.PLCAddressLists.SqlQuery("Select * from PLCAddressList where PLCTagName = '" + tag + "'").FirstOrDefault();
                DataTable dt = new DataTable();

                if (plcRes != null)
                {
                    switch (station)
                    {
                        case "Station1": plc.Write(plcRes.Station1.ToString(), val); break;
                        case "Station2": plc.Write(plcRes.Station2.ToString(), val); break;
                        case "Station3": plc.Write(plcRes.Station3.ToString(), val); break;
                        case "Station4": plc.Write(plcRes.Station4.ToString(), val); break;
                        case "Station5": plc.Write(plcRes.Station5.ToString(), val); break;
                        case "Station6": plc.Write(plcRes.Station6.ToString(), val); break;
                        case "Station7": plc.Write(plcRes.Station7.ToString(), val); break;
                        case "Station8": plc.Write(plcRes.Station8.ToString(), val); break;
                        case "Station9": plc.Write(plcRes.Station9.ToString(), val); break;
                        case "Station10": plc.Write(plcRes.Station10.ToString(), val); break;
                        case "Station11": plc.Write(plcRes.Station11.ToString(), val); break;
                        case "Station12": plc.Write(plcRes.Station12.ToString(), val); break;
                        case "Station13": plc.Write(plcRes.Station13.ToString(), val); break;
                        case "Station14": plc.Write(plcRes.Station14.ToString(), val); break;
                        case "Station15": plc.Write(plcRes.Station15.ToString(), val); break;
                        case "Station16": plc.Write(plcRes.Station16.ToString(), val); break;
                        case "Station17": plc.Write(plcRes.Station17.ToString(), val); break;
                        case "Station18": plc.Write(plcRes.Station18.ToString(), val); break;
                        case "Station19": plc.Write(plcRes.Station19.ToString(), val); break;
                        case "Station20": plc.Write(plcRes.Station20.ToString(), val); break;
                        case "Station21": plc.Write(plcRes.Station21.ToString(), val); break;
                        case "Station22": plc.Write(plcRes.Station22.ToString(), val); break;
                        case "Station23": plc.Write(plcRes.Station23.ToString(), val); break;
                        case "Station24": plc.Write(plcRes.Station24.ToString(), val); break;
                        case "Station25": plc.Write(plcRes.Station25.ToString(), val); break;
                        default: break;
                    }
                }
            }

        }

        public static string ReadTagNameInPlc(string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //code for plc write bit enable
                    var plcRes = db.PLCAddressLists.SqlQuery("Select * from PLCAddressList where PLCTagName = 'ReadBit'").FirstOrDefault();
                    if (plcRes != null)
                    {
                        switch (station)
                        {
                            case "Station1": return plcRes.Station1.ToString();
                            case "Station2": return plcRes.Station2.ToString();
                            case "Station3": return plcRes.Station3.ToString();
                            case "Station4": return plcRes.Station4.ToString();
                            case "Station5": return plcRes.Station5.ToString();
                            case "Station6": return plcRes.Station6.ToString();
                            case "Station7": return plcRes.Station7.ToString();
                            case "Station8": return plcRes.Station8.ToString();
                            case "Station9": return plcRes.Station9.ToString();
                            case "Station10": return plcRes.Station10.ToString();
                            case "Station11": return plcRes.Station11.ToString();
                            case "Station12": return plcRes.Station12.ToString();
                            case "Station13": return plcRes.Station13.ToString();
                            case "Station14": return plcRes.Station14.ToString();
                            case "Station15": return plcRes.Station15.ToString();
                            case "Station16": return plcRes.Station16.ToString();
                            case "Station17": return plcRes.Station17.ToString();
                            case "Station18": return plcRes.Station18.ToString();
                            case "Station19": return plcRes.Station19.ToString();
                            case "Station20": return plcRes.Station20.ToString();
                            case "Station21": return plcRes.Station21.ToString();
                            case "Station22": return plcRes.Station22.ToString();
                            case "Station23": return plcRes.Station23.ToString();
                            case "Station24": return plcRes.Station24.ToString();
                            case "Station25": return plcRes.Station25.ToString();
                            default: return "";
                        }
                    }
                    return "";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            return "";
        }

    }
}