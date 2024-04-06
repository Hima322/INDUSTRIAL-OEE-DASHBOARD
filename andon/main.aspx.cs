using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Timers;
using System.Web.Services.Description;
using System.Web.UI.WebControls;
using System.Threading;
using System.Web.Services;
using System.Web;
using System.Text.Json;
using System.Runtime.InteropServices;


namespace WebApplication2.andon
{
    public partial class Main : System.Web.UI.Page
    { 
         
        public void Page_Load(object sender, EventArgs e)
        {   
        }

        [WebMethod]
        public static string GetAllAndonDetails()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.Andons.ToList();
                    return JsonSerializer.Serialize(res);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
        } 
         
        [WebMethod]
        public static string GetTotalBreak()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.ShiftSettings.Where(i => i.ID > 3).ToList(); 
                    if (res.Count > 0)
                    {
                      var lst =  res.Where(o => o.StartTime < DateTime.Now.TimeOfDay && o.StartTime > DateTime.Today.TimeOfDay && o.EndTime < DateTime.Now.TimeOfDay && o.EndTime > DateTime.Today.TimeOfDay).ToList();

                        return JsonSerializer.Serialize(lst);
                    }
                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
            return "Error";
        }
         
        [WebMethod]
        public static string GetTotalDelay()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.DelayRecords.Where(i => i.DelayTime > DateTime.Today).ToList();

                    if (res.Count > 0)
                    { 
                        return JsonSerializer.Serialize(res);
                    }
                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
            return "Error";
        }
         
        [WebMethod]
        public static string GET_UPCOMMING_SEAT()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.SEAT_DATA.Where(i => i.StationNo == 0).Take(6).ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GET_TODAY_REJECTED_SEAT()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.SEAT_DATA.Where(i => i.STAUS == "REJECT" && i.FinalPrintDateTime > DateTime.Today).Select(s => new {s.ID}).ToList();
                    if (res.Count > 0)
                    {
                        return JsonSerializer.Serialize(res);
                    }
                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
            return "Error";
        }
        
        [WebMethod]
        public static string GetSeaftyLine()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {   
                    var res = entity.VarTables.Where(i => i.VarName == "SeftyLine").FirstOrDefault(); 
                    return res.VarValue;

                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
        }
        
        [WebMethod]
        public static string GetShift(string cs)
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var varRes = entity.VarTables.Where(i => i.VarName == "Shift").FirstOrDefault();
                    if(varRes != null) { varRes.VarValue = cs; entity.SaveChanges(); }
                    var res = entity.Andons.Where(i => i.ShiftName == cs).ToList();
                    return JsonSerializer.Serialize(res);
                }
            } catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return "Error";
            }
        }

        [WebMethod]
        public static string GetCurrentShiftName()
        {
            try
            {
                var cs = "";

                using (TMdbEntities db = new TMdbEntities())
                {

                    //fetch data from shiftsetting table 
                    var shiftRes = db.ShiftSettings.ToList();
                    TimeSpan H = TimeSpan.FromHours(8);
                    //check condition for current shift 
                    foreach (var item in shiftRes)
                    {

                        if (item.ID < 4)
                        {
                            if (cs == "")
                            {
                                DateTime StartTime = DateTime.ParseExact(DateTime.Now.ToString("dd-MM-yyyy") + " " + item.StartTime, "dd-MM-yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                                DateTime EndTime = StartTime.AddHours(8);
                                int Result1 = DateTime.Compare(DateTime.Now, StartTime);
                                int Result2 = DateTime.Compare(EndTime, DateTime.Now);
                                if (Result1 == 1 && Result2 == 1)
                                {
                                    cs = item.ShiftName;
                                }
                            }
                        }
                        else
                        {
                            if (cs == "")
                            {
                                cs = "C";
                            }
                            if (DateTime.Now.TimeOfDay >= item.StartTime && DateTime.Now.TimeOfDay < item.EndTime)
                            {
                                cs = item.ShiftName;
                            }
                        }
                    }
                } 
                return cs;

                } catch (Exception e)
                {
                   Console.WriteLine(e.Message);
                    return ""; 
                }
            }


        [WebMethod]
        public static int GetCurrentShiftRowId()
        {
            try
            {
                int ID = 0;
                using (TMdbEntities db = new TMdbEntities())
                {
                    var andonRes = db.Andons.ToList();
                    foreach (var item in andonRes)
                    {
                        DateTime start = Convert.ToDateTime(item.HourName.Split('-')[0]);
                        DateTime end = Convert.ToDateTime(item.HourName.Split('-')[1]);

                        if (start < end)
                        {
                            if (DateTime.Now >= start && DateTime.Now <= end)
                            {
                                ID =  item.ID;
                                break;
                            }
                         }
                        else { ID = 18; }
                    }
                    return ID;
                }
            }
            catch 
            {
                return 0;
            } 
        }


    }
}
