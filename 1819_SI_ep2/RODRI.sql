--1.a)
create trigger receita_trg on receita instead of insert
as
begin
    begin tran
        declare @NumCons int
        declare @NumF int
        declare @quantidade int
        declare @stock int
        declare cursor curs from select NumCons, NumF, quantidade from inserted
    	FETCH NEXT FROM curs into @NumCons,@NumF,@quantidade
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            IF(EXISTS(select Stock from Farmaco where NumF = @NumF) AND
            EXISTS(select NumCons from Consulta where NumCons = @NumCons))
            begin
                select @stock = Stock from Farmaco where NumF = @NumF
                IF(stock>= quantidade)
                begin
                    insert into receita (NumCons, NumF, quantidade)
                    VALUES (@NumCons,@NumF,@quantidade)

                    Update Farmaco
                    Set Stock = @stock-@quantidade
                    Where NumF = @NumF
                end
                else
                begin
                    print 'nao ha stock para isso'
                end
            end
            else
            begin
                print 'nao exsite o medicamento ou nao existe consulta'
            end
            
            FETCH NEXT FROM curs into @NumCons,@NumF,@quantidade
        END;
        
    commit
end

--1.b.i)
create trigger apagar_consultas_trg on Medico instead of delete
as
begin
    begin tran
        declare @codMed int
        declare @numCons int
        declare cursor curs from select codMed from deleted
        FETCH NEXT FROM curs into @codMed
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            declare cursor curs2 from select numCons from consulta WHERE CodMed = @CodMed
            FETCH NEXT FROM curs2 into @numCons
            WHILE (@@FETCH_STATUS = 0)
            BEGIN
                delete from consulta where numCons = @numCons
                FETCH NEXT FROM curs2 into @numCons
            END
            CLOSE curs2 ;
            DEALLOCATE curs2;

            DELETE FROM Medico WHERE CodMed = @codMed

            FETCH NEXT FROM curs into @codMed
        END
        CLOSE curs ;
        DEALLOCATE curs;
    commit
end

--1.b.ii)
create trigger apagar_consultas_trg on Medico after insert
as
begin
    begin tran
        declare @codMed int
        declare cursor curs from select codMed from deleted
        FETCH NEXT FROM curs into @codMed
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            delete from consulta where codMed = @codMed
            FETCH NEXT FROM curs into @codMed
        END
    commit
end

--1.b.iii)
--é o que nao tem o cursor sobre a tabela da consulta, é mais eficiente deixa o SGBD fazer a query e apagar
--todos os registos que façam match com a query do que itera-los no codigo e apagalos indevidualmente, iosto requer mais operações


--1.c) ver o do quintela
create function top_MedicosPorFarmaco(@NumF int) returns @medicos Table(nome varchar(100), quant int)
as
begin
    declare cursor @curs for (Select TOP 10 quantidade
    from Receita
    where NumF = @NumF
    order by desc quantidade)

    declare @quantidade int
    declare @NumCons int
    declare @nome varchar(100)

    FETCH NEXT FROM curs INTO @quantidade, @NumCons
	WHILE @@FETCH_STATUS = 0
	BEGIN
        select @nome=med.nome
        from consulta inner join medico as med on consulta.codMed=med.CodMed
        where consulta.NumCons = @NumCons

		insert into @medicos (nome, quant)
        VALUES (, @quantidade)
        FETCH NEXT FROM curs INTO @quantidade
	end

end
--1.d)
CREATE VIEW view_name AS
    (select *
    from Farmaco
    where Stock = 0 and NumF not in (select NumF from receita) 

--1.e)
--Com virtual proxy a vida do programador fica facilitada, na medida em que alterações do modelo sao automaticament tracked pelo proxy.
--Uma vez feitas as alterações tambem é o proxy que faz as operações diretamente a base de dados, tendo o porgramador de tratar erros
--caso aconteçao.
--Além disso permite tecnoicas de lazy loading que têm vantagens a nivel de performance.

--1.f)
public void carregConsultasMed(Medico med, List<Consulta> cons){
    using(var ctx = new Entities()) {
        ctx.Medicos.first(m => m.nome = med.nome) //assumindo que nome é id unico
        .consultasDadas.AddRange(cons.Select(c => {
            CONTULTA con = ctx.Consultas.create();
            con.NumConsulta = c.NumConsulta;
            con.CodMed = c.CodMed;
            con.NomePaciente = c.NomePaciente;
            con.Data = c.Data;
        }));
        ctx.saveChanges();
    }
}

--2.a)
--prints
0
(deadlock)

--nao é serializavel, porque nao é equivalente a aos escalonamentos serie do pontos de vista de conflitosw
--nao produz o mesmo resultado se estiverem em serie T2->T1 ou T1->T2 do que se estiverem como apresentados

--2.b)
--T1                                     |             T2
--bt                                     |             
--                                       |             bt
--read * medicos where CodMed %2 = 0     |             
--read * medicos where CodMed %2 <> 0    |             
--                                       |             insert medico CodMed = <numero par>
--                                       |             insert medico CodMed = <numero impar>
--                                       |             cm
--read * medicos where CodMed %2 = 0     |  (phantom tupple)           
--read * medicos where CodMed %2 <> 0    |  (phantom tupple)           
--cm                                     |             

--2.c)
--nao da erro, termina com sucesso
--apesar de consulta ter um campo que diz respeito a chave privada do medico, este campo nao é chave estrangeira
--pelo que a consulta pode ser inserida e depois o medico

--2.d)
--Saga junta as vantagens das transações encadeadas (parcial commits) com as operações de compensação.
--As vantagens face a uma tradicional é que sao feitos em incrementos menosres, nao tendo tanto peso do ponto
--vista do processamenteo, menos risco de falhar e perder todo o processamento no caso de processamentos longos
--e nao mantem locks durante tanto tempo no caso de transaçoes longas.
--A atomicidade é garantida com as acções de compensaçao, no caso de falha de um determinado passo da saga,
--a sua acção de compensaçao é executada, ou até todas as ações de compensação para passos ja terminados caso
--se queira fazer "rollback" toda a saga.
--exemplos: chora no meu pau