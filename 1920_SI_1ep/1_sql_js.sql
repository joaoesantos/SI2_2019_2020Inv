--1.a
create proc InsereConta(
    @keycol int,
    @num_bi1 int,
    @num_bi2 int
)
AS
BEGIN
begin try
    SET TRANSACTION ISOLATION LEVEL read committed
    begin TRAN
    declare @tipo CHAR

    if(@num_bi1 is null)
    begin
        RAISERROR('o valor de @num_bi1 nao pode ser null', 15, 1)
    end

    if(@num_bi1 = @num_bi2)
    begin
        RAISERROR('o valor de @num_bi1 nao pode ser igual a @num_bi2', 15, 1)
    end

    if(@num_bi2 is null)
    BEGIN
        set @tipo = 'S'
    end
    ELSE
    BEGIN
        set @tipo = 'C'
    END

    if(NOT EXISTS(
        select 1
        from t_Conta
        where keycol = @keycol
    )
    )
    BEGIN
        insert into t_Conta(keycol, tipo)
        VALUES
        (@keycol, @tipo)
    END

    if(@tipo = 'S')
    BEGIN
        insert into t_contaSingular(keycol, num_bi)
        VALUES
        (@keycol, @num_bi1)
    end
    else
    begin
        insert into t_contaSolidaria(keycol, num_bi1, num_bi2)
        VALUES
        (@keycol, @num_bi1, @num_bi2)
    end
    commit
end TRY
begin CATCH
    ROLLBACK
    SELECT ERROR_MESSAGE() AS ErrorMessage;  
end CATCH
end
go;

--1.b
create VIEW v_contas
AS
SELECT
con.keycol AS Keycol,
con.tipo as Tipo,
CASE
when sol.num_bi2 is null then sing.num_bi
else sol.num_bi1 end AS Num_bi1,
sol.num_bi2 as Num_bi2 
FROM t_conta con
left join t_contaSingular sing on sing.keycol = con.keycol
left join t_contaSolidaria sol on sol.keycol = con.keycol
GO;

--1.c
/*
Necessario criar um trigger para tornar a vista editavel dado que está a obter dados de diversas tabelas
*/

create trigger trg_v_contas
on v_contas
instead of insert
as
BEGIN
DECLARE
@keycol int,
@tipo char,
@num_bi1 int,
@num_bi2 int

declare crs_vcontas cursor FOR
select Keycol,Tipo, Num_bi1, Num_bi2
from inserted

open crs_vcontas
fetch next from crs_vcontas into 
@keycol,@tipo, @num_bi1, @num_bi2

while @@fetch_status = 0
BEGIN

if(@num_bi2 is null and @tipo <> 's')
BEGIN
    RAISERROR('Tipo incompativel', 15, 1)
end

if(@num_bi2 is not null and @tipo <> 'C')
BEGIN
    RAISERROR('Tipo incompativel', 15, 1)
end

exec InsereConta
@keycol = @keycol,
@num_bi1 = @num_bi1,
@num_bi2 = @num_bi2

fetch next from crs_vcontas into 
@keycol,@tipo, @num_bi1, @num_bi2
END
close crs_vcontas
DEALLOCATE crs_vcontas
end