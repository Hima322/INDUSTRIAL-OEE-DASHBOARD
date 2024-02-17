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
    public partial class print : System.Web.UI.Page
    {
        // Printer2 IP Address and communication port
        public static string printer1IpAddress = "";
        public static int port1 = 0;
        
        // Printer2 IP Address and communication port
        public static string printer2IpAddress = "";
        public static int port2 = 0;

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
                        string ZPLString = "\u0010CT~~CD,~CC^~CT~\r\n^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ\r\n^XA\r\n^MMT\r\n^PW531\r\n^LL0177\r\n^LS0\r\n^FT215,39^A0N,25,24^FH\\^FD" + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS\r\n^FT31,182^BQN,2,7\r\n^FH\\^FDLA," + res.FG_PartNumber + "-" + res.SequenceNo.ToString().PadLeft(5, '0') + "^FS\r\n^FT215,87^A0N,25,24^FH\\^FD" + res.Variant + "^FS\r\n^FT407,88^A0N,25,24^FH\\^FD" + res.SeatType + "^FS\r\n^FT243,136^A0N,25,24^FH\\^FD" + res.Model + "^FS\r\n^FT365,135^A0N,31,21^FH\\^FD" + Convert.ToDateTime(res.BuildNoDatetime).ToShortDateString() + "^FS\r\n^PQ1,0,1,Y^XZ";

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
            return "Something went wrong";
        }


        [WebMethod]
        public static string FINEL_QRCODE_PRINT(int sequence, string seat)
        {
            try
            {
                using(TMdbEntities db  = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.SeatType == seat && i.SequenceNo == sequence).OrderByDescending(o => o.ID).FirstOrDefault();
                    if (res != null)
                    {
                        if(res.FinalBarcodeData == null)
                        {
                            return "Unavailable QR Code.";
                        }

                        // ZPL command
                        string ZPLString = "\u0010CT~~CD,~CC^~CT~ ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD18^JUS^LRN^CI0^XZ ^XA ^MMT ^PW1181 ^LL0295 ^LS0 ^FO32,32^GFA,08192,08192,00032,:Z64: eJzt2TEOwjAMBVBXDBl7hB6Fo9Gj9Sg5QscOFSaxnaRILRJJmPiegh+TG9mmEH2OG6fwRI91YN4opzZ4u89aaPGQW/QY4w7v4aNUmn14FFb/eOQnvK/r/Zb6w3/iNEoS3tVL/7Cmcdlf4BWe5198FFr/8/kIr/BD5P58EfAKt06RS86L49RK4O0eT7K00bSH/U2SzLvAfYO3uySdFn+1pE7FheAdfCUNveqU9jd4D9f9IvYPb0ebf7oqwxv9EFZ0x/Kp9Gd4g7/tb1J0Z8eT/Rhe4bNWX+/3EL9JE4tr/eGNXt7/yNDTUWhZeD+nsr/xsX/D+3hpGmFVtldB8HY/9g89ht8f9lcHvNlT+PzS8no+wr91BOKf4wXW9Sr1:4388 ^FT315,82^A0N,36,36^FH\\^FD"+res.Model+ "^FS ^FT455,79^A0N,33,45^FH\\^FD"+Convert.ToDateTime(res.FinalPrintDateTime).ToString("dd-MM-yyyy HH:mm")+ "^FS ^FT323,134^A0N,44,43^FH\\^FD"+res.Variant+"^FS ^FT455,133^A0N,31,50^FH\\^FD"+res.SeatType+"^FS ^FT323,178^A0N,44,43^FH\\^FDD^FS ^FT326,239^A0N,42,40^FH\\^FD"+res.FinalBarcodeData+"^FS ^PQ1,0,1,Y^XZ";
                        
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
            return "Something went wrong";
        }


    }
}