using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Net.NetworkInformation;
using System.Net;
using System.Threading;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using S7.Net;
using S7.Net.Types;
using System.Text.Json;
using System.Security.Cryptography;
using System.Text; 
using WebApplication2.other;
using System.Net.Sockets;

namespace WebApplication2.monitor
{
    public partial class index : System.Web.UI.Page
    {
        public static string plcIpAddress = "";
        public static string printer1IpAddress = "";
        public static string printer2IpAddress = ""; 
        public static string reworkDctoolIpAddress = ""; 

        static Plc plc;
        public static string pwd = "";
        public static string seftyTitle = "";
        public static Cryption cryption = new Cryption(); 

        protected void Page_Load(object sender, EventArgs e)
        {
            PAGE_LOAD_FUNCTION();
        }


        [WebMethod]
        public static void PAGE_LOAD_FUNCTION()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //this code for get admin password 
                    var res = db.USERs.Where(i => i.Roll == "Admin").FirstOrDefault();
                    if (res != null)
                    {
                        pwd = res.Password;
                    }
                    //this code for plc ip address fetching 
                    var plcIpRes = db.VarTables.Where(i => i.VarName == "PlcIp").FirstOrDefault();
                    {
                        if (plcIpRes != null)
                            plcIpAddress = plcIpRes.VarValue;
                    }
                    //this code for printer1 ip address fetching 
                    var printer1IpRes = db.VarTables.Where(i => i.VarName == "PrinterIp").FirstOrDefault();
                    if (printer1IpRes != null)
                    {
                        printer1IpAddress = printer1IpRes.VarValue;
                    }
                    //this code for printer2 ip address fetching 
                    var printer2IpRes = db.VarTables.Where(i => i.VarName == "FinelPrinterIp").FirstOrDefault();
                    if (printer2IpRes != null)
                    {
                        printer2IpAddress = printer2IpRes.VarValue;
                    }
                    //this code for printer2 ip address fetching 
                    var reworkDctoolIpAddressRes = db.VarTables.Where(i => i.VarName == "ReworkDcTooIP").FirstOrDefault();
                    if (reworkDctoolIpAddressRes != null)
                    {
                        reworkDctoolIpAddress = reworkDctoolIpAddressRes.VarValue;
                    }
                    //this code for printer2 ip address fetching 
                    var seftyLineRes = db.VarTables.Where(i => i.VarName == "SeftyLine").FirstOrDefault();
                    if (seftyLineRes != null)
                    {
                        seftyTitle = seftyLineRes.VarValue;
                    }
                }
            }
            catch { Console.Write("Error."); }

            plc = new Plc(CpuType.S71500, plcIpAddress, 0, 0);
        }

        [WebMethod]
        public static bool IS_PLC_CONNECTED()
        { 
                try
                { 
                    Ping p1 = new Ping();
                    PingReply PR = p1.Send(plcIpAddress);

                    // check after the ping is n success
                    if (PR.Status.ToString() != "Success")
                    {
                        return false;
                    }
                    else
                    {
                        if (plc.IsConnected == false)
                        {
                            if (plc.Open() == ErrorCode.NoError)
                            {
                                return true;
                            }
                            else
                            {
                                return false;
                            }
                        }
                        else
                        {
                            return true;
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    return false;
                }
            }

        [WebMethod]  
        public static string GET_DCTOOL_LIST()
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.STD_TorqueTable.ToList();
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
        public static string STATION_ASSIGNMENTS()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.PLCAddressLists.Where(i => i.ID == 1).FirstOrDefault();
                    if (res != null)
                    {
                        return JsonSerializer.Serialize(res);
                    }

                    return "Error";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
        }
         
        [WebMethod]
        public static string GET_SHIFT_SETTING()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.ShiftSettings.ToList();
                    if (res != null)
                    {
                        return JsonSerializer.Serialize(res);
                    }

                    return "Error";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
        }
         
        [WebMethod]
        public static string STATION_NAME()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.StationAssignments.ToList();
                    if (res != null)
                    {
                        return JsonSerializer.Serialize(res);
                    }

                    return "Error";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
        }

        [WebMethod]
        public static string GET_PLC_TAG_NAME()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    int[] plcTagIds = {2,3,4,5,6,7,8 };
                    var res = db.PLCAddressLists.Where(i => plcTagIds.Contains(i.ID)).ToList();
                    if (res != null)
                    {
                        return JsonSerializer.Serialize(res);
                    }

                    return "Error";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return "Error";
            }
        }

        [WebMethod]
        public static string UPDATE_STATION_POSITION( string Operator, string CurrentST, string PrevST)
        {
            try
            {
                using(TMdbEntities  db = new TMdbEntities())
                {
                    string currentRes = "update PLCAddressList set " + CurrentST + " = '"+Operator+"' where ID = '1' ";
                    string preRes = "update PLCAddressList set " + PrevST + " = '' where ID = '1' ";
                    db.Database.ExecuteSqlCommand(currentRes);
                    db.SaveChanges();
                    db.Database.ExecuteSqlCommand(preRes);
                    db.SaveChanges();
                    return "Done";
                } 
            } catch (Exception ex)
            {
                return ex.Message;
            }
        }
        
        [WebMethod]
        public static string UPDATE_SHIFT_SETTING_TIMING( int id, TimeSpan value, string time)
       {
            try
            {
                using(TMdbEntities  db = new TMdbEntities())
                { 
                    var res = db.ShiftSettings.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        if(time == "StartTime")
                        {
                            res.StartTime = value;
                        }
                        else if(time == "EndTime")
                        {
                            res.EndTime = value;
                        }
                        db.SaveChanges(); 
                        return "Done";
                    }
                } 
            } catch (Exception ex)
            {
                return ex.Message;
            }
            return "Something went wrong.";
        }
        
        [WebMethod]
        public static string UPDATE_PLCTAG_NAME( int id, string station, string value)
        {
            try
            {
                using(TMdbEntities  db = new TMdbEntities())
                {
                    string qry = "update PLCAddressList set " + station + " = '"+value+"' where ID = '"+id+"' "; 
                    db.Database.ExecuteSqlCommand(qry);
                    db.SaveChanges(); 
                    return "Done";
                } 
            } catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string UPDATE_STATION_NAME( int id, string value)
        {
            try
            {
                using(TMdbEntities  db = new TMdbEntities())
                {
                    var res = db.StationAssignments.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        res.Station_Name = value;
                    }

                    db.SaveChanges();
                    return "Done";
                } 
            } catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string UPDATE_DCTOOL_IPADDRESS(int id, string value)
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.STD_TorqueTable.Where(i => i.ID == id).FirstOrDefault();
                    if(res != null)
                    {
                        res.TorqueToolIPAddress = value;
                        db.SaveChanges();
                        return "Done";
                    }
                }
            } catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return ex.Message;
            }
            return "Something went wrong.";
        }
        
        [WebMethod]
        public static string UPDATE_IPADDRESS(string key, string value)
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.VarTables.Where(i => i.VarName == key).FirstOrDefault();
                    if(res != null)
                    {
                        res.VarValue = value;
                        db.SaveChanges();
                        return "Done";
                    }
                }
            } catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return ex.Message;
            }
            return "Something went wrong";
        }
        
        [WebMethod]
        public static string UPDATE_SEFTYLINE(string value)
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.VarTables.Where(i => i.VarName == "SeftyLine").FirstOrDefault();
                    if(res != null)
                    {
                        res.VarValue = value;
                        db.SaveChanges();
                        return "Done";
                    }
                }
            } catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return ex.Message;
            }
            return "Something went wrong";
        }

        [WebMethod]
        public static string READ_PLCTAG(string tag)
        {
            try
            {
                if (IS_PLC_CONNECTED())
                {
                    return "Tag value : " + plc.Read(tag).ToString();
                }
                else
                {
                    return "Plc not connected";
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
         

    }

}