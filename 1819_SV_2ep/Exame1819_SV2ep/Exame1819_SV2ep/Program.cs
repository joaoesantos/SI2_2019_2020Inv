using System.Collections.Generic;

namespace Ex4
{
    class Program
    {
        static void Main(string[] args)
        {
            Manutencao manutencao = new Manutencao();
            manutencao.Matricula = "xpto";

            List<ManutencaoItem> lista = new List<ManutencaoItem>();
            ManutencaoItem mi1 = new ManutencaoItem();
            mi1.km = 300;
            mi1.NLinha = 3;
            mi1.Valor = 55.03M;

            lista.Add(mi1);

            ManutencaoItem mi2 = new ManutencaoItem();
            mi2.km = 400;
            mi2.NLinha = 4;
            mi2.Valor = 55M;

            lista.Add(mi2);

            manutencao.Itens = lista;
            manutencao.km = 450;

            ManutencaoMapper mapper = new ManutencaoMapper();
            mapper.InsereManutencao(manutencao);
        }
    }
}
