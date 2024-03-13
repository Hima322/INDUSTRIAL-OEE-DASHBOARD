using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2.other;

namespace WebApplication2.user
{
    public partial class Info : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string SEARCH_USER(DateTime date, int station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    DateTime nd = date.AddDays(1);
                    var res = db.OperatorWorkTimes.Where(i => i.StationNameID == station && i.LoginTime >= date && i.LoginTime <= nd).ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }

            }

            catch
            {
                return "Error";
            }
            return "Error";
        }

    }
}
