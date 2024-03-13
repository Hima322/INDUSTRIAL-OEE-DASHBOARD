using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.report
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GET_MODEL_LIST()
        {
            try
            { 
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.MODELs.ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            { 
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GET_VARIANT_LIST()
        {
            try
            { 
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.MODEL_DEATILS.ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            { 
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }

        [WebMethod]
        public static string GET_DAY_REPORT(DateTime from, DateTime to)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //var res = db.JITLineSeatMfgReports.Where(i => i.Date >= from && i.Date <= to).ToList();
                    var res = db.JITLineSeatMfgReports.SqlQuery("select * from JITLineSeatMfgReport where Date >= '"+from+"' and Date <= '"+to+"'").ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GET_SERIAL_REPORT(string serial)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.JITLineSeatMfgReports.Where(i => i.SeatSerialNumber == serial).FirstOrDefault(); 
                    if (res != null)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GET_SHIFT_REPORT(string shift, DateTime from, DateTime to)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.JITLineSeatMfgReports.Where(i => i.Shift == shift && i.Date >= from && i.Date <= to).ToList(); 
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GET_MODEL_REPORT(string model, DateTime from, DateTime to)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //var res = db.JITLineSeatMfgReports.Where(i => i.Date >= from && i.Date <= to).ToList();
                    var res = db.JITLineSeatMfgReports.SqlQuery("select * from JITLineSeatMfgReport where BuildLabelNumber like '%" + model + "%' and Date >= '"+from+"' and Date <= '"+to+"'").ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }

        
        [WebMethod]
        public static string GET_VARIANT_REPORT(string variant, DateTime from, DateTime to)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //var res = db.JITLineSeatMfgReports.Where(i => i.Date >= from && i.Date <= to).ToList();
                    var res = db.JITLineSeatMfgReports.SqlQuery("select * from JITLineSeatMfgReport where BuildLabelNumber like '%" + variant + "%' and Date >= '"+from+"' and Date <= '"+to+"'").ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
            return "Error";
        }


    }
}