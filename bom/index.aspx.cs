using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.bom
{
    public partial class index : System.Web.UI.Page
    {
        public List<BOM> BomList = new List<BOM>();

        protected void Page_Load(object sender, EventArgs e)
        {
            get_bom(Request.Params.Get("fg"));
        }


        private void get_bom(string fg)
        {
            TMdbEntities mdbEntities = new TMdbEntities();
            var bom = mdbEntities.BOMs.Where(i => i.FG_PartNumber == fg).ToList();
            BomList.AddRange(bom);
        }

        protected void DELETE_BOM(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            Response.Write(btn.CommandName);
        }



        [WebMethod]
        public static bool HandleDelete(int id)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.BOMs.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        mdbEntities.BOMs.Remove(res);
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