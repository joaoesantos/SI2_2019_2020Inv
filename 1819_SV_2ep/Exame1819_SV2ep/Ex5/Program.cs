using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ex5
{
    class Program
    {
        static void Main(string[] args)
        {
           

            //using (var ctx = new Exame1819SV2epEntities())
            //{
            //    Console.WriteLine("5.a");
            //    IEnumerable<manutencaoItem> lista1 = ctx.manutencaoItems
            //        .Where(x => x.matricula.Equals("00-ZZ-00") && x.km == 50000 && x.valor >= 90).AsEnumerable();

            //    foreach (var mi in lista1)
            //    {
            //        Console.WriteLine($"[{mi.nLinha}] - Matricula{mi.matricula}, valor:{mi.valor}");
            //        Console.WriteLine(Environment.NewLine);
            //    }
            //}
            using (var ts = new TransactionScope()) {
                using (var ctx = new Exame1819SV2epEntities()) {
                    Console.WriteLine("5.b");
                    veiculo v = ctx.veiculoes.First(x => x.matricula.Equals("00-ZZ-00"));

                    if (v != null)
                    {
                        v.kmActuais = 10000;
                        ctx.SaveChanges();
                    }
                    else
                    {
                        Console.WriteLine("Veiculo não encontrado");
                    }
                }
                ts.complete();
            }

           

            Console.ReadKey();
        }
    }
}
