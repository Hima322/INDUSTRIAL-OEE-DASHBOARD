using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.bom
{
    public partial class add : Page
    {
        public string CurrentError = "";

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
       public static string ADD_BOM(String MODEL, string VARIANT, string FG_PART_NUMBER, string PART_NUMBER, string SIDE, string ASSYSTATIONID, string PART_NAME)
        {
                try
                {
                    using (TMdbEntities mdbEntities = new TMdbEntities())
                    {
                        BOM bOM = new BOM
                        {
                            Model = MODEL, 
                            Variant = VARIANT,
                            FG_PartNumber = FG_PART_NUMBER,
                            PartNumber = PART_NUMBER,
                            Side = SIDE,
                            AssyStationID = Convert.ToInt32(ASSYSTATIONID),
                            PartName = PART_NAME
                        };

                        mdbEntities.BOMs.Add(bOM);
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