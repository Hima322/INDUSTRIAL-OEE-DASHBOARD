using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;



namespace WebApplication2.AlarmRecord
{
    public partial class AlarmRecord : System.Web.UI.Page
    {
        public static string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (!IsPostBack)
            //{

            //    if (Request.UrlReferrer == null ||
            //        !Request.UrlReferrer.AbsolutePath.EndsWith("index.aspx", StringComparison.OrdinalIgnoreCase))
            //    {
            //        Response.Redirect("~/index.aspx");
            //    }
            //}
        }
        public class Alarm
        {
            public string Start_Date { get; set; }
            public string End_date { get; set; }
            public string Duration { get; set; }
            public string ShiftData { get; set; }
            public string Message { get; set; }
            public string AlarmGroup { get; set; }
        }

        [WebMethod]
        public static List<Alarm> GetAlarmData(string dateFrom, string dateTo, string shift, string group)
        {
            List<Alarm> alarms = new List<Alarm>();

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    string query = @"
                SELECT ID, Start_Date, End_date, Duration, Shift, Message, AlarmGroup
                FROM AlarmDurationList
                WHERE 1 = 1 ";

                    if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(dateTo) && string.IsNullOrEmpty(shift))
                        query += " AND CAST(Start_Date AS date) BETWEEN @DateFrom AND @DateTo ";

                    if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(shift))
                        query += " AND CAST(Start_Date AS date) = @DateFrom AND Shift = @Shift ";

                    if (!string.IsNullOrEmpty(group) && group != "ALL")
                        query += " AND AlarmGroup = @Group ";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        if (!string.IsNullOrEmpty(dateFrom))
                            cmd.Parameters.AddWithValue("@DateFrom", Convert.ToDateTime(dateFrom));

                        if (!string.IsNullOrEmpty(dateTo))
                            cmd.Parameters.AddWithValue("@DateTo", Convert.ToDateTime(dateTo));

                        if (!string.IsNullOrEmpty(shift))
                            cmd.Parameters.AddWithValue("@Shift", shift);

                        if (!string.IsNullOrEmpty(group) && group != "ALL")
                            cmd.Parameters.AddWithValue("@Group", group);

                        SqlDataReader reader = cmd.ExecuteReader();

                        while (reader.Read())
                        {
                            double dur = 0;
                            double.TryParse(reader["Duration"].ToString(), out dur);

                            // round duration if needed
                            int totalSec = (int)Math.Round(dur);

                            int min = totalSec / 60;
                            int sec = totalSec % 60;

                            alarms.Add(new Alarm
                            {
                                Start_Date = Convert.ToDateTime(reader["Start_Date"]).ToString("dd-MM-yyyy HH:mm:ss"),
                                End_date = Convert.ToDateTime(reader["End_date"]).ToString("dd-MM-yyyy HH:mm:ss"),

                                Duration = $"{min:D2}:{sec:D2}",

                                ShiftData = reader["Shift"].ToString(),
                                Message = reader["Message"].ToString(),
                                AlarmGroup = reader["AlarmGroup"].ToString()
                            });

                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
            }

            return alarms;
        }

        //[WebMethod]
        //public static List<Alarm> GetAlarmData(string dateFrom, string dateTo, string shift)
        //{
        //    List<Alarm> alarms = new List<Alarm>();

        //    try
        //    {
        //        using (SqlConnection con = new SqlConnection(connStr))
        //        {
        //            con.Open();

        //            // ✅ Base query
        //            string query = @"
        //                SELECT DATE_TIME, PLANT_NAME, MACHINE, ALARM, SHIFT
        //                FROM dbo.MachineAlarmList
        //                WHERE 1=1";

        //            // ✅ If date range search (from & to provided)
        //            if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(dateTo) && string.IsNullOrEmpty(shift))
        //            {
        //                query += " AND CAST(DATE_TIME AS date) BETWEEN @DateFrom AND @DateTo";
        //            }
        //            // ✅ If shift-based search (single date + shift)
        //            else if (!string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(shift))
        //            {
        //                query += " AND CAST(DATE_TIME AS date) = @DateFrom AND SHIFT = @Shift";
        //            }

        //            using (SqlCommand cmd = new SqlCommand(query, con))
        //            {
        //                // Parameters based on search type
        //                if (!string.IsNullOrEmpty(dateFrom))
        //                    cmd.Parameters.AddWithValue("@DateFrom", Convert.ToDateTime(dateFrom));

        //                if (!string.IsNullOrEmpty(dateTo))
        //                    cmd.Parameters.AddWithValue("@DateTo", Convert.ToDateTime(dateTo));

        //                if (!string.IsNullOrEmpty(shift))
        //                    cmd.Parameters.AddWithValue("@Shift", shift);

        //                SqlDataReader reader = cmd.ExecuteReader();
        //                while (reader.Read())
        //                {
        //                    DateTime dt = Convert.ToDateTime(reader["DATE_TIME"]);

        //                    alarms.Add(new Alarm
        //                    {
        //                        Date = dt.ToString("dd-MM-yyyy"),
        //                        MachineName = reader["MACHINE"].ToString(),
        //                        AlarmTime = dt.ToString("HH:mm"),
        //                        Message = reader["ALARM"].ToString(),
        //                        ShiftData = reader["SHIFT"].ToString()
        //                    });
        //                }
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Optional: log the error if needed
        //        System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
        //    }

        //    return alarms;
        //}

        //public static List<Alarm> GetAlarmData(string dateFrom, string dateTo, string shift)
        //{
        //    List<Alarm> alarms = new List<Alarm>();


        //    using (SqlConnection con = new SqlConnection(connStr))
        //    {
        //        con.Open();
        //        string query = "SELECT DATE_TIME, PLANT_NAME, MACHINE, ALARM FROM dbo.MachineAlarmList WHERE 1=1";

        //        if (!string.IsNullOrEmpty(dateFrom))
        //            query += " AND DATE_TIME >= @DateFrom";

        //        if (!string.IsNullOrEmpty(dateTo))
        //            query += " AND DATE_TIME <= @DateTo";
        //        if (!string.IsNullOrEmpty(shift))
        //            query += " AND Shift = @Shift";

        //        using (SqlCommand cmd = new SqlCommand(query, con))
        //        {
        //            if (!string.IsNullOrEmpty(dateFrom))
        //                cmd.Parameters.AddWithValue("@DateFrom", Convert.ToDateTime(dateFrom));

        //            if (!string.IsNullOrEmpty(dateTo))
        //                cmd.Parameters.AddWithValue("@DateTo", Convert.ToDateTime(dateTo));

        //            if (!string.IsNullOrEmpty(shift))
        //                cmd.Parameters.AddWithValue("@Shift", shift);

        //            SqlDataReader reader = cmd.ExecuteReader();
        //            while (reader.Read())
        //            {
        //                DateTime dt = Convert.ToDateTime(reader["DATE_TIME"]);
        //                alarms.Add(new Alarm
        //                {
        //                    Date = dt.ToString("dd-MM-yyyy"),
        //                    MachineName = reader["MACHINE"].ToString(),
        //                    AlarmTime = dt.ToString("HH:mm"),
        //                    Message = reader["ALARM"].ToString()
        //                });
        //            }
        //        }
        //    }

        //    return alarms;
        //}

        //public class Alarm
        //{
        //    public string Date { get; set; }
        //    public string MachineName { get; set; }
        //    public string AlarmTime { get; set; }
        //    public string Message { get; set; }
        //    public string ShiftData { get; set; }
        //}
    }
}
