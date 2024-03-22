using System;
using System.Linq;
using System.Web.Services;

namespace WebApplication2.bom
{
    public partial class edit : System.Web.UI.Page
    {
        public string CurrentError = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.Params.Get("id") != null)
                {
                    GET_BOM(Convert.ToInt32(Request.Params.Get("id")));
                }
            }
        }


        private void GET_BOM(int id)
        {
            using (TMdbEntities mdbEntities = new TMdbEntities())
            {
                var bom = mdbEntities.BOMs.Where(i => i.ID == id).FirstOrDefault();
                if (bom != null)
                {
                    MODEL.Text = bom.Model.ToString();
                    VARIANT.Text = bom.Variant.ToString();
                    FG_PART_NUMBER.Text = bom.FG_PartNumber.ToString();
                    PART_NUMBER.Text = bom.PartNumber.ToString();
                    SIDE.Text = bom.Side.ToString(); 
                    PART_NAME.Text = bom.PartName.ToString();
                }
            }

        }


        [WebMethod]
        public static string EDIT_BOM(int id, string PART_NUMBER, string SIDE, string PART_NAME)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var bOM = mdbEntities.BOMs.Where(i => i.ID == id).FirstOrDefault();

                    if (bOM != null)
                    { 
                        bOM.PartNumber = PART_NUMBER;
                        bOM.Side = SIDE;
                        bOM.PartName = PART_NAME;
                    }

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