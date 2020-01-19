using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Configuration;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;
namespace Ex4
{
    public class ManutencaoMapper
    {
        public void InsereManutencao(Manutencao m)
        {
            using (var ts = new TransactionScope())
            {
                using (var connection = new SqlConnection(DBHelper.DbString))
                {
                    connection.Open();

                    SqlCommand command = connection.CreateCommand();
                    command.CommandType = CommandType.Text;
                    command.CommandText = "SELECT matricula FROM Veiculo WHERE matricula = @matricula";
                    command.Parameters.AddWithValue("@matricula", m.Matricula);
                    SqlDataReader dataReader = command.ExecuteReader();

                    if (dataReader.Read())
                    {
                        dataReader.Close();
                        foreach (var mi in m.Itens)
                        {
                            SqlCommand insertCommand = connection.CreateCommand();
                            insertCommand.CommandType = CommandType.StoredProcedure;
                            insertCommand.CommandText = "insereManutencaoItem";
                            insertCommand.Parameters.AddWithValue("@mat", m.Matricula);
                            insertCommand.Parameters.AddWithValue("@km", mi.km);
                            insertCommand.Parameters.AddWithValue("@linha", mi.NLinha);
                            insertCommand.Parameters.AddWithValue("@valor", mi.Valor);

                            insertCommand.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        throw new Exception("Veiculo não encontrado");

                    }
                }
                ts.Complete();
            }
        }
    }
}
