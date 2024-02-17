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
    public partial class add : System.Web.UI.Page
    {
        public static Cryption cryption = new Cryption();
        protected void Page_Load(object sender, EventArgs e)
        { 

        }

        [WebMethod]
        public static string ADD_USER(string userid, string roll, string username, string password)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var userAlreadyExist = mdbEntities.USERs.Where(i => i.UserID == userid).FirstOrDefault();
                    if (userAlreadyExist != null)
                    {
                        return "UserId already exist.";
                    }

                    USER uSER = new USER
                    {
                        UserID = userid,
                        UserName = username,
                        Password = cryption.Encryptword(password),
                        Roll = roll,
                        WorkingAtStationID = "",
                        Authenticated = 0
                    };

                    mdbEntities.USERs.Add(uSER);
                    mdbEntities.SaveChanges();
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