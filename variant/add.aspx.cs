using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.variant
{
    public partial class Add : System.Web.UI.Page
    {  
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ADD_VARIANT(string MODEL, string VARIANT, string C5S_7F, string CustPartNumber, string SEAT, string FGPartNUMBER, string FEATURES, string PART_NAME)
        { 
                try
                {
                    using (TMdbEntities mdbEntities = new TMdbEntities())
                    {
                        MODEL_DEATILS mODEL_DEATILS = new MODEL_DEATILS
                        {
                            Model = MODEL,
                            Variant = VARIANT,
                            CustPartNumber = CustPartNumber,
                            C5S_7F = C5S_7F,
                            Seat = SEAT,
                            FG_PartNumber = FGPartNUMBER,
                            Features = FEATURES,
                            PartName = PART_NAME

                        };

                        mdbEntities.MODEL_DEATILS.Add(mODEL_DEATILS);
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