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
using System.Web.Services.Description;
using System.IO;
using System.Net.Sockets;

namespace WebApplication2.station
{
    public partial class Station13 : System.Web.UI.Page
    {
        public static int station_number = 0;
        public static int sequence_number = 0; 
        public static string CurrentError = "";
        public static string station_name = "";
        public static string station_id = "";
        public static string seat_type = "";
        public static string fg_part_number = "";

        public static int functionCallCount = 0;

        public static Plc plc;

        public static string plcReadTAg = ""; 
        public static string plcIpAddress = "";

        public static string printerIpAddress = "";
        public static int port = 0;

        private void Page_Load(object sender, EventArgs e)
        {
            PAGE_LOAD_FUNCTION();
        }

        public static void PAGE_LOAD_FUNCTION()
        {
            GET_PLCIP_ADDRESS();
            plc = new Plc(CpuType.S71500, plcIpAddress, 0, 0);
        }

        public static void GET_PRINTERIP_ADDRESS()
        {

            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //this code for printer1 ip address fetching 
                    var printerIpRes = db.VarTables.Where(i => i.VarName == "FinelPrinterIp").FirstOrDefault();
                    if (printerIpRes != null)
                    {
                        printerIpAddress = printerIpRes.VarValue.Split(':')[0];
                        port = Convert.ToInt32(printerIpRes.VarValue.Split(':')[1]);
                    }
                }
            }
            catch { }
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
                    if (plc.IsConnected == false)
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
        public static string ISPRINTERCONNECTED()
        {
            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(printerIpAddress);

                // check after the ping is n success 
                return PR.Status.ToString();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return ex.Message;
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
                            plcReadTAg = ReadTagNameInPlc(plcStation);

                            if (IS_PLC_CONNECTED())
                            {
                                //this is scan bit tag in plc 
                                WriteTagValueInPlc(plcStation, "ScanBit");

                                //this is for ods and all 
                                if (res.Model == "PY1B" && res.SeatType == "DRIVER")
                                {
                                    plc.Write("DB5.DBW1218", Convert.ToUInt16(11));
                                }
                                else if (res.Model == "PY1B" && res.SeatType == "CO-DRIVER")
                                {
                                    plc.Write("DB5.DBW1218", Convert.ToUInt16(12));
                                }
                                else if (res.Model == "BBA" && res.SeatType == "DRIVER")
                                {
                                    plc.Write("DB5.DBW1218", Convert.ToUInt16(21));
                                }
                                else if (res.Model == "BBA" && res.SeatType == "CO-DRIVER")
                                {
                                    plc.Write("DB5.DBW1218", Convert.ToUInt16(22));
                                }
                            } else { return "plcDiconnected"; }

                            return res.ID.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "0";
            }
            return "0";
        }

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
        public static string GET_WEIGHT_AND_REGISTANCE_VALUE()
        {
            try
            {
                if (IS_PLC_CONNECTED())
                {
                    decimal weight = (decimal)((UInt16)plc.Read("DB98.DBW34")) / 10;
                    decimal registance = (decimal)((UInt16)plc.Read("DB98.DBW24")) / 10;

                    string wr = weight.ToString("00.00") + "," + registance.ToString("00.00");
                    return wr;
                }
                return "Error";
            }
            catch { return "Error"; }
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

        [WebMethod]
        public static string ODSExecuteTask(int id, string model_variant, long seat_data_id, string station, string username)
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
                            decimal weight = (decimal)((UInt16)plc.Read("DB98.DBW34"))/10m;
                            decimal registance = (decimal)((UInt16)plc.Read("DB98.DBW24"))/10m;

                            string wr = weight.ToString("00.00") + "," + registance.ToString("00.00");
                            res.TaskCurrentValue = wr;

                            int result = (UInt16)plc.Read("DB98.DBW30"); 
                            if (result == 1)
                            {
                                UpdateSeatData(seat_data_id, "ODS", wr);
                                InsertJITLineSeatMfgReport(seat_data_id, station, "ODS", wr, "OK", username);

                                res.TaskStatus = "Done";

                                //update next row status to running
                                if(IsRunningTask(res.StationNameID, model_variant)){
                                    var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                                    if (nextRow != null) { nextRow.TaskStatus = "Running"; } 
                                }

                            } 
                            else if (result == 2)
                            {

                                var seatRes = dbEntities.SEAT_DATA.Where(s => s.ID == seat_data_id).OrderByDescending(o => o.ID).FirstOrDefault();
                                if (seatRes != null)
                                {
                                    ADD_REWORK_DATA(seatRes.BuildLabelBarcode, "ODS", username, seat_data_id.ToString());
                                }
                                //InsertJITLineSeatMfgReport(seat_data_id, station, "ODS", wr, "NG", username);
                                //RejectTask(seat_data_id, res.StationNameID);
                                //return "REJECTED";
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
        public static string BeltBuckleExecuteTask(int id, string model_variant, long seat_data_id, string seat, string station, string username)
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
                            decimal registance = (decimal)((UInt16)plc.Read("DB98.DBW24")) / 10m;

                            res.TaskCurrentValue = registance.ToString();

                            int result = (UInt16)plc.Read("DB98.DBW32");
                            if (result == 1)
                            {

                                InsertJITLineSeatMfgReport(seat_data_id, station, "BELT BUCKLE", registance.ToString(), "OK", username);
                                UpdateSeatData(seat_data_id, "BELT_BUCKLE", registance.ToString());

                                if (seat == "DRIVER")
                                {
                                    UpdateSeatData(seat_data_id, "ODS", "NA"); 
                                }



                                res.TaskStatus = "Done";
                                //update next row status to running
                                if (IsRunningTask(res.StationNameID, model_variant))
                                {
                                    var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                                    if (nextRow != null) { nextRow.TaskStatus = "Running"; }
                                }

                            } else if (result == 2)
                            {
                                var seatRes = dbEntities.SEAT_DATA.Where(s => s.ID == seat_data_id).OrderByDescending(o => o.ID).FirstOrDefault();
                                if (seatRes != null)
                                {
                                    ADD_REWORK_DATA(seatRes.BuildLabelBarcode, "BELT_BUCKLE", username, seat_data_id.ToString());
                                }
                                //InsertJITLineSeatMfgReport(seat_data_id, station, "BELT BUCKLE", registance.ToString(), "NG", username);
                                //RejectTask(seat_data_id, res.StationNameID);
                                //return "REJECTED";
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
        public static string SABExecuteTask(int id, string model_variant, long seat_data_id, string station, string username)
        {
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {

                    var res = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {

                        InsertJITLineSeatMfgReport(seat_data_id, station, "SAB", "value", "OK", username); 
                        UpdateSeatData(seat_data_id, "SAB", "value");

                        res.TaskCurrentValue = "OK";
                        res.TaskStatus = "Done";
                        dbEntities.SaveChanges();

                        //update next row status to running
                        if (IsRunningTask(res.StationNameID, model_variant))
                        {
                            var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                            if (nextRow != null) { nextRow.TaskStatus = "Running"; }
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
         
        public static bool qrEntry = true;

        [WebMethod]
        public static string QRCODE_PRINT(int id, string val, string model_variant, long seat_data_id, string feature)
        {
            var seq = val.Split('-')[2];
            int andonRowId = GetCurrentShiftRowId();

            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                { 

                    var res = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        var seatDataRes = dbEntities.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                        if (seatDataRes != null)
                        {
                            string status = "";

                            var rewordRes = dbEntities.ReworkTables.Where(i => i.SeatID == seat_data_id.ToString() && i.SeatStatus == "NG").ToList();
                            if (rewordRes != null)
                            {
                                status = "HOLD";
                            }


                            if (PrintFinelQrCode(val, seatDataRes.Model, seatDataRes.Variant, seatDataRes.SeatType, seatDataRes.FG_PartNumber, feature, status) == "Done")
                            {
                                seatDataRes.FinalBarcodeData = val + DateTime.Now.ToString("MMddyyyyHHmm");
                                seatDataRes.FinalPrintDateTime = DateTime.Now;
                                seatDataRes.STAUS = status == "" ? "OK" : "HOLD";
                                res.TaskCurrentValue = val + DateTime.Now.ToString("MMddyyyyHHmm");
                                res.TaskStatus = "Done";
                                 
                                var andonRes = dbEntities.Andons.Where(i => i.ID == andonRowId).FirstOrDefault();
                                if (andonRes != null)
                                {
                                    andonRes.Production++;
                                }

                                string q = "update JITLineSeatMfgReport set SeatSerialNumber = '"+ val + DateTime.Now.ToString("MMddyyyyHHmm") + "' where BuildLabelNumber = '"+ val + "' ";
                                dbEntities.Database.ExecuteSqlCommand(q);  
                                dbEntities.SaveChanges();

                                //update next row status to running   
                                if (IsRunningTask(res.StationNameID, model_variant))
                                {
                                    var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();

                                    if (nextRow != null)
                                    {
                                        nextRow.TaskStatus = "Running";
                                        dbEntities.SaveChanges();
                                        return "Done";
                                    }
                                }
                            }
                            else
                            {
                                res.TaskCurrentValue = val + DateTime.Now.ToString("MMddyyyyHHmm");
                                res.TaskStatus = "Error";
                                dbEntities.SaveChanges();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
            return "Error";
        }


        [WebMethod]
        public static string PrintFinelQrCode(string val, string model, string variant, string seat, string fgpart, string feature, string status)
        {
            // ZPL command 
            string ZPLString = "\u0010CT~~CD,~CC^~CT~\r\n^XA\r\n~TA000\r\n~JSN\r\n^LT0\r\n^MNW\r\n^MTT\r\n^PON\r\n^PMN\r\n^LH0,0\r\n^JMA\r\n^PR6,6\r\n~SD15\r\n^JUS\r\n^LRN\r\n^CI27\r\n^PA0,1,1,0\r\n^XZ\r\n^XA\r\n^MMT\r\n^PW1181\r\n^LL295\r\n^LS0\r\n^FT316,67^A0N,40,48^FH\\^CI28^FD"+model+"^FS^CI27\r\n^FT598,69^A0N,42,43^FH\\^CI28^FD"+ DateTime.Now.ToString("dd-MM-yyyy HH:mm") + "^FS^CI27\r\n^FT321,133^A0N,42,43^FH\\^CI28^FD" + variant + "^FS^CI27\r\n^FT316,251^A0N,40,41^FH\\^CI28^FD" + val + DateTime.Now.ToString("ddMMyyyyHHmm") + "^FS^CI27\r\n^FT772,133^A0N,42,43^FH\\^CI28^FD" + seat + "^FS^CI27\r\n^FT591,128^A0N,42,43^FH\\^CI28^FD" + feature + "^FS^CI27\r\n^FT321,193^A0N,42,43^FH\\^CI28^FD"+ fgpart + "      " + status +"^FS^CI27\r\n^FT53,267^BQN,2,9\r\n^FH\\^FDLA," + val + DateTime.Now.ToString("ddMMyyyyHHmm") + status + "^FS\r\n^PQ1,0,1,Y\r\n^XZ\r\n";

            // check after the ping is n success
            while (ISPRINTERCONNECTED() == "Success")
            {

                // Open connection
                TcpClient client = new TcpClient();
                client.Connect(printerIpAddress, port);

                // Write ZPL String to connection
                StreamWriter writer = new StreamWriter(client.GetStream());
                writer.Write(ZPLString);
                writer.Flush();

                // Close Connection
                writer.Close();
                client.Close();
                return "Done";
            }

            return "Error";

        }


        [WebMethod]
        public static int GetCurrentShiftRowId()
        {
            try
            {
                int ID = 0;
                using (TMdbEntities db = new TMdbEntities())
                {
                    var andonRes = db.Andons.ToList();
                    foreach (var item in andonRes)
                    {
                        DateTime start = Convert.ToDateTime(item.HourName.Split('-')[0]);
                        DateTime end = Convert.ToDateTime(item.HourName.Split('-')[1]);

                        if (start < end)
                        {
                            if (DateTime.Now >= start && DateTime.Now <= end)
                            {
                                ID = item.ID;
                                break;
                            }
                        }
                        else { ID = 18; }
                    }
                    return ID;
                }
            }
            catch
            {
                return 0;
            } 
        }


        [WebMethod]
        public static string WriteBitExecuteTask(int id, string model_variant, string plcStation)
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
                            WriteTagValueInPlc(plcStation, "WriteBit");
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

        public static void ADD_REWORK_DATA(string built_ticket, string ins, string user, string seatId)
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {

                    ReworkTable reworkTable = new ReworkTable
                    {
                        BuildLabelNumber = built_ticket,
                        InspectionName = ins,
                        InspectionType = ins,
                        StationNameID = "rework",
                        OperatorName = user,
                        InspectionDateTime = DateTime.Now,
                        SeatID = seatId,
                        SeatStatus = "NG",
                        ReworkDatetime = DateTime.Now
                    };

                    db.ReworkTables.Add(reworkTable);
                    db.SaveChanges();

                }
            } catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
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


        [WebMethod]
        public static bool FinishTask(string station, int seat_data_id)
        { 
            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {
                    var seatDataRes = dbEntities.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                    if (seatDataRes != null)
                    {
                        seatDataRes.StationNo = int.Parse(station.Split('-')[1]) + 1;
                    }
                    var res = dbEntities.TaskListTables.Where(i => i.StationNameID == station).ToList();
                    if (res != null)
                    {
                        res[0].TaskStatus = "Running";
                        res[1].TaskStatus = "Pending";
                        res[2].TaskStatus = "Pending";
                        res[3].TaskStatus = "Pending";
                        res[4].TaskStatus = "Pending";
                        res[5].TaskStatus = "Pending";
                        res[6].TaskStatus = "Pending";
                        res[7].TaskStatus = "Pending";
                        res[8].TaskStatus = "Pending";
                        res[9].TaskStatus = "Pending";

                        res[0].TaskCurrentValue = "";
                        res[1].TaskCurrentValue = "";
                        res[2].TaskCurrentValue = "";
                        res[3].TaskCurrentValue = "";
                        res[4].TaskCurrentValue = "";
                        res[5].TaskCurrentValue = "";
                        res[6].TaskCurrentValue = "";
                        res[7].TaskCurrentValue = "";
                        res[8].TaskCurrentValue = "";
                        res[9].TaskCurrentValue = "";

                        dbEntities.SaveChanges();

                    }
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
        public static bool RejectTask(long seat_data_id, string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                    res.STAUS = "REJECT";

                    var taskListRes = db.TaskListTables.Where(i => i.StationNameID == station).ToList();
                    if (taskListRes != null)
                    {
                        taskListRes[0].TaskStatus = "Running";
                        taskListRes[1].TaskStatus = "Pending";
                        taskListRes[2].TaskStatus = "Pending";
                        taskListRes[3].TaskStatus = "Pending";
                        taskListRes[4].TaskStatus = "Pending";
                        taskListRes[5].TaskStatus = "Pending";
                        taskListRes[6].TaskStatus = "Pending";
                        taskListRes[7].TaskStatus = "Pending";
                        taskListRes[8].TaskStatus = "Pending";
                        taskListRes[9].TaskStatus = "Pending";

                        taskListRes[0].TaskCurrentValue = "";
                        taskListRes[1].TaskCurrentValue = "";
                        taskListRes[2].TaskCurrentValue = "";
                        taskListRes[3].TaskCurrentValue = "";
                        taskListRes[4].TaskCurrentValue = "";
                        taskListRes[5].TaskCurrentValue = "";
                        taskListRes[6].TaskCurrentValue = "";
                        taskListRes[7].TaskCurrentValue = "";
                        taskListRes[8].TaskCurrentValue = "";
                        taskListRes[9].TaskCurrentValue = "";

                        db.SaveChanges();

                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                CurrentError = ex.Message;
                return false;
            }
            return false;
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