using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Wordprocessing;

using S7.Net;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web.Services;
using System.Web.Services.Description;
using System.Net.NetworkInformation;
using System.Diagnostics;
using System.Net.Sockets;

using System.Drawing;
using System.Text;
using System.Threading;


namespace WebApplication2
{
    public partial class index : System.Web.UI.Page
    {
        public static string path = @"D:\ModBusServices\ModBusServices\ModBusServices\bin\Debug\output.txt";
        public static string plcIP = "192.168.2.242";
        static string ipAddress = "192.168.2.10";  

        protected void Page_Load(object sender, EventArgs e)
        {
        }


        [WebMethod]
        public static bool ISPLCONNECTED()
        {
            try
            {
                Ping ping = new Ping();
                PingReply reply = ping.Send(plcIP, 1000); // 1 second timeout
                return reply.Status == IPStatus.Success;
            }
            catch
            {
                return false;
            }
        }


        [WebMethod]

        public static string GetShiftTarget(string currentShift)
        {
            string targetValue = string.Empty;

            try
            {
               string varName = currentShift == "1" ? "TargetAshift"
                               : currentShift == "2" ? "TargetBshift"
                               : "TargetCshift";
                string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(conStr))
                {
                   
                    string query = "SELECT VARIABLE_VALUE FROM VARIABLE WHERE VARIBALE_NAME = @name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", varName);

                        conn.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            targetValue = result.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
             
            }

            return targetValue;
        }
        [WebMethod]
        public static string GetMonthlyTarget()
        {
            string targetValue = string.Empty;

            try
            {
               string varName = "TargetMonth";
                string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(conStr))
                {
                   
                    string query = "SELECT VARIABLE_VALUE FROM VARIABLE WHERE VARIBALE_NAME = @name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", varName);

                        conn.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            targetValue = result.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
             
            }

