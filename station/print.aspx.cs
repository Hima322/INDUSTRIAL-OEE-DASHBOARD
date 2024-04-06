using S7.Net;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Web;
using System.Web.Services;
using System.Web.Services.Description;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace WebApplication2.station
{
    public partial class Print : System.Web.UI.Page
    {
        // Printer2 IP Address and communication port
        public static string printer1IpAddress = "";
        public static int port1 = 0;
        
        // Printer2 IP Address and communication port
        public static string printer2IpAddress = "";
        public static int port2 = 0; 

        public static double bd = 0;
        public static double fd = 0;

        public static string builtTicketBrightness = "15";
        public static string finelTicketBrightness = "15"; 

        public static List<PrnFile> prnData;

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
                        port1 = Convert.ToInt32(printer1IpRes.VarValue.Split(':')[1]);
                    }
                    //this code for printer1 ip address fetching 
                    var printer2IpRes = db.VarTables.Where(i => i.VarName == "FinelPrinterIp").FirstOrDefault();
                    if (printer2IpRes != null)
                    {
                        printer2IpAddress = printer2IpRes.VarValue.Split(':')[0];
                        port2 = Convert.ToInt32(printer2IpRes.VarValue.Split(':')[1]);
                    }  
                    var builtPrinterDpiRes = db.VarTables.Where(i => i.VarName == "BuiltPrinterDpi").FirstOrDefault();
                    if (builtPrinterDpiRes != null)
                    {
                        bd = Convert.ToDouble(builtPrinterDpiRes.VarValue) / 25.4; 
                    }
                    var finelPrinterDpiRes = db.VarTables.Where(i => i.VarName == "FinelPrinterDpi").FirstOrDefault();
                    if (finelPrinterDpiRes != null)
                    {
                        fd = Convert.ToDouble(finelPrinterDpiRes.VarValue) / 25.4;
                    }
                    var builtTicketBrightRes = db.VarTables.Where(i => i.VarName == "BuiltTicketBrightness").FirstOrDefault();
                    if (builtTicketBrightRes != null)
                    {
                        builtTicketBrightness = builtTicketBrightRes.VarValue;
                    }
                    var finelTicketBrightRes = db.VarTables.Where(i => i.VarName == "FinelTicketBrightness").FirstOrDefault();
                    if (finelTicketBrightRes != null)
                    {
                        finelTicketBrightness = finelTicketBrightRes.VarValue;
                    }
                    //this code for get prn data fetching 
                    var prnRes = db.PrnFiles.ToList();
                    if (prnRes != null)
                    {
                        prnData = prnRes;
                    }
                }
            }
            catch { }
        }
         

        [WebMethod]
        public static string IS_PRINTER1_CONNECTED()
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
        public static string IS_PRINTER2_CONNECTED()
        {
            try
            {
                Ping p1 = new Ping();
                PingReply PR = p1.Send(printer2IpAddress);

                // check after the ping is n success 
                return PR.Status.ToString();
            }
            catch (Exception ex)
            { 
                return ex.Message;
            }

        }
         

        [WebMethod]
        public static string BUILT_TICKET_PRINT(int sequence, string seat)
        {
            try
            {
                using(TMdbEntities db  = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.SeatType == seat && i.SequenceNo == sequence).OrderByDescending(o => o.ID).FirstOrDefault();
                    if (res != null)
                    {
                        // ZPL command 
                        string ZPLString = "\u0010CT~~CD,~CC^~CT~" +
                            "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ" +
                            "^XA\r\n^MMT\r\n^PW531" +
                            "^LL0177" +
                            "^LS0" +
                            "^FT215,39^A0N,25,24^FH\\^FD" + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS" +
                            "^FT31,182^BQN,2,7" +
                            "^FH\\^FDLA," + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS" +
                            "^FT215,87^A0N,25,24^FH\\^FD" + res.Variant + "^FS" +
                            "^FT407,88^A0N,25,24^FH\\^FD" + res.SeatType + "^FS" +
                            "^FT243,136^A0N,25,24^FH\\^FD" + res.Model + "^FS" +
                            "^FT365,135^A0N,31,21^FH\\^FD" + Convert.ToDateTime(res.BuildNoDatetime).ToShortDateString() + "^FS" +
                            "^PQ1,0,1,Y^XZ";

                        //trying to handle with databases that is prnData 
                        string errZPLString = "\u0010CT~~CD,~CC^~CT~" +
                            "^XA~TA000~JSN" +
                            "^LT0" +
                            "^MNW" +
                            "^MTT" +
                            "^PON" +
                            "^PMN" +
                            "^LH0,0" +
                            "^JMA" +
                            "^PR6,6" +
                            $"~SD{builtTicketBrightness}" +
                            "^JUS^LRN" +
                            "^CI0^XZ" +
                            "^XA" +
                            "^MMT" +
                            "^PW531" +
                            "^LL0177" +
                            "^LS0" +
                            $"^FT{prnData[11].Left * bd},{prnData[11].Top * bd}^A0N,{prnData[11].Width},{prnData[11].Height}^FH\\^FD" + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS" +
                            $"^FT{prnData[12].Left * bd},{prnData[12].Top * bd}^BQN,{prnData[12].Width},{prnData[12].Height}^FH\\^FDLA," + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS" +
                            $"^FT{prnData[13].Left * bd},{prnData[13].Top * bd}^A0N,{prnData[13].Width},{prnData[13].Height}^FH\\^FD" + res.Variant + "^FS" +
                            $"^FT{prnData[14].Left * bd},{prnData[14].Top * bd}^A0N,{prnData[14].Width},{prnData[14].Height}^FH\\^FD" + res.SeatType + "^FS" +
                            $"^FT{prnData[15].Left * bd},{prnData[15].Top * bd}^A0N,{prnData[15].Width},{prnData[15].Height}^FH\\^FD" + res.Model + "^FS" +
                            $"^FT{prnData[16].Left * bd},{prnData[16].Top * bd}^A0N,{prnData[16].Width},{prnData[16].Height}^FH\\^FD" + Convert.ToDateTime(res.BuildNoDatetime).ToShortDateString() + "^FS" +
                            "^PQ1,0,1,Y^XZ";

                        // check after the ping is n success
                        while (IS_PRINTER2_CONNECTED() == "Success")
                        {
                            // Open connection
                            TcpClient client = new TcpClient();
                            client.Connect(printer1IpAddress, port1);

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
            }catch (Exception ex)
            {
                return ex.Message;
            }
            return "Something went wrong";
        }


        [WebMethod]
        public static string FINEL_QRCODE_PRINT(int sequence, string seat)
        {
            string feature = "";
            try
            {
                using(TMdbEntities db  = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.SeatType == seat && i.SequenceNo == sequence).OrderByDescending(o => o.ID).FirstOrDefault();
                    if (res != null)
                    {
                        var modelDetailsRes = db.MODEL_DEATILS.Where(i => i.ModelVariant == res.ModelVariant).FirstOrDefault();
                        if(modelDetailsRes != null) { feature = modelDetailsRes.Features; }

                        if(res.FinalBarcodeData == null)
                        {
                            return "Unavailable QR Code.";
                        }

                        string ZPLString = "\u0010CT~~CD,~CC^~CT~" +
                            "^XA" +
                            "~TA000" +
                            "~JSN" +
                            "^LT0" +
                            "^MNW" +
                            "^MTT" +
                            "^PON" +
                            "^PMN" +
                            "^LH0,0" +
                            "^JMA" +
                            "^PR6,6" +
                            "~SD15" +
                            "^JUS" +
                            "^LRN" +
                            "^CI27" +
                            "^PA0,1,1,0" +
                            "^XZ" +
                            "^XA" +
                            "^MMT" +
                            "^PW1181" +
                            "^LL295" +
                            "^LS0" +
                            "^FT316,67^A0N,40,48^FH\\^CI28^FD" + res.Model + "^FS^CI27" +
                            "^FT598,69^A0N,42,43^FH\\^CI28^FD" + Convert.ToDateTime(res.FinalPrintDateTime).ToString("dd-MM-yyyy HH:mm") + "^FS^CI27" +
                            "^FT321,133^A0N,42,43^FH\\^CI28^FD" + res.Variant + "^FS^CI27" +
                            "^FT316,251^A0N,40,41^FH\\^CI28^FD" + res.FinalBarcodeData + "^FS^CI27" +
                            "^FT772,133^A0N,42,43^FH\\^CI28^FD" + res.SeatType + "^FS^CI27" +
                            "^FT591,128^A0N,42,43^FH\\^CI28^FD" + feature + "^FS^CI27" +
                            "^FT321,193^A0N,42,43^FH\\^CI28^FD" + res.FG_PartNumber + "^FS^CI27" +
                            "^FT53,267^BQN,2,9" +
                            "^FH\\^FDLA," + res.FG_PartNumber + "^FS^CI27" +
                            "^PQ1,0,1,Y" +
                            "^XZ";

                        // trying to handle this label with prn datsbase  
                        string errZPLString = "\u0010CT~~CD,~CC^~CT~" +
                            "^XA" +
                            "~TA000" +
                            "~JSN" +
                            "^LT0" +
                            "^MNW" +
                            "^MTT" +
                            "^PON" +
                            "^PMN" +
                            "^LH0,0" +
                            "^JMA" +
                            "^PR6,6" +
                            $"~SD{finelTicketBrightness}" +
                            "^JUS" +
                            "^LRN" +
                            "^CI27" +
                            "^PA0,1,1,0" +
                            "^XZ" +
                            "^XA" +
                            "^MMT" +
                            "^PW1181" +
                            "^LL295" +
                            "^LS0" +
                            $"^FT{prnData[3].Left * fd},{prnData[3].Top * fd}^A0N,{prnData[3].Width },{prnData[3].Height}^FH\\^CI28^FD" + res.Model + "^FS^CI27" +
                            $"^FT{prnData[4].Left * fd},{prnData[4].Top * fd}^A0N,{prnData[4].Width},{prnData[4].Height}^FH\\^CI28^FD" + Convert.ToDateTime(res.FinalPrintDateTime).ToString("dd-MM-yyyy HH:mm") + "^FS^CI27" +
                            $"^FT{prnData[5].Left * fd},{prnData[5].Top * fd}^A0N,{prnData[5].Width},{prnData[5].Height}^FH\\^CI28^FD" + res.Variant + "^FS^CI27" +
                            $"^FT{prnData[6].Left * fd},{prnData[6].Top * fd}^A0N,{prnData[6].Width},{prnData[6].Height}^FH\\^CI28^FD" + res.FinalBarcodeData + "^FS^CI27" +
                            $"^FT{prnData[7].Left * fd},{prnData[7].Top * fd}^A0N,{prnData[7].Width},{prnData[7].Height}^FH\\^CI28^FD" + res.SeatType + "^FS^CI27" +
                            $"^FT{prnData[8].Left * fd},{prnData[8].Top * fd}^A0N,{prnData[8].Width},{prnData[8].Height}^FH\\^CI28^FD" + feature + "^FS^CI27" +
                            $"^FT{prnData[9].Left * fd},{prnData[9].Top * fd}^A0N,{prnData[9].Width},{prnData[9].Height}^FH\\^CI28^FD" + res.FG_PartNumber + "^FS^CI27" +
                            $"^FT{prnData[10].Left * fd},{prnData[10].Top * fd}^A0N,{prnData[10].Width},{prnData[10].Height}^FH\\^CI28^FD" + " " +
                            $"^FT{prnData[2].Left * fd},{prnData[2].Top * fd}^BQN,{prnData[2].Width},{prnData[2].Height}^FH\\^FDLA," + res.FinalBarcodeData + res.STAUS == "HOLD" ? "HOLD" : "" + "^FS" +
                            "^PQ1,0,1,Y" +
                            "^XZ";

                        // check after the ping is n success
                        while (IS_PRINTER2_CONNECTED() == "Success")
                        {
                            // Open connection
                            TcpClient client = new TcpClient();
                            client.Connect(printer2IpAddress, port2);

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
            }catch (Exception ex)
            {
                return ex.Message;
            }
            return "Unavailable Sequence.";
        }


    }
}