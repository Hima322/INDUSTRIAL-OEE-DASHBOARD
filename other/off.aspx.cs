using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.other
{
    public partial class Off : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string POWER_OFF()
        {
            Process Proc = null; 
            try { 
                string CmdDir = Environment.CurrentDirectory + @"\CMD"; 
                Proc = new Process(); 
                Proc.StartInfo.WorkingDirectory = CmdDir; 
                Proc.StartInfo.FileName = "shutdown1";
                Proc.StartInfo.CreateNoWindow = false; 
                Proc.Start(); 
                Proc.WaitForExit();
                return "Done";
            } catch (Exception Ex) {
                return Ex.Message;
            }
        }
            //Debug mai ye script file bnani pdegi net use \\172.12.18.10 Admin / USER:Admin & shutdown - s - m \\172.12.18.10 - t 1


        }
    }
