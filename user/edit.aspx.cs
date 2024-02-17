using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication2.other;

namespace WebApplication2.user
{
    public partial class edit : System.Web.UI.Page
    {
        public static Cryption cryption = new Cryption();
        public string CurrentError = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.Params.Get("id") != null)
                {
                    GET_USER(Convert.ToInt32(Request.Params.Get("id")));
                }
            }
        }


        private void GET_USER(int id)
        {
            try
            {
            using (TMdbEntities mdbEntities = new TMdbEntities())
            {
                var user = mdbEntities.USERs.Where(i => i.ID == id).FirstOrDefault();
                if (user != null)
                {
                    USERID.Text = user.UserID.ToString();
                    USERNAME.Text = user.UserName;
                    PASSWORD.Text = user.Password;
                    ROLL.Value = user.Roll; 
                    ONSTATION.Text = user.WorkingAtStationID.ToString();
                }
            }
            } catch (Exception ex)
            {
                CurrentError = ex.Message;
            }
           

        }


        protected void EDIT_USER(object sender, EventArgs e)
        {
            if (USERID.Text == "" || USERNAME.Text == "" || PASSWORD.Text == "" || ROLL.Value == "")
            {
                CurrentError = "All feilds are required."; 
            }
            else
            {
                try
                {
                    using (TMdbEntities mdbEntities = new TMdbEntities())
                    {
                        var id = Convert.ToInt16(Request.Params.Get("id"));

                        var user = mdbEntities.USERs.Where(i => i.ID == id).FirstOrDefault();

                        if (user != null)
                        { 
                            user.WorkingAtStationID = ONSTATION.Text;
                            user.UserID = USERID.Text; 
                            user.UserName = USERNAME.Text; 
                            user.Password = cryption.Encryptword(PASSWORD.Text);
                            user.Roll = ROLL.Value; 
                            if (ONSTATION.Text == "" || ONSTATION.Text == "")
                            {
                                user.Authenticated = 0;

                            } else
                            {
                                user.Authenticated = 1;
                            }

                            mdbEntities.SaveChanges();
                            Response.Redirect("index.aspx");
                        }

                    }
                }
                catch (Exception ex)
                {
                    CurrentError = ex.Message;
                }
            }
        }

    }
}