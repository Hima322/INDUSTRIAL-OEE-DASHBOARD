using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.andon
{
    public partial class Projection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string PRODUCTION_REJECTION()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.BuildNoDatetime > DateTime.Today).ToList();
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