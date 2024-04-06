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

namespace WebApplication2.bom
{
    public partial class Print : System.Web.UI.Page
    {
        // Printer2 IP Address and communication port
        public static string printerIpAddress = "";
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
                    var printer1IpRes = db.VarTables.Where(i => i.VarName == "FinelPrinterIp").FirstOrDefault();
                    if (printer1IpRes != null)
                    {
                        printerIpAddress = printer1IpRes.VarValue.Split(':')[0];
                        port = Convert.ToInt32(printer1IpRes.VarValue.Split(':')[1]);
                    }   
                }
            }
            catch { }
        }


        [WebMethod]
        public static string IS_PRINTER_CONNECTED()
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
                return ex.Message;
            }

        }


        [WebMethod]
        public static string BOM_PRINT(int id)
        {
            string name = "";
            string val = "";

            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.BOMs.Where(i => i.ID == id).FirstOrDefault();
                    if(res != null)
                    {
                        name = res.PartName;
                        val = res.PartNumber;
                    }
                }

                // ZPL command 
                string ZPLString = "\u0010CT~~CD,~CC^~CT~\r\n^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD10^JUS^LRN^CI0^XZ\r\n^XA\r\n^MMT\r\n^PW799\r\n^LL0200\r\n^LS0\r\n^FT52,179^BQN,2,6\r\n^FH\\^FDLA,"+val+"^FS\r\n^FT212,73^A0N,32,40^FH\\^FD"+name+"^FS\r\n^FT218,139^A0N,38,38^FH\\^FD"+val+"^FS\r\n^PQ1,0,1,Y^XZ\r\n";


                // check after the ping is n success
                while (IS_PRINTER_CONNECTED() == "Success")
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
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
            return "Something went wrong";
        }
         

    }
}