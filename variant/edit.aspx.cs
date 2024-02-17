using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.variant
{
    public partial class edit : System.Web.UI.Page
    {
        public string CurrentError = "";

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GET_VARIANT(int id)
        {
            var rtn = "";
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.MODEL_DEATILS.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        rtn = JsonSerializer.Serialize(res);
                    }
                }
            } catch (Exception ex)
            {
                rtn = ex.Message;
            }
            return rtn;
        } 

        [WebMethod]
        public static string EDIT_VARIANT(int id, string VARIANT, string C5S_7F, string CustPartNumber, string SEAT, string FGPartNUMBER, string FEATURES, string PART_NAME)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var res = mdbEntities.MODEL_DEATILS.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    { 
                        res.Variant = VARIANT;
                        res.CustPartNumber = CustPartNumber;
                        res.C5S_7F = C5S_7F;
                        res.Seat = SEAT;
                        res.FG_PartNumber = FGPartNUMBER;
                        res.Features = FEATURES;
                        res.PartName = PART_NAME;
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