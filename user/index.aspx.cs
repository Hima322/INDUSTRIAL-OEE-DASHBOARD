using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.user
{
    public partial class index : System.Web.UI.Page
    {
        public string CurrentError = "";
        public List<USER> UserList = new List<USER>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            GET_USER();
            }
        }

        private void GET_USER()
        {
            try
            {
                TMdbEntities mdbEntities = new TMdbEntities();
                var user = mdbEntities.USERs.Where(i => i.Roll != "Admin").ToList();
                UserList.AddRange(user);
            } catch ( Exception e) {
                CurrentError = e.Message;                
            }
               
        }


        [WebMethod]
        public static bool HandleDelete(int id)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.USERs.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        mdbEntities.USERs.Remove(res);
                        mdbEntities.SaveChanges();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
            return false;
        }

    }
}