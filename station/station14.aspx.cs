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
    public partial class Station14 : Page
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
          
        private static Plc plc; 

        // Printer IP Address and communication port
        public static string printerIpAddress = "";
        public static int port = 0;

        private void Page_Load(object sender, EventArgs e)
        {
            PAGE_LOAD_FUNCTION();
            build_ticket.Focus();
        }

        [WebMethod]
        public static void PAGE_LOAD_FUNCTION()
        {
            GET_PLCIP_ADDRESS();
            GET_PRINTERIP_ADDRESS();
            plc = new Plc(CpuType.S71500, plcIpAddress, 0, 0); 
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
                            StationNameID = Convert.ToInt32(Station),
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
        public static string UserLogout(string Userid, int Station)
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
                            plcReadTAg = ReadTagNameInPlc(plcStation);
                            return res.ID.ToString();

                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
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
                        dbEntities.SaveChanges();
                    }

                    //update next row status to running  
                    if (Update == true)
                    {
                        if (IsRunningTask(res.StationNameID, model_variant) == true)
                        {
                            var nextRow = dbEntities.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + res.StationNameID + "' and " + model_variant + " = '1' and TaskStatus = 'Pending' ").FirstOrDefault();
                            if (nextRow != null)
                            {
                                nextRow.TaskStatus = "Running";
                            }
                            dbEntities.SaveChanges();
                            Update = false;
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


        public static bool qrEntry = true;

        [WebMethod]
        public static string QRCODE_PRINT(int id, string val, string model_variant, long seat_data_id)
        {
            var seq = val.Split('-')[2];
            int andonRowId = 0;

            try
            {
                using (TMdbEntities dbEntities = new TMdbEntities())
                {

                    var varTableRes = dbEntities.VarTables.Where(i => i.VarName == "CurrentShiftRowId").FirstOrDefault();
                    if (varTableRes != null)
                    {
                        andonRowId = int.Parse(varTableRes.VarValue);
                    }

                    var res = dbEntities.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        var seatDataRes = dbEntities.SEAT_DATA.Where(i => i.ID == seat_data_id).FirstOrDefault();
                        if (seatDataRes != null)
                        {
                            if (PrintFinelQrCode(seq, seatDataRes.Model, seatDataRes.Variant, seatDataRes.SeatType, seatDataRes.FG_PartNumber) == "Done")
                            {
                                seatDataRes.FinalBarcodeData = val + DateTime.Now.ToString("MMddyyyyHHmm");
                                seatDataRes.FinalPrintDateTime = DateTime.Now;
                                seatDataRes.STAUS = "OK";
                                res.TaskCurrentValue = val + DateTime.Now.ToString("MMddyyyyHHmm");
                                res.TaskStatus = "Done";

                                var andonRes = dbEntities.Andons.Where(i => i.ID == andonRowId).FirstOrDefault();
                                if (andonRes != null)
                                {
                                    andonRes.Production++;
                                }

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
        public static string PrintFinelQrCode(string seq, string model, string variant, string seat, string fgpart)
        {
            // ZPL command 
            string ZPLString = "\u0010CT~~CD,~CC^~CT~\r\n^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ\r\n^XA\r\n^MMT\r\n^PW531\r\n^LL0177\r\n^LS0\r\n^FT215,39^A0N,25,24^FH\\^FD" + fgpart + "-" + seq + "^FS\r\n^FT31,182^BQN,2,7\r\n^FH\\^FDLA," + fgpart + "-" + seq + "^FS\r\n^FT215,87^A0N,25,24^FH\\^FD" + variant + "^FS\r\n^FT407,88^A0N,25,24^FH\\^FD" + seat + "^FS\r\n^FT243,136^A0N,25,24^FH\\^FD" + model + "^FS\r\n^FT365,135^A0N,31,21^FH\\^FD" + DateTime.Now.ToShortDateString() + "^FS\r\n^PQ1,0,1,Y^XZ";

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
                    var nextRow1 = db.TaskListTables.SqlQuery("Select * from TaskListTable where StationNameID = '" + station + "' and " + ModelVar + " = '1' and TaskStatus = 'Running' or TaskStatus = 'Error'").FirstOrDefault();
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
                            WriteTagValueInPlc(plc_station);
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
        public static string ReadBitExecuteTask(int id)
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
         
        public static void WriteTagValueInPlc(string station)
        {

            using (TMdbEntities db = new TMdbEntities())
            {
                //code for plc write bit enable
                var plcRes = db.PLCAddressLists.SqlQuery("Select * from PLCAddressList where PLCTagName = 'WriteBit'").FirstOrDefault();
                DataTable dt = new DataTable();

                if (plcRes != null)
                {
                    switch (station)
                    {
                        case "Station1": plc.Write(plcRes.Station1.ToString(), true); break;
                        case "Station2": plc.Write(plcRes.Station2.ToString(), true); break;
                        case "Station3": plc.Write(plcRes.Station3.ToString(), true); break;
                        case "Station4": plc.Write(plcRes.Station4.ToString(), true); break;
                        case "Station5": plc.Write(plcRes.Station5.ToString(), true); break;
                        case "Station6": plc.Write(plcRes.Station6.ToString(), true); break;
                        case "Station7": plc.Write(plcRes.Station7.ToString(), true); break;
                        case "Station8": plc.Write(plcRes.Station8.ToString(), true); break;
                        case "Station9": plc.Write(plcRes.Station9.ToString(), true); break;
                        case "Station10": plc.Write(plcRes.Station10.ToString(), true); break;
                        case "Station11": plc.Write(plcRes.Station11.ToString(), true); break;
                        case "Station12": plc.Write(plcRes.Station12.ToString(), true); break;
                        case "Station13": plc.Write(plcRes.Station13.ToString(), true); break;
                        case "Station14": plc.Write(plcRes.Station14.ToString(), true); break;
                        case "Station15": plc.Write(plcRes.Station15.ToString(), true); break;
                        case "Station16": plc.Write(plcRes.Station16.ToString(), true); break;
                        case "Station17": plc.Write(plcRes.Station17.ToString(), true); break;
                        case "Station18": plc.Write(plcRes.Station18.ToString(), true); break;
                        case "Station19": plc.Write(plcRes.Station19.ToString(), true); break;
                        case "Station20": plc.Write(plcRes.Station20.ToString(), true); break;
                        case "Station21": plc.Write(plcRes.Station21.ToString(), true); break;
                        case "Station22": plc.Write(plcRes.Station22.ToString(), true); break;
                        case "Station23": plc.Write(plcRes.Station23.ToString(), true); break;
                        case "Station24": plc.Write(plcRes.Station24.ToString(), true); break;
                        case "Station25": plc.Write(plcRes.Station25.ToString(), true); break;
                        case "Station26": plc.Write(plcRes.Station26.ToString(), true); break;
                        case "Station27": plc.Write(plcRes.Station27.ToString(), true); break;
                        case "Station28": plc.Write(plcRes.Station28.ToString(), true); break;
                        case "Station29": plc.Write(plcRes.Station29.ToString(), true); break;
                        case "Station30": plc.Write(plcRes.Station30.ToString(), true); break;
                        case "Station31": plc.Write(plcRes.Station31.ToString(), true); break;
                        case "Station32": plc.Write(plcRes.Station32.ToString(), true); break;
                        case "Station33": plc.Write(plcRes.Station33.ToString(), true); break;
                        case "Station34": plc.Write(plcRes.Station34.ToString(), true); break;
                        case "Station35": plc.Write(plcRes.Station35.ToString(), true); break;
                        case "Station36": plc.Write(plcRes.Station36.ToString(), true); break;
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
                            case "Station26": return plcRes.Station26.ToString();
                            case "Station27": return plcRes.Station27.ToString();
                            case "Station28": return plcRes.Station28.ToString();
                            case "Station29": return plcRes.Station29.ToString();
                            case "Station30": return plcRes.Station30.ToString();
                            case "Station31": return plcRes.Station31.ToString();
                            case "Station32": return plcRes.Station32.ToString();
                            case "Station33": return plcRes.Station33.ToString();
                            case "Station34": return plcRes.Station34.ToString();
                            case "Station35": return plcRes.Station35.ToString();
                            case "Station36": return plcRes.Station36.ToString();
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