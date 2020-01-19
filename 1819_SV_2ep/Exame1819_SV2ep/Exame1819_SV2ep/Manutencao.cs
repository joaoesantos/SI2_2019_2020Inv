using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ex4
{
    public class Manutencao
    {
        public Veiculo V { get; set; }
        public string Matricula { get; set; }
        public int km { get; set; }
        public Decimal valorTotal { get; set; }
        public DateTime data { get; set; }
        public List<ManutencaoItem> Itens { get; set; }
    }
}
