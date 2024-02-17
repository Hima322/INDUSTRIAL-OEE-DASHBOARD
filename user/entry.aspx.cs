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
    public partial class entry : System.Web.UI.Page
    {
        public static Cryption cryption = new Cryption();
        protected void Page_Load(object sender, EventArgs e)
        { 

        }


        [WebMethod]
        public static string GetAthenticatedUser()
        {
            try
            {
            string AuthData = "";
            using (TMdbEntities db = new TMdbEntities())
            {
                for (int st = 0; st < 17; st++)
                {
                    string s = st.ToString();
                    var d = db.USERs.Where(i => i.WorkingAtStationID == s).FirstOrDefault();
                    if (d == null)
                    {
                        AuthData += s + ",nouser/";
                    }
                    else
                    {
                        if (d.Authenticated == 1)
                        {
                            AuthData += s+"," + d.UserName + "," + d.UserID + "/";
                        }
                        else { AuthData += s+"," + "nouser/"; }
                    }
                }
                AuthData = AuthData.TrimEnd('/');
                return AuthData;
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string UserLogin(string Userid = "",  string Password = "", string Station = "")
        {
            using (TMdbEntities db = new TMdbEntities())
            { 
            var d = db.USERs.Where(i=>i.UserID == Userid).FirstOrDefault();
                if (d != null)
                {
                    if ( cryption.Decryptword(d.Password) == Password)
                    {
                        if (d.Authenticated == 1)
                        { return "Already login at station " + d.WorkingAtStationID; }
                        else
                        {
                            d.WorkingAtStationID = Station;
                            d.Authenticated = 1;

                            //add data inside operator work time 
                            OperatorWorkTime operatorWorkTime = new OperatorWorkTime
                            {
                                StationNameID = Convert.ToInt32(Station),
                                OperatorName = Userid,
                                LoginTime = DateTime.Now
                            };

                            db.OperatorWorkTimes.Add(operatorWorkTime);
                            db.SaveChanges();
                            return "success";
                        }
                    }
                    else
                    { return "Password is wrong"; }
                }
                else
                { return "User is not Available"; }
                }
            }
        }
    }
