using System;
using System.Linq;
using System.Text.Json;
using System.Web.Services;

namespace WebApplication2.bom
{
    public partial class Edit : System.Web.UI.Page
    {
        public string CurrentError = "";
        protected void Page_Load(object sender, EventArgs e)
        { 

        }

        [WebMethod]
        public static string GET_BOM(int id)
        {
            try
            {
                using (TMdbEntities mdbEntities = new TMdbEntities())
                {
                    var bom = mdbEntities.BOMs.Where(i => i.ID == id).FirstOrDefault();
                    if (bom != null)
                    {
                        return JsonSerializer.Serialize(bom);
                    }
                }
            }
            catch
            {
                return "Error";
            }
            return "Error";
        }


        [WebMethod]
        public static string EDIT_BOM(int id, string PART_NUMBER, bool DUPLICATE, string SIDE, string PART_NAME)
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
                        bOM.IsDuplicate = DUPLICATE;
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