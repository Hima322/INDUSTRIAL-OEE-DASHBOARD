using DocumentFormat.OpenXml.Drawing.Diagrams;
using DocumentFormat.OpenXml.Math;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Vml;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Services;

namespace WebApplication2.Setting
{
    public partial class Setting : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.UrlReferrer == null ||
                    !Request.UrlReferrer.AbsolutePath.EndsWith("index.aspx", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/index.aspx");
                }
            }
        }

        [WebMethod]
        public static List<dynamic> GetTodayData(string dt)
        {
            List<dynamic> list = new List<dynamic>();
            string conStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"SELECT ID, DateTime, Shift, RunningSize, TotalProduction,SupervisorName, RejectPart 
                                 FROM MachinShiftPro WHERE CAST(DateTime AS DATE)=@dt";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@dt", dt);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    list.Add(new
                    {
                        ID = dr["ID"],
                        DateTime = dr["DateTime"].ToString(),
                        Shift = dr["Shift"].ToString(),
                        RunningSize = dr["RunningSize"].ToString(),
                        TotalProduction = dr["TotalProduction"].ToString(),
                        SuperviserName = dr["SupervisorName"].ToString(),
                        RejectPart = dr["RejectPart"].ToString()
                    });
                }
            }
            return list;
        }

        [WebMethod]
        public static void UpdateShiftData(int id, string reject)
        {
            string conStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE MachinShiftPro SET RejectPart=@rej WHERE ID=@id", con);
                cmd.Parameters.AddWithValue("@rej", reject);
                cmd.Parameters.AddWithValue("@id", id);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        [WebMethod]
        public static void SaveTarget(string shift, string value)
        {
            //string varName = shift == "1" ? "TargetAshift" : shift == "2" ? "TargetBshift" : "TargetCshift";
            string varName = shift; // == "1" ? "TargetAshift" : shift == "2" ? "TargetBshift" : "TargetCshift";

            string conStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE VARIABLE SET VARIABLE_VALUE=@val WHERE VARIBALE_NAME=@name", con);
                cmd.Parameters.AddWithValue("@val", value);
                cmd.Parameters.AddWithValue("@name", varName);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        [WebMethod]
        public static void SaveSupervisor(string supervisorName)
        {
            string conStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE VARIABLE SET VARIABLE_VALUE=@val WHERE VARIBALE_NAME='SupervisorName'", con);
                cmd.Parameters.AddWithValue("@val", supervisorName);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
     [WebMethod]
public static string SaveRemark(string remark)
{
    try
    {
        string conStr = System.Configuration.ConfigurationManager
                        .ConnectionStrings["constr"].ConnectionString;

        using (SqlConnection con = new SqlConnection(conStr))
        {
            SqlCommand cmd = new SqlCommand(
            @"UPDATE VARIABLE 
              SET VARIABLE_VALUE = 
                  CASE 
                      WHEN VARIABLE_VALUE IS NULL OR LTRIM(RTRIM(VARIABLE_VALUE)) = '' 
                          THEN @val
                      ELSE VARIABLE_VALUE + ', ' + @val
                  END
              WHERE VARIBALE_NAME = 'Remarks'",
            con);

            cmd.Parameters.AddWithValue("@val", remark);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        return "OK";
    }
    catch (Exception ex)
    {
        return "ERROR: " + ex.Message;
    }
}




    }
}
