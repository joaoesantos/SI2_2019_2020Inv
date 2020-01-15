// SI2_1819_SV_1ep
// 5

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Transactions;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;


public class Ex5 {
    public bool Transferir(int contaDebitar, int contaCreditar, decimal montante) {
        bool res = false;
        using (var ts = new TransactionScope())
        {
            res = Debitar(contaDebitar, montante)
            if(res){
                res &= Creditar(contaCreditar, montante);
            }
            ts.Complete();
        }
        return res;
    }

    private bool Debitar(int contaID, decimal montante) {
        
        using (var ts = new TransactionScope(TransactionScopeOption.Required)) {
            IContaMapper contas = new ContaMapper();
            Conta conta = contas.Get(contaID);

            if(conta == null){
                return false;
            }

            if(conta.Saldo < montante){
                return false;
            }

            conta.Saldo -= montante;

            contas.Update(conta);

            ts.Complete()
            return true;
        }
    }

    private bool Creditar(int contaID, decimal montante) {
        using (var ts = new TransactionScope(TransactionScopeOption.Required)){
            IContaMapper contas = new ContaMapper();
            Conta conta = contas.Get(contaID);

            if(conta == null){
                return false;
            }

            conta.Saldo += montante;
            contas.Update(conta);

            ts.Complete();
            return true;
        }
    }
}