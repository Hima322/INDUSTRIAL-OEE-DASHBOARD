using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.andon
{
    public partial class Quality_delay : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string GetQualityDelay()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var listRes = entity.DelayRecords.Where(i => i.DelayType == "QualityDelay" && i.DelayTime > DateTime.Today).ToList();

                    if (listRes.Count > 0)
                    {
                        List<object> QualityDelays = new List<object>();
                        for (int j = 1; j <= 25; j++)
                        {
                            int sum = listRes.Where(i => i.StationNo == j.ToString() && i.DelayTime > DateTime.Today).Sum(p => p.DelaySecond).Value;
                            QualityDelays.Add(new Dictionary<string, int>()
                                    {
                                        { "StationNo", j},
                                        { "DelaySecond", sum}
                                    });
                        }

                        return JsonSerializer.Serialize(QualityDelays);
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