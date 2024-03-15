using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2.other;

namespace WebApplication2.qrlabel
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string GET_PRN_FILE()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                { 
                    var res = db.PrnFiles.ToList();
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
        

        [WebMethod]
        public static string UPDATE_PRN_FILE(int id, string key, float value)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.PrnFiles.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        if(key == "width")
                        {
                            res.Width = System.Math.Round(value, 2);
                        } 
                        if (key == "height")
                        {
                            res.Height = System.Math.Round(value, 2);
                        } 
                        if (key == "top")
                        {
                            res.Top = System.Math.Round(value, 2);
                        }
                        if(key == "left")
                        {
                            res.Left = System.Math.Round(value, 2);
                        }
                        if(key == "font")
                        {
                            res.Width = System.Math.Round(value,2);
                            res.Height = System.Math.Round(value,2);
                        }
                    }

                    db.SaveChanges();
                    return "Done";
                }
            }
            catch (Exception ex) 
            {
                return ex.Message;
            } 
        }

    }
}
