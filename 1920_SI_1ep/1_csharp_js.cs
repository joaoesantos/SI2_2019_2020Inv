//1.d
public interface IContaSingular
{
    int KeyCol{
        get;
        set;
    }

    char Tipo{
        get;
        set;
    }

    int Num_bi{
        get;
        set;
    }
    Titular TitularPrincipal {
        get;
    }
}

//1.e
public class ContaSingular : IContaSingular{
    private int _keyCol;
    private char _tipo;
    private int _num_bi;

    public int KeyCol{
        get => _name;
        set => _name = value;
    }

    public char Tipo{
        get => _char;
        set => _char = value
    }

    public int Num_bi {
        get => _num_bi;
        set => _num_bi = value;
    }

    public Titular TitularPrincipal{
        get {
            TitularMapper mapper = new TitularMapper(ConnectionString);
            return mapper.Read(_num_bi);
        }
    }
}

//1.f
public class ContaSingularMapper {
    private string _connectionString;

    public ContaSingularMapper(string connectionString){
        _connectionString = connectionString;
    }

    public ContaSingular Read(int id) {
        ContaSingular res = new ContaSingular();
        using(var ts = new TransactionScope()){
            using(var conn = new SqlConnection(_connectionString) ){
                conn.Open();

                SqlCommand command = conn.CreateCommnad();
                command.Text = "SELECT keyCol, 'S', num_bi from t_contaSingular where keycol = @id";
                command.CommandType = CommmandType.Text;
                command.AddWithValue("@id", id):

                using(var reader = command.ExecuteReader()){
                    if(reader.Read()){
                        res.KeyCol = id;
                        res.Tipo = reader.GetChar(1);
                        res.Num_bi = reader.GetInt64 (2);
                    }
                    else{
                        throw new InvalidArgumentException("Conta nao encontrada");
                    }
                }
            }
            ts.Complete();
        }
        return res;
    }
}