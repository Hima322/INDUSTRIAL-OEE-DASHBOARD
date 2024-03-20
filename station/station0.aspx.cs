using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2;
using System.Runtime.CompilerServices;
using System.Data.SqlTypes;
using System.Net.NetworkInformation;

namespace WebApplication2.station
{
    public partial class Station0 : System.Web.UI.Page
    {
        // Printer IP Address and communication port
        public static string printer1IpAddress = "";
        public static int port = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            PAGE_LOAD_FUNCTION();
        }

        [WebMethod]
        public static void PAGE_LOAD_FUNCTION()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //this code for printer1 ip address fetching 
                    var printer1IpRes = db.VarTables.Where(i => i.VarName == "PrinterIp").FirstOrDefault();
                    if (printer1IpRes != null)
                    {
                        printer1IpAddress = printer1IpRes.VarValue.Split(':')[0];
                        port = Convert.ToInt32(printer1IpRes.VarValue.Split(':')[1]);
                    }

                }

            }
            catch { }
        }

        [WebMethod]
        public static string GetStationInfo(string station)
        {
            string station_name = string.Empty;
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var d = db.StationAssignments.Where(i => i.StationNameID == station).FirstOrDefault();
                    if (d != null)
                    {
                        station_name = d.Station_Name;
                    }
                }
                return station_name;

            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string ISPRINTERCONNECTED()
        {
            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(printer1IpAddress);

                // check after the ping is n success
                return PR.Status.ToString();
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

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
        public static string GetRequiredPrint()
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.SEAT_DATA.Where(i => i.StationNo == 0).FirstOrDefault();
                    if (res != null)
                    {
                        var rtn = new Dictionary<string, string>
                            {
                                {"seq",res.SequenceNo.ToString().PadLeft(5,'0') },
                                {"model",res.Model },
                                {"variant",res.Variant },
                                {"fgpart",res.FG_PartNumber },
                                {"seat",res.SeatType },
                            };

                        return JsonSerializer.Serialize(rtn);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }


        [WebMethod]
        public static string IsQRValid(string value)
        {
            string rtn = null;
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var seatDataRes = db.SEAT_DATA.Where(i => i.StationNo == 0).FirstOrDefault();
                    string SelectedFGpartno = seatDataRes.FG_PartNumber.ToString();
                    long ID = seatDataRes.ID;

                    var res = db.BOMs.Where(i => value.Contains(i.PartNumber) && i.FG_PartNumber == SelectedFGpartno).FirstOrDefault();
                    if (res != null)
                    {
                        if (seatDataRes != null)
                        {
                            try
                            {
                                if (PrintBuildTicket(seatDataRes.SequenceNo.ToString().PadLeft(5, '0'), seatDataRes.Model, seatDataRes.Variant, seatDataRes.SeatType, seatDataRes.FG_PartNumber) == "Done")
                                {
                                    seatDataRes.BuildLabelBarcode = seatDataRes.FG_PartNumber + "-" + seatDataRes.SequenceNo.ToString().PadLeft(5, '0');
                                    seatDataRes.StationNo = 1;
                                    seatDataRes.BuildNoDatetime = DateTime.Now;
                                    db.SaveChanges();
                                    rtn = "Done";
                                }
                            }
                            catch (Exception ex)
                            {
                                return "Error: " + ex.Message;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                rtn = null;
                Console.WriteLine(ex.Message);
            }
            return rtn;
        }

        public static string PrintBuildTicket(string seq, string model, string variant, string seat, string fgpart)
        {
            // Open connection
            TcpClient client = new TcpClient();
            client.Connect(printer1IpAddress, port);

            // ZPL command 
            string ZPLString = "\u0010CT~~CD,~CC^~CT~\r\n^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ\r\n^XA\r\n^MMT\r\n^PW531\r\n^LL0177\r\n^LS0\r\n^FT215,39^A0N,25,24^FH\\^FD" + fgpart + "-" + seq + "^FS\r\n^FT31,182^BQN,2,7\r\n^FH\\^FDLA," + fgpart + "-" + seq + "^FS\r\n^FT215,87^A0N,25,24^FH\\^FD" + variant + "^FS\r\n^FT407,88^A0N,25,24^FH\\^FD" + seat + "^FS\r\n^FT243,136^A0N,25,24^FH\\^FD" + model + "^FS\r\n^FT365,135^A0N,31,21^FH\\^FD" + DateTime.Now.ToShortDateString() + "^FS\r\n^PQ1,0,1,Y^XZ";

            // Write ZPL String to connection
            StreamWriter writer = new StreamWriter(client.GetStream());
            writer.Write(ZPLString);
            writer.Flush();

            // Close Connection
            writer.Close();
            client.Close();

            return "Done";
        }

    }

}