            return targetValue;
        }


        [WebMethod]
        public static string ISDBCONNECTION()
        {
            try
            {
                string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(conStr))
                {
                    conn.Open();
                    if (conn.State == System.Data.ConnectionState.Open)
                        return "Success";
                    else
                        return "Error: Unable to open connection.";
                }
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }
        [WebMethod]
        public static object GetVarData()
        {
            string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
            var data = new Dictionary<string, string>();

            try
            {
                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    string query = "SELECT VARIBALE_NAME, VARIABLE_VALUE FROM VARIABLE";
                    SqlCommand cmd = new SqlCommand(query, con);
                    SqlDataReader dr = cmd.ExecuteReader();

                    Dictionary<string, string> variables = new Dictionary<string, string>();
                    while (dr.Read())
                    {
                        variables[dr["VARIBALE_NAME"].ToString()] = dr["VARIABLE_VALUE"].ToString();
                    }
                    dr.Close();

                    // --- Get Current Time ---
                    DateTime now = DateTime.Now;
                    string currentShift = "N/A";

                    // --- Detect Shift (A/B/C) ---
                    foreach (var kvp in variables)
                    {
                        if (kvp.Key.Contains(":")) // shift key like "06:30:59-15:00:00"
                        {
                            string[] parts = kvp.Key.Split('-');
                            if (parts.Length == 2)
                            {
                                TimeSpan start = TimeSpan.Parse(parts[0]);
                                TimeSpan end = TimeSpan.Parse(parts[1]);

                                bool inShift = (start < end)
                                    ? (now.TimeOfDay >= start && now.TimeOfDay <= end)
                                    : (now.TimeOfDay >= start || now.TimeOfDay <= end);

                                if (inShift)
                                {
                                    currentShift = kvp.Value; // A / B / C
                                    break;
                                }
                            }
                        }
                    }

                    // --- Running Model ---
                    string runningModel = variables.ContainsKey("RunningModel") ? variables["RunningModel"] : "N/A";

                    // --- Return data ---
                    data["RunningShift"] = currentShift;
                    data["RunningModel"] = runningModel;
                }
            }
            catch (Exception ex)
            {
                data["Error"] = ex.Message;
            }

            return data;
        }



        [WebMethod]
        public static object GetChartData()
        {
            string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            try
            {
                DateTime now = DateTime.Now;
                DateTime today = now.Date;

                // --- Shift Timings ---
                DateTime shiftAStart = today.AddHours(6).AddMinutes(30);
                DateTime shiftAEnd = today.AddHours(15);
                DateTime shiftBStart = today.AddHours(15).AddMinutes(1);
                DateTime shiftBEnd = today.AddHours(23);
                DateTime shiftCStart = today.AddHours(23).AddMinutes(1);
                DateTime shiftCEnd = today.AddDays(1).AddHours(6).AddMinutes(30);

                string currentShift;
                DateTime shiftStart, shiftEnd;

                // --- Determine Current Shift ---
                if (now >= shiftAStart && now < shiftAEnd)
                {
                    currentShift = "A"; shiftStart = shiftAStart; shiftEnd = shiftAEnd;
                }
                else if (now >= shiftBStart && now < shiftBEnd)
                {
                    currentShift = "B"; shiftStart = shiftBStart; shiftEnd = shiftBEnd;
                }
                else
                {
                    currentShift = "C";
                    if (now >= shiftCStart)
                    {
                        shiftStart = shiftCStart; shiftEnd = shiftCEnd;
                    }
                    else
                    {
                        shiftStart = shiftCStart.AddDays(-1); shiftEnd = shiftCEnd.AddDays(-1);
                    }
                }

                // --- Prepare Hourly Buckets ---
                var hoursData = new Dictionary<string, List<dynamic>>();
                DateTime temp = shiftStart;
                while (temp < shiftEnd)
                {
                    string label = $"{temp:HH}:00 - {temp.AddHours(1):HH}:00";
                    hoursData[label] = new List<dynamic>();
                    temp = temp.AddHours(1);
                }

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    string query = @"
                SELECT DATEPART(HOUR, DateTime) AS HourPart, MachineName,
                       SUM(ISNULL(TotalBDtime,0)) AS BreakDownTime,
                       SUM(ISNULL(RunningTime,0)) AS RunningTime
                FROM [ServicesDB].[dbo].[ProductionTable]
                WHERE DateTime BETWEEN @Start AND @End
                GROUP BY DATEPART(HOUR, DateTime), MachineName
                ORDER BY HourPart";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Start", shiftStart);
                    cmd.Parameters.AddWithValue("@End", shiftEnd);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int hour = Convert.ToInt32(dr["HourPart"]);
                            string machine = dr["MachineName"].ToString();
                            double bdTime = dr["BreakDownTime"] != DBNull.Value ? Convert.ToDouble(dr["BreakDownTime"]) : 0;
                            double runTime = dr["RunningTime"] != DBNull.Value ? Convert.ToDouble(dr["RunningTime"]) : 0;

                            foreach (var key in hoursData.Keys.ToList())
                            {
                                if (key.StartsWith(hour.ToString("00") + ":"))
                                {
                                    hoursData[key].Add(new { Machine = machine, BDTime = bdTime, RunTime = runTime });
                                    break;
                                }
                            }
                        }
                    }
                }

                var shiftData = hoursData.Select(kvp => new
                {
                    HourRange = kvp.Key,
                    TotalBDTime = kvp.Value.Sum(x => (double)x.BDTime),
                    TotalRunTime = kvp.Value.Sum(x => (double)x.RunTime),
                    Machines = kvp.Value
                }).ToList();

                return new
                {
                    CurrentShift = currentShift,
                    ShiftStart = shiftStart.ToString("yyyy-MM-dd HH:mm"),
                    ShiftEnd = shiftEnd.ToString("yyyy-MM-dd HH:mm"),
                    ShiftAlarms = shiftData
                };
            }
            catch (Exception ex)
            {
                return new { Error = true, Message = ex.Message };
            }
        }



        [WebMethod]
        public static object GetHourlyProductionByShift()
        {
           
            string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            try
            {
                DateTime now = DateTime.Now;
                DateTime today = now.Date;

                // Shift timings
                DateTime shiftAStart = today.AddHours(6).AddMinutes(30);
                DateTime shiftAEnd = today.AddHours(15);

                DateTime shiftBStart = today.AddHours(15).AddMinutes(01);
                DateTime shiftBEnd = today.AddHours(23);

                DateTime shiftCStart = today.AddHours(23).AddMinutes(01);
                DateTime shiftCEnd = today.AddDays(1).AddHours(6).AddMinutes(30);

                string currentShift;
                DateTime shiftStart, shiftEnd;

                if (now >= shiftAStart && now < shiftAEnd)
                {
                    currentShift = "A"; shiftStart = shiftAStart; shiftEnd = shiftAEnd;
                }
                else if (now >= shiftBStart && now < shiftBEnd)
                {
                    currentShift = "B"; shiftStart = shiftBStart; shiftEnd = shiftBEnd;
                }
                else
                {
                    currentShift = "C";
                    if (now >= shiftCStart)
                    {
                        shiftStart = shiftCStart; shiftEnd = shiftCEnd;
                    }
                    else
                    {
                        shiftStart = shiftCStart.AddDays(-1); shiftEnd = shiftCEnd.AddDays(-1);
                    }
                }

                // Hourly slots
                var hourlyProduction = new Dictionary<string, int>();
                DateTime temp = shiftStart;
                while (temp < shiftEnd)
                {
                    string label = $"{temp:HH}:00 - {temp.AddHours(1):HH}:00";
                    hourlyProduction[label] = 0;
                    temp = temp.AddHours(1);
                }

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();
                    string query = @"
                SELECT DATEPART(HOUR, DateTime) AS HourPart,
                       ISNULL(SUM(TotalProduction),0) AS TotalProd
                FROM [ServicesDB].[dbo].[ProductionTable]
                WHERE DateTime BETWEEN @Start AND @End
                GROUP BY DATEPART(HOUR, DateTime)
                ORDER BY HourPart";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Start", shiftStart);
                    cmd.Parameters.AddWithValue("@End", shiftEnd);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int hour = Convert.ToInt32(dr["HourPart"]);
                            int total = dr["TotalProd"] != DBNull.Value ? Convert.ToInt32(dr["TotalProd"]) : 0;

                            foreach (var key in hourlyProduction.Keys.ToList())
                            {
                                if (key.StartsWith(hour.ToString("00") + ":"))
                                {
                                    hourlyProduction[key] = total;
                                    break;
                                }
                            }
                        }
                    }
                    con.Close();
                }

                var data = hourlyProduction.Select(kvp => new
                {
                    HourRange = kvp.Key,
                    Total = kvp.Value
                }).ToList();

                return new
                {
                    Shift = currentShift,
                    ShiftStart = shiftStart.ToString("yyyy-MM-dd HH:mm"),
                    ShiftEnd = shiftEnd.ToString("yyyy-MM-dd HH:mm"),
                    Data = data
                };
            }
            catch (Exception ex)
            {
                return new { Error = true, Message = ex.Message };
            }
        }


        [WebMethod]
        public static string GetAvailability()
        {
            var data = GetMachineAvailability() as Dictionary<string, string>;
            return data != null && data.ContainsKey("Availability") ? data["Availability"] : "0 %";
        }
        public static object GetMachineAvailability()
        {
            string filePath = path;
           

            var result = new Dictionary<string, string>
    {
        {"RunningTime", "0"},
        {"BDTime", "0"},
        {"StandbyTime", "0"},
        {"ManualTime", "0"},
        {"Availability", "0 %"}
    };

            try
            {
                int runningTime = 0;
                int bdTime = 0;
                int standbyTime = 0;
                int manualTime = 0;

                // Read times from file
                if (File.Exists(filePath))
                {
                    var lines = File.ReadAllLines(filePath);
                    foreach (var line in lines)
                    {
                        if (string.IsNullOrWhiteSpace(line)) continue;

                        var parts = line.Split(':');
                        if (parts.Length == 2 && int.TryParse(parts[1].Trim(), out int value))
                        {
                            string key = parts[0].Trim();
                            if (key == "RunningTime") runningTime = value;
                            else if (key == "BDTime") bdTime = value;
                            else if (key == "StandbyTime") standbyTime = value;
                            else if (key == "ManualTime") manualTime = value;

                            result[key] = value.ToString();
                        }
                    }
                }

                // Total BD Time
                int totalBDTime = bdTime + standbyTime + manualTime;

                // Availability formula
                double availability = 0;
                if (runningTime + totalBDTime > 0)
                    availability = (double)runningTime / (runningTime + totalBDTime) * 100;

                result["Availability"] = availability.ToString("0.00") + " %";
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return result;
        }


        [WebMethod]
        public static object GetDashboardDataFromFile()
        {
            string filePath = path;
                //@"D:\ModBusServices\ModBusServices\ModBusServices\bin\Debug\output.txt";

            var result = new Dictionary<string, string>
    {
        {"Production", "0"},
        {"RunningTime", "0 min 0 sec"},
        {"RunningStatus", "0"},
        {"BDTime", "0 min 0 sec"},
        {"BDStatus", "0"},
        {"StandbyTime", "0 min 0 sec"},
        {"StandbyStatus", "0"},
        {"ManualTime", "0 min 0 sec"},
        {"ManualStatus", "0"},
        {"MonthlyProduction", "0"}
    };

            try
            {
                // Read from file
                if (File.Exists(filePath))
                {
                    var lines = File.ReadAllLines(filePath);
                    foreach (var line in lines)
                    {
                        if (string.IsNullOrWhiteSpace(line)) continue;

                        var parts = line.Split(':');
                        if (parts.Length == 2)
                        {
                            string key = parts[0].Trim();
                            int value;
                            if (int.TryParse(parts[1].Trim(), out value))
                            {
                                if (result.ContainsKey(key))
                                {
                                   
                                    if (key == "RunningTime" || key == "BDTime" || key == "StandbyTime" || key == "ManualTime")
                                    {
                                        result[key] = ConvertSecondsToMinutesSeconds(value);
                                    }
                                    else
                                    {
                                        result[key] = value.ToString();
                                    }
                                }
                            }
                        }
                    }
                }

            
                string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
                using (SqlConnection db = new SqlConnection(conStr))
                {
                    db.Open();

                    string query = @"
                SELECT SUM(TotalProduction) AS TotalProduction_Sum
                FROM [ServicesDB].[dbo].[MachinShiftPro]
                WHERE MONTH([DateTime]) = MONTH(GETDATE()) AND YEAR([DateTime]) = YEAR(GETDATE());";

                    using (SqlCommand cmd = new SqlCommand(query, db))
                    {
                        object resultObj = cmd.ExecuteScalar();
                        if (resultObj != DBNull.Value && resultObj != null)
                        {
                            int monthlyProduction = Convert.ToInt32(resultObj);
                            result["MonthlyProduction"] = monthlyProduction.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Optional: log the error
                // Example: Console.WriteLine(ex.Message);
            }

            return result;
        }
        public class ShiftProduction
        {
            public string Shift { get; set; }
            public string RunningSize { get; set; }
            public int TotalQty { get; set; }
        }

        [WebMethod]
        public static List<ShiftProduction> GetShiftProduction()
        {
            List<ShiftProduction> list = new List<ShiftProduction>();
            string conStr = System.Configuration.ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection db = new SqlConnection(conStr))
            {
                db.Open();
                string query = @"
            SELECT 
                RunningSize,
                SUM(TotalProduction) AS TotalProduction
            FROM 
                ServicesDB.dbo.MachinShiftPro
            WHERE 
                CONVERT(date, DateTime) = 
                    CASE 
                        WHEN CAST(GETDATE() AS time) < '06:30' 
                        THEN DATEADD(DAY, -1, CAST(GETDATE() AS date))
                        ELSE CAST(GETDATE() AS date)
                    END
            GROUP BY 
                RunningSize
            ORDER BY 
                RunningSize;";


                using (SqlCommand cmd = new SqlCommand(query, db))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            list.Add(new ShiftProduction
                            {
                                //Shift = reader["Shift"].ToString(),
                                RunningSize = reader["RunningSize"].ToString(),
                                TotalQty = Convert.ToInt32(reader["TotalProduction"])
                            });
                        }
                    }
                }
            }

            return list;
        }
        [WebMethod]
        public static object GetAlertMessage()
        {
            try
            {
                string filePath = path;
                    //@"D:\ModBusServices\ModBusServices\ModBusServices\bin\Debug\output.txt";

                if (!File.Exists(filePath))
                    return new { Code = 0, Message = "" };

                string[] lines = File.ReadAllLines(filePath);

                int code = 0;

                foreach (string line in lines)
                {
                    if (line.StartsWith("Call:"))
                    {
                        string callValue = line.Split(':')[1].Trim(); // "1", "2", "0", etc.
                        int.TryParse(callValue, out code); // safely convert
                        break;
                    }
                }

                string message = "";

                switch (code)
                {
                    case 1: message = "Maintenance Call"; break;
                    case 2: message = "Priventive Manintenance"; break;
                    case 3: message = "Planned Conversion"; break;
                    case 4: message = "unplanned Conversion"; break;
                    default: message = ""; break;
                }

                return new { Code = code, Message = message };
            }
            catch (Exception ex)
            {
                return new { Code = 0, Message = "Error: " + ex.Message };
            }
        }


        // Helper: Convert seconds → "X min Y sec"
        //private static string ConvertSecondsToMinutesSeconds(int totalSeconds)
        //{
        //    int minutes = totalSeconds / 60;
        //    int seconds = totalSeconds % 60;
        //    return $"{minutes} min {seconds} sec";
        //}

        private static string ConvertSecondsToMinutesSeconds(int totalSeconds)
        {
            int hours = totalSeconds / 3600;
            int minutes = (totalSeconds % 3600) / 60;
            int seconds = totalSeconds % 60;

            return $"{hours:D2}H:{minutes:D2}M:{seconds:D2}S";
        }

        //public static object GetDashboardDataFromFile()
        //{
        //    string filePath = @"D:\ModBusServices\ModBusServices\ModBusServices\bin\Debug\output.txt";
        //    var result = new Dictionary<string, int>
        //{
        //    {"Production", 0},
        //    {"RunningTime", 0},
        //    {"RunningStatus", 0},
        //    {"BDTime", 0},
        //    {"BDStatus", 0},
        //    {"StandbyTime", 0},
        //    {"StandbyStatus", 0},
        //    {"ManualTime", 0},
        //    {"ManualStatus", 0}
        //};

        //    try
        //    {
        //        if (File.Exists(filePath))
        //        {
        //            var lines = File.ReadAllLines(filePath);
        //            foreach (var line in lines)
        //            {
        //                if (string.IsNullOrWhiteSpace(line)) continue;
        //                var parts = line.Split(':');
        //                if (parts.Length == 2)
        //                {
        //                    string key = parts[0].Trim();
        //                    int value = 0;
        //                    int.TryParse(parts[1].Trim(), out value);
        //                    if (result.ContainsKey(key))
        //                    {
        //                        result[key] = value;
        //                    }
        //                }
        //            }

        //            string conStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
        //            using (SqlConnection db = new SqlConnection(conStr))
        //            { 
        //               var query = "SELECT \r\n    SUM(TotalProduction) AS TotalProduction_Sum\r\nFROM \r\n    [ServicesDB].[dbo].[ProductionTable]\r\nWHERE \r\n    MONTH([DateTime]) = MONTH(GETDATE()) AND\r\n    YEAR([DateTime]) = YEAR(GETDATE());\r\n  "




        //            }

        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        // Optional: log the error
        //    }

        //    return result;
        //}
    }
}
