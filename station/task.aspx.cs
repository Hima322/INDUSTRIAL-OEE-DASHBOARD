using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.station
{
    public partial class Task : System.Web.UI.Page
    {
        public string pwd = "";

        protected void Page_Load(object sender, EventArgs e)
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
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

        }


        [WebMethod]
        public static string GET_STATION_LIST()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.TaskListTables.ToList();
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
        public static string GET_MODEL_DETAIL()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.MODEL_DEATILS.ToList();
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
        public static string UPDATE_TASKLIST_TABLE(int id, string colName, string val)
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.TaskListTables.Where(i => i.ID == id).FirstOrDefault();
                    if (res != null)
                    {
                        switch (colName)
                        {
                            case "TaskName":
                                if (val == "SCAN")
                                {
                                    res.TaskType = "Scan";
                                }
                                else if (val == "")
                                {
                                    res.TaskType = "";
                                }
                                else
                                {
                                    res.TaskType = "Torque";
                                }
                                res.TaskName = val;
                                break;
                            case "BomSeq": res.BomSeq = val; break;
                            case "ModelVariant1": res.ModelVariant1 = val; break;
                            case "ModelVariant2": res.ModelVariant2 = val; break;
                            case "ModelVariant3": res.ModelVariant3 = val; break;
                            case "ModelVariant4": res.ModelVariant4 = val; break;
                            case "ModelVariant5": res.ModelVariant5 = val; break;
                            case "ModelVariant6": res.ModelVariant6 = val; break;
                            case "ModelVariant7": res.ModelVariant7 = val; break;
                            case "ModelVariant8": res.ModelVariant8 = val; break;
                            case "ModelVariant9": res.ModelVariant9 = val; break;
                            case "ModelVariant10": res.ModelVariant10 = val; break;
                            case "ModelVariant11": res.ModelVariant11 = val; break;
                            case "ModelVariant12": res.ModelVariant12 = val; break;
                            case "ModelVariant13": res.ModelVariant13 = val; break;
                            case "ModelVariant14": res.ModelVariant14 = val; break;
                            case "ModelVariant15": res.ModelVariant15 = val; break;
                            case "ModelVariant16": res.ModelVariant16 = val; break;
                            case "ModelVariant17": res.ModelVariant17 = val; break;
                            case "ModelVariant18": res.ModelVariant18 = val; break;
                            case "ModelVariant19": res.ModelVariant19 = val; break;
                            case "ModelVariant20": res.ModelVariant20 = val; break;
                            case "ModelVariant21": res.ModelVariant21 = val; break;
                            case "ModelVariant22": res.ModelVariant22 = val; break;
                            case "ModelVariant23": res.ModelVariant23 = val; break;
                            case "ModelVariant24": res.ModelVariant24 = val; break;
                            case "ModelVariant25": res.ModelVariant25 = val; break;
                            case "ModelVariant26": res.ModelVariant26 = val; break;
                            case "ModelVariant27": res.ModelVariant27 = val; break;
                            case "ModelVariant28": res.ModelVariant28 = val; break;
                            case "ModelVariant29": res.ModelVariant29 = val; break;
                            case "ModelVariant30": res.ModelVariant30 = val; break;
                        }
                        db.SaveChanges();
                        return "Done";
                    }
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return ex.Message;
            }
            return "Something went wrong.";
        }

    }
}