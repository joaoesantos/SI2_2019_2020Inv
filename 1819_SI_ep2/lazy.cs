public class Medico{
    public Medico() {...}
    public int Nome { get; set; }
    public string Genero { get; set; }
    public string Especialidade { get; set; }

    public List<Consulta> consultasDadas { 
        get
        {
            List<Consulta> temp = new List<Consulta>();
            using(var ts = new TransactionScope()){
                using(var conn = new SqlConnection(ConnectionString)){
                    conn.Open();
                    SqlCommand command = conn.CreateCommand();
                    command.CommandType = CommandType.Text;
                    command.Text = "Select NumCons, codMed, NomePaciente, Data" +
                                    "FROM CONSULTA" + 
                                    "INNER JOIN Medico on Medico.CodMed = Consulta.CodMed" + 
                                    "Where Medico.Nome = @Nome";
                    command.Parameters.AddWithValue("@Nome", Nome);
                    using(var reader = command.ExecuteReader()){
                        while (reader.Read())
                        {
                            temp.Add(new Consulta());
                        }
                    }
                }
                ts.Complete();
            }
            return temp;
        } 
        set
        {
            _consultasDadas = value;
        } 
    }
}

public class Consulta {
public Consulta() {...}
public int NumConsulta { get; set; }
public int CodMed { get; set; }
public string NomePaciente { get; set; }
public string Data { get; set; }
}