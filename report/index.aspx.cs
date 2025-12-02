using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

namespace WebApplication2.report
{
    public partial class Index : System.Web.UI.Page
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

        public class ModelItem
        {
             public int ID { get; set; }
            public string ModelName { get; set; }
            public string Size { get; set; }
            public string STDName { get; set; }
        }


     
        [WebMethod]
        public static object GetModels()
        {
            string runningModel = "";
            List<ModelItem> models = new List<ModelItem>();
            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // First: Load model data
                using (SqlCommand cmd = new SqlCommand("SELECT ID,Name, Size, StdName FROM ModelData", con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        models.Add(new ModelItem
                        {
                            ID = Convert.ToInt32(dr["ID"].ToString()),
                            ModelName = dr["Name"].ToString(),
                            Size = dr["Size"].ToString(),
                            STDName = dr["StdName"].ToString()
                        });
                    }
                }

                // Second: Get currently running model name
                using (SqlCommand cmd2 = new SqlCommand("SELECT VARIABLE_VALUE FROM VARIABLE WHERE VARIBALE_NAME = 'runningModel'", con))
                {
                    object result = cmd2.ExecuteScalar();
                    if (result != null)
                        runningModel = result.ToString();
                }
            }

            return new { models = models, runningModel = runningModel };
        }

        [WebMethod]
        public static void UpdateModel(int id, string newName, string newSize, string newSTDName)
        {
            if (string.IsNullOrWhiteSpace(newName) || string.IsNullOrWhiteSpace(newSize) || string.IsNullOrWhiteSpace(newSTDName))
                throw new ArgumentException("All fields are required.");

            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string query = "UPDATE ModelData SET Name=@Name, Size=@Size, STDName=@STDName WHERE ID=@ID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = newName;
                    cmd.Parameters.Add("@Size", SqlDbType.NVarChar, 50).Value = newSize;
                    cmd.Parameters.Add("@STDName", SqlDbType.NVarChar, 100).Value = newSTDName;
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;

                    int rows = cmd.ExecuteNonQuery();
                    if (rows == 0)
                        throw new Exception("No record found with the given ID.");
                }
            }
        }


        [WebMethod]
        public static void DeleteModel(int id)
        {
            try
            {
                string constr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

                using (SqlConnection con = new SqlConnection(constr))
                {
                    con.Open();
                    string query = "DELETE FROM ModelData WHERE ID = @ID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows == 0)
                        {
                            throw new Exception("No record found for deletion.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Optional: Log or rethrow for debugging
                throw new Exception("DeleteModel failed: " + ex.Message);
            }
        }


        [WebMethod]
        public static string SelectModel(string modelName, string size)
        {
            if (string.IsNullOrEmpty(modelName) || string.IsNullOrEmpty(size))
                throw new ArgumentException("ModelName and Size are required");

            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
            string stdName = "";

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // Get StdName for the selected Model + Size
                using (SqlCommand cmd = new SqlCommand("SELECT StdName FROM ModelData WHERE Name=@ModelName AND Size=@Size", con))
                {
                    cmd.Parameters.AddWithValue("@ModelName", modelName);
                    cmd.Parameters.AddWithValue("@Size", size);

                    var result = cmd.ExecuteScalar();
                    if (result != null)
                        stdName = result.ToString();
                    else
                        throw new Exception("Invalid Model or Size");
                }

                // Save StdName as RunningModel
                using (SqlCommand cmdVar = new SqlCommand(
                    "UPDATE VARIABLE SET VARIABLE_VALUE=@Value WHERE VARIBALE_NAME='RunningModel'", con))
                {
                    cmdVar.Parameters.AddWithValue("@Value", stdName);
                    cmdVar.ExecuteNonQuery();
                }

                // Save Size as RunningSize
                using (SqlCommand cmdSize = new SqlCommand(
                    "UPDATE VARIABLE SET VARIABLE_VALUE=@Value WHERE VARIBALE_NAME='RunningSize'", con))
                {
                    cmdSize.Parameters.AddWithValue("@Value", size);
                    cmdSize.ExecuteNonQuery();
                }
            }

            return stdName; // return selected StdName
        }




        [WebMethod]
        public static void AddModel(string name, string size, string stdName)
        {
            // Basic validation
            if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(size) || string.IsNullOrWhiteSpace(stdName))
                throw new ArgumentException("All fields are required.");

            string connStr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string query = "INSERT INTO ModelData (Name, Size, STDName) VALUES (@Name, @Size, @STDName)";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = name;
                    cmd.Parameters.Add("@Size", SqlDbType.NVarChar, 50).Value = size;
                    cmd.Parameters.Add("@STDName", SqlDbType.NVarChar, 100).Value = stdName;

                    cmd.ExecuteNonQuery();
                }
            }
        }

    }
}
