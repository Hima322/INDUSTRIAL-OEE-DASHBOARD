using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.andon
{
    public partial class index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string GetCurrentAnonScreen()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.VarTables.Where(i => i.VarName == "CurrentAndonScreen").FirstOrDefault();
                    if (res != null)
                    {
                        return res.VarValue;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
                return "Error";
        }


    }
}