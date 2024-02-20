using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication2.order
{
    public partial class index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string MODEL_DETAILS()
        {
            try
            {
                using(TMdbEntities db = new TMdbEntities())
                {
                    var res = db.MODEL_DEATILS.ToList();
                    return JsonSerializer.Serialize(res);
                }
            } catch {
                return "Error";
            }
        }
        
        [WebMethod]
        public static string REMAIN_SEAT()
        {
            try
            {
                using (TMdbEntities db = new TMdbEntities())
                {
                    var res = db.SEAT_DATA.Where(i => i.STAUS == null).ToList();
                    return JsonSerializer.Serialize(res);
                }
            } catch {
                return "Error";
            }
        }

        [WebMethod]
        public static string ADD_BULK_DATA(string type, string model, string variant, string driver_fgpart, string co_driver_fgpart, int quantity,string modelVariant)
        {
            try
            {

                using(TMdbEntities db = new TMdbEntities())
                {
                    int lastSeq = 0;
                    var seatDataRes = db.SEAT_DATA.OrderByDescending(x => x.ID).FirstOrDefault();
                    if (seatDataRes != null)
                    {
                        lastSeq = (int)seatDataRes.SequenceNo;  
                    }

                    for (var i = 1; i <= quantity; i++)
                    {
                        lastSeq += 1;
                        if (lastSeq > 99999) { lastSeq = 1; }
                        if (type == "SET" || type == "DRIVER")
                        {
                            SEAT_DATA driver_seat_data = new SEAT_DATA
                            {
                                SequenceNo = lastSeq,
                                Model = model,
                                Variant = variant,
                                SeatType = "DRIVER",
                                StationNo = 0,
                                ModelVariant = modelVariant,
                                FG_PartNumber = driver_fgpart
                            };
                            db.SEAT_DATA.Add(driver_seat_data);
                        }
                        if (type == "SET" || type == "CO-DRIVER")
                        {
                            SEAT_DATA co_driver_seat_data = new SEAT_DATA
                            {
                                SequenceNo = lastSeq,
                                Model = model,
                                Variant = variant,
                                SeatType = "CO-DRIVER",
                                ModelVariant = modelVariant,
                                StationNo = 0,
                                FG_PartNumber = co_driver_fgpart
                            };
                            db.SEAT_DATA.Add(co_driver_seat_data);
                        }
                    }
                        db.SaveChanges(); 


                    return "Done";

                }
            } catch (Exception ex) { 
                return ex.Message;
            }  
        }
    }
}