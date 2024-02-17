using System;
using System.Linq;

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
                    ASSYSTATIONID.Text = bom.AssyStationID.ToString();
                    PART_NAME.Text = bom.PartName.ToString();
                }
            }

        }


        protected void EDIT_BOM(object sender, EventArgs e)
        {
            if (PART_NUMBER.Text == "" || SIDE.Text == "" || ASSYSTATIONID.Text == "" || PART_NAME.Text == "")
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

                            var bOM = mdbEntities.BOMs.Where(i => i.ID == id).FirstOrDefault();

                        if (bOM != null)
                        {
                            bOM.Model = MODEL.Text;
                            bOM.Variant = VARIANT.Text;
                            bOM.PartNumber = PART_NUMBER.Text;
                            bOM.Side = SIDE.Text;
                            bOM.PartName = PART_NAME.Text;
                            bOM.AssyStationID = Convert.ToInt16(ASSYSTATIONID.Text);
                            mdbEntities.SaveChanges();
                        Response.Redirect("/bom/edit.aspx?model=" + MODEL.Text + "&variant=" + VARIANT.Text + "&fg=" + FG_PART_NUMBER.Text);
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