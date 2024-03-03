using S7.Net;
using System;
using System.Collections;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text.Json;
using System.Web.Services;  

namespace WebApplication2.andon
{
    public partial class Index : System.Web.UI.Page
    { 

        public static string plcIpAddress = "";
        private static Plc plc;

        protected void Page_Load(object sender, EventArgs e)
        {

            PAGE_LOAD_FUNCTION();
        } 
        public static void PAGE_LOAD_FUNCTION()
        {
            GET_PLCIP_ADDRESS();
            plc = new Plc(CpuType.S71500, plcIpAddress, 0, 0); 
        }

        public static void GET_PLCIP_ADDRESS()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    //this code for plc ip address fetching 
                    var plcIpRes = db.VarTables.Where(i => i.VarName == "PlcIp").FirstOrDefault();
                    {
                        if (plcIpRes != null)
                            plcIpAddress = plcIpRes.VarValue;
                    }
                }
            }
            catch { }
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
                    if (!plc.IsConnected)
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
        public static string GetCurrentAnonScreen()
        {
            try
            {
                using (TMdbEntities entity = new TMdbEntities())
                {
                    var res = entity.VarTables.Where(i => i.VarName == "CurrentAndonScreen").FirstOrDefault();
                    if (res != null)
                    {
                        return res.VarValue;
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


        public static bool delayEntry = true;

        [WebMethod]
        public static void INSERT_DELAY_IN_DATABASE()
        {
            if (delayEntry)
            {
                delayEntry = false;
                if (IS_PLC_CONNECTED())
                {
                    try
                    {
                        using (TMdbEntities entity = new TMdbEntities())
                        {
                            var indexBit = entity.PLCAddressLists.Where(i => i.PLCTagName == "IndexBit").FirstOrDefault();
                            var mntcDelay = entity.PLCAddressLists.Where(i => i.PLCTagName == "MaintenanceDelay").FirstOrDefault();
                            var optDelay = entity.PLCAddressLists.Where(i => i.PLCTagName == "OperatrorDelay").FirstOrDefault();
                            var qtyDelay = entity.PLCAddressLists.Where(i => i.PLCTagName == "QualityDelay").FirstOrDefault();
                            var mtlDelay = entity.PLCAddressLists.Where(i => i.PLCTagName == "MaterialDelay").FirstOrDefault();

                            string[] indexBitTagArr = { indexBit.Station1, indexBit.Station2, indexBit.Station3, indexBit.Station4, indexBit.Station5, indexBit.Station6, indexBit.Station7, indexBit.Station8, indexBit.Station9, indexBit.Station10, indexBit.Station11, indexBit.Station12, indexBit.Station13, indexBit.Station14, indexBit.Station15, indexBit.Station16, indexBit.Station17, indexBit.Station18, indexBit.Station19, indexBit.Station20, indexBit.Station21, indexBit.Station22, indexBit.Station23, indexBit.Station24, indexBit.Station25 };
                            string[] maintenanceDelayTagArr = { mntcDelay.Station1, mntcDelay.Station2, mntcDelay.Station3, mntcDelay.Station4, mntcDelay.Station5, mntcDelay.Station6, mntcDelay.Station7, mntcDelay.Station8, mntcDelay.Station9, mntcDelay.Station10, mntcDelay.Station11, mntcDelay.Station12, mntcDelay.Station13, mntcDelay.Station14, mntcDelay.Station15, mntcDelay.Station16, mntcDelay.Station17, mntcDelay.Station18, mntcDelay.Station19, mntcDelay.Station20, mntcDelay.Station21, mntcDelay.Station22, mntcDelay.Station23, mntcDelay.Station24, mntcDelay.Station25 };
                            string[] optDelayTagArr = { optDelay.Station1, optDelay.Station2, optDelay.Station3, optDelay.Station4, optDelay.Station5, optDelay.Station6, optDelay.Station7, optDelay.Station8, optDelay.Station9, optDelay.Station10, optDelay.Station11, optDelay.Station12, optDelay.Station13, optDelay.Station14, optDelay.Station15, optDelay.Station16, optDelay.Station17, optDelay.Station18, optDelay.Station19, optDelay.Station20, optDelay.Station21, optDelay.Station22, optDelay.Station23, optDelay.Station24, optDelay.Station25 };
                            string[] qualityDelayTagArr = { qtyDelay.Station1, qtyDelay.Station2, qtyDelay.Station3, qtyDelay.Station4, qtyDelay.Station5, qtyDelay.Station6, qtyDelay.Station7, qtyDelay.Station8, qtyDelay.Station9, qtyDelay.Station10, qtyDelay.Station11, qtyDelay.Station12, qtyDelay.Station13, qtyDelay.Station14, qtyDelay.Station15, qtyDelay.Station16, qtyDelay.Station17, qtyDelay.Station18, qtyDelay.Station19, qtyDelay.Station20, qtyDelay.Station21, qtyDelay.Station22, qtyDelay.Station23, qtyDelay.Station24, qtyDelay.Station25 };
                            string[] materialDelayTagArr = { mtlDelay.Station1, mtlDelay.Station2, mtlDelay.Station3, mtlDelay.Station4, mtlDelay.Station5, mtlDelay.Station6, mtlDelay.Station7, mtlDelay.Station8, mtlDelay.Station9, mtlDelay.Station10, mtlDelay.Station11, mtlDelay.Station12, mtlDelay.Station13, mtlDelay.Station14, mtlDelay.Station15, mtlDelay.Station16, mtlDelay.Station17, mtlDelay.Station18, mtlDelay.Station19, mtlDelay.Station20, mtlDelay.Station21, mtlDelay.Station22, mtlDelay.Station23, mtlDelay.Station24, mtlDelay.Station25 };

                            int[] maintenanceRegisterValueArr = { };
                            int[] operatoregisterValueArr = { };
                            int[] qualityRegisterValueArr = { };
                            int[] materialRegisterValueArr = { };

                            for (int i = 1; i < 26; i++)
                            {
                                maintenanceRegisterValueArr.Append(Convert.ToUInt16(plc.Read(maintenanceDelayTagArr[i])));
                                operatoregisterValueArr.Append(Convert.ToUInt16(plc.Read(optDelayTagArr[i])));
                                qualityRegisterValueArr.Append(Convert.ToUInt16(plc.Read(qualityDelayTagArr[i])));
                                materialRegisterValueArr.Append(Convert.ToUInt16(plc.Read(materialDelayTagArr[i])));

                                if ((bool)plc.Read(indexBitTagArr[i]))
                                {
                                    if (maintenanceRegisterValueArr[i] > 0)
                                    {
                                        ADD_DELAY_RECORD("MaintenanceDelay", maintenanceRegisterValueArr[i], i.ToString());
                                    }
                                    if (operatoregisterValueArr[i] > 0)
                                    {
                                        ADD_DELAY_RECORD("OperatrorDelay", operatoregisterValueArr[i], i.ToString());
                                    }
                                    if (qualityRegisterValueArr[i] > 0)
                                    {
                                        ADD_DELAY_RECORD("QualityDelay", qualityRegisterValueArr[i], i.ToString());
                                    }
                                    if (materialRegisterValueArr[i] > 0)
                                    {
                                        ADD_DELAY_RECORD("MaterialDelay", materialRegisterValueArr[i], i.ToString());
                                    }

                                    plc.Write(indexBitTagArr[i], false);
                                }
                            }

                            delayEntry = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.ToString());
                        delayEntry = true;
                    }
                }
            }
        }

        [WebMethod]
        public static void ADD_DELAY_RECORD(string delayType, int delaySecond, string station)
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    DelayRecord delayRecord = new DelayRecord()
                    {
                        DelayType = delayType,
                        DelaySecond = delaySecond,
                        DelayTime = DateTime.Now,
                        StationNo = station
                    };
                    db.DelayRecords.Add(delayRecord);
                }
            } catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

    }
}