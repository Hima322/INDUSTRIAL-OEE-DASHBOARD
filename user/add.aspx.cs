using DocumentFormat.OpenXml.Spreadsheet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace WebApplication2.user
{
    public partial class add : System.Web.UI.Page
    {
       // public static Cryption cryption = new Cryption();
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
        public static string ADD_USER(string userid, string roll, string username, string password)
        {
            try
            {
                // Convert userid to Int16 outside of the LINQ query
                if (!short.TryParse(userid, out short userId))
                {
                    return "Invalid User ID.";
                }

                using (Entities1 mdbEntities1 = new Entities1())
                {
                    // Check if the user already exists
                    var userAlreadyExist = mdbEntities1.Users.FirstOrDefault(i => i.ID == userId);
                    if (userAlreadyExist != null)
                    {
                        return "User ID already exists.";
                    }

                    // Create a new user object
                    User newUser = new User
                    {
                        ID = userId, // ID converted to Int16
                        UserName = username,
                        Password = password, // Assuming encryption is handled elsewhere
                        Roll = roll
                    };

                    // Add the new user to the database
                    mdbEntities1.Users.Add(newUser);
                    mdbEntities1.SaveChanges();

                    return "User added successfully.";
                }
            }
            catch (Exception ex)
            {
                // Return the exception message for debugging
                return $"Error: {ex.Message}";
            }
        }


    }
}