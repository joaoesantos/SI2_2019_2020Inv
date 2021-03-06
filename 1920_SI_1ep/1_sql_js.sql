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
        RAISERROR('o valor de @num_bi1 nao pode ser igual a @num_bi2', 15, 2)
    end

   

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

     if(@num_bi2 is null)
    BEGIN
        set @tipo = 'S'
        insert into t_contaSingular(keycol, num_bi)
        VALUES
        (@keycol, @num_bi1)
    end
    ELSE
    BEGIN
        set @tipo = 'C'
        insert into t_contaSolidaria(keycol, num_bi1, num_bi2)
        VALUES
        (@keycol, @num_bi1, @num_bi2)
    END
    commit
end TRY
begin CATCH
    ROLLBACK;
    SELECT ERROR_MESSAGE() AS ErrorMessage; 
    throw 
end CATCH
end
go;

--1.b
create VIEW v_contas
AS
SELECT
con.keycol AS Keycol,
con.tipo as Tipo,
sing.num_bi AS Num_bi1,
null as Num_bi2
FROM t_conta con
inner join t_contaSingular sing on sing.keycol = con.keycol
union
SELECT
con.keycol AS Keycol,
con.tipo as Tipo,
sol.num_bi1 AS Num_bi1,
sol.num_bi2 as Num_bi2 
FROM t_conta con
inner join t_contaSolidaria sol on sol.keycol = con.keycol
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
    RAISERROR('Tipo incompativel', 15, 3)
end

if(@num_bi2 is not null and @tipo <> 'C')
BEGIN
    RAISERROR('Tipo incompativel', 15, 4)
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