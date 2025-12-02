using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;

namespace WebApplication2
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        public class LoginResult
        {
            public bool Success { get; set; }
            public string UserName { get; set; }
            public string Role { get; set; }
        }

        [WebMethod]
        public static LoginResult LoginMe(string username, string password)
        {
            LoginResult result = new LoginResult { Success = false, UserName = null, Role = null };

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // ✅ Correct query and table name
                    string query = @"
                        SELECT TOP 1 [USER_NAME], [ROLL] 
                        FROM [Authentication] 
                        WHERE [USER_NAME] = @username 
                        AND [USER_PASSCODE] = @password
                        AND ([ROLL] = 'Administrator' OR [ROLL] = 'Operator' OR [ROLL] = 'Supervisor')";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@username", username);
                        cmd.Parameters.AddWithValue("@password", password);

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                result.Success = true;
                                result.UserName = dr["USER_NAME"].ToString();
                                result.Role = dr["ROLL"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login Error: " + ex.Message);
                result.Success = false;
            }

            return result;
        }
    }
}
