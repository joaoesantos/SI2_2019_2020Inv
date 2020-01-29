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
create trigger apagar_consultas_trg on Medico after insert
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