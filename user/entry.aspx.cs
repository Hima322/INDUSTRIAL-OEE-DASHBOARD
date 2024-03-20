using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2.other;

namespace WebApplication2.user
{
    public partial class Entry : System.Web.UI.Page
    { 
        protected void Page_Load(object sender, EventArgs e)
        { 

        }


        [WebMethod]
        public static string UserLogin(string username, string station)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //add data inside operator work time 
                    OperatorWorkTime operatorWorkTime = new OperatorWorkTime
                    {
                        StationNameID = station,
                        OperatorName = username,
                        LoginTime = DateTime.Now
                    };

                    db.OperatorWorkTimes.Add(operatorWorkTime);
                    db.SaveChanges();
                    return "Done";
                }

            } 

            catch
            {
                return "Something went wrong.";
            }
        }

        }
    }
