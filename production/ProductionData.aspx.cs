using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;

namespace WebApplication2.production
{
    public partial class modelselection : System.Web.UI.Page
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

        public class ProductionRow
        {
            public string DateTime { get; set; }
            public string Shift { get; set; }
            public string RunningSize { get; set; }
            public int TotalProduction { get; set; }
            public string TotalRunningTime { get; set; }
            public string TotalBDtime { get; set; }
            public string StandByTime { get; set; }
            public string ManualModeTime { get; set; }
            public string SupervisorName { get; set; }

            public string RejectPart { get; set; }
            public string Remarks { get; set; }
        }

        public class ProductionSummaryData
        {
            public string DateTime { get; set; }
            public string Shift { get; set; }
            public string Duration { get; set; }
            public int TotalProduction { get; set; }
        }

        [WebMethod]
        public static List<ProductionRow> GetProductionData(string dateFrom, string dateTo, string shift)
        {
            List<ProductionRow> list = new List<ProductionRow>();
            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"SELECT [DateTime], [Shift], [RunningSize], [TotalProduction],
                                        [TotalRunningTime], [TotalBDtime], [StandByTime], [ManualModeTime],[SupervisorName], [RejectPart],[Remarks]
                                 FROM [ServicesDB].[dbo].[MachinShiftPro]
                                 WHERE [TotalProduction] > 0";

                if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(dateTo) && string.IsNullOrEmpty(shift))
                {
                    query += " AND CAST([DateTime] AS DATE) BETWEEN @DateFrom AND @DateTo";
                }
                else if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(shift))
                {
                    query += " AND CAST([DateTime] AS DATE) = @DateFrom AND [Shift] = @Shift";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(dateFrom))
                        cmd.Parameters.AddWithValue("@DateFrom", DateTime.Parse(dateFrom));
                    if (!string.IsNullOrEmpty(dateTo) && string.IsNullOrEmpty(shift))
                        cmd.Parameters.AddWithValue("@DateTo", DateTime.Parse(dateTo));
                    if (!string.IsNullOrEmpty(shift))
                        cmd.Parameters.AddWithValue("@Shift", shift);

                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        list.Add(new ProductionRow
                        {
                            DateTime = Convert.ToDateTime(dr["DateTime"]).ToString("dd‑MM‑yyyy"),
                            Shift = dr["Shift"].ToString(),
                            RunningSize = dr["RunningSize"].ToString(),
                            TotalProduction = Convert.ToInt32(dr["TotalProduction"]),
                            TotalRunningTime = dr["TotalRunningTime"].ToString(),
                            TotalBDtime = dr["TotalBDtime"].ToString(),
                            StandByTime = dr["StandByTime"].ToString(),
                            ManualModeTime = dr["ManualModeTime"].ToString(),
                            SupervisorName = dr["SupervisorName"].ToString(),
                            RejectPart = dr["RejectPart"].ToString(),
                            Remarks=dr["Remarks"].ToString()
                        });
                    }
                }
            }
            return list;
        }

        [WebMethod]
        public static List<ProductionSummaryData> GetProductionSummary(string dateFrom, string dateTo, string shift)
        {
            List<ProductionSummaryData> list = new List<ProductionSummaryData>();
            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"SELECT [DateTime], [Shift], [Time], [TotalProduction]
                                 FROM [ServicesDB].[dbo].[ProductionTable]
                                 WHERE CAST([DateTime] AS DATE) BETWEEN @DateFrom AND @DateTo";

                if (!string.IsNullOrEmpty(shift))
                    query += " AND [Shift] = @Shift";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DateFrom", DateTime.Parse(dateFrom));
                    cmd.Parameters.AddWithValue("@DateTo", DateTime.Parse(dateTo));
                    if (!string.IsNullOrEmpty(shift))
                        cmd.Parameters.AddWithValue("@Shift", shift);

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        list.Add(new ProductionSummaryData
                        {
                            DateTime = Convert.ToDateTime(reader["DateTime"]).ToString("dd‑MM‑yyyy"),
                            Shift = reader["Shift"].ToString(),
                            Duration = reader["Time"].ToString(),
                            TotalProduction = Convert.ToInt32(reader["TotalProduction"])
                        });
                    }
                }
            }
            return list;
        }
    }
}
