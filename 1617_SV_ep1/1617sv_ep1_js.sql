--1.a
create FUNCTION dbo.LeituraValida(@sensorId int, @valorLeitura decimal)
RETURNS INT
as
BEGIN
declare @res INT = 2
if(not exists(
    select 1
    from leitura
    where sensorId = @sensorId
))
BEGIN
    set @res = 1
END
ELSE
BEGIN
    declare @max DECIMAL
    declare @min DECIMAL

    SELECT
    @max = limiteMaximo,
    @mix = limiteMinimo
    FROM sensor
    WHERE 	pk = @sensorId

    if(@valorLeitura > @max)
    BEGIN
        set @res = 0
    end
    ELSE IF(@valorLeitura < @min)
    BEGIN
        set @res = -1
    END

END
return (@res)
end
GO;
--1.b
create proc dbo.InsereLeitura
(
    @sensorId int,
    @dataLeitura datetime = null,
    @valorLeitura decimal
)
as
BEGIN
    begin TRY
    set TRANSACTION ISOLATION level READ COMMITTED
    declare @erro INT
    select @erro = dbo.LeituraValida(@sensorId, @valorLeitura)
    
    if(@erro = -1)
    BEGIN
        insert into alarme(sensorId, [data], causa)
        VALUES
        (@sensorId, GETDATE(), 'Inferior ao Minimo')

        select 1

    end
    else if(@erro = 0)
    BEGIN
        insert into alarme(sensorId, [data], causa)
        VALUES
        (@sensorId, GETDATE(), 'Superior ao Maximo')

        select 1
    END
    else if(@erro = 1)
    begin
        RAISERROR('Identificador de sensor inválido',16,1)
        select 1
    END
    else
    BEGIN
        if(@dataLeitura is null)
        BEGIN
            insert into Leitura(sensorId, valorLeitura)
            values (@sensorId, @valorLeitura)
        end
        ELSE
        BEGIN
            insert into Leitura(sensorId, valorLeitura,[data])
            values (@sensorId, @valorLeitura, @dataLeitura)
        end
        COMMIT
    end
    end TRY
    BEGIN CATCH
        ROLLBACK
        THROW
    end catch
end
go;

--1.c
create trigger trg_sensorqueue 
on sensorQueue
after INSERT
as
BEGIN
    declare 
    @sensorId int,
    @dataL datetime,
    @valorL DECIMAL

    declare crs_queue cursor FOR
    select sensorId, [data], valorLeitura
    from sensorQueue

    fetch next from crs_queue into @sensorId, @dataL, @valorL
    while @@fetch_status = 0
    BEGIN
    declare @erro INT
    select @erro = dbo.LeituraValida(@sensorId, @valorL)

    if(@erro in (2,-1,0))
    BEGIN
        exec dbo.InsereLeitura
        @sensorId = @sensorId,
        @dataLeitura = @dataL,
        @valorLeitura = @valorL

        delete 
        from sensorQueue
        where sensorId = @sensorId and [data] = @dataL
    end 

    fetch next from crs_queue into @sensorId, @dataL, @valorL
    end
end
go;
--3
create table fatura(
    id numeric(6), ano numeric(4), nifcli numeric(8), data datetime
    primary key(id, ano)
)
go;

create function novoId(@ano numeric(4))
returns numeric(6)
as
begin
declare @m numeric(6)
select @m = max(id)+1 from fatura where ano = @ano
if @m is null
set @m = 1
return @m
end
go;


create proc insFat(@nifCli numeric(8))
as
begin
declare @id numeric(6)
declare @dt datetime = getdate()
set transaction isolation level repeatable read
begin tran
begin try
select @id = dbo.novoid(datepart(year,@dt))
insert into fatura values(@id,datepart(year,getdate()),
@nifCli, @dt)
commit
end try
begin catch
select ERROR_MESSAGE()
if @@TRANCOUNT > 0
rollback
end catch
end
go;

/*
a)
O problema aparece ao obter o novo id recorrendo à função novoId
com o nivel de isolamento de repeatable read duas transacoes podem obter o mesmo valor dado que é um shared lock
assim sendo quando forem inserir uma dela vai tentar inserir um valor que já existe na tabela dando o erro indicado no enunciado

b)
Com nivel de isolamento serializable cada transacao ficara com predicate locking para o registo para o ano indicado. ao inserir um novo registo haverá um deadlock onde uma das transacoes
será abortada
*/

--4
create table tx(i int primary key, j int)
insert into tx values(1,1)
insert into tx values(2,2)
insert into tx values(3,3)
insert into tx values(4,4)
--Transação T1
set tran isolation level repeatable read
begin tran --1a
update tx set j = j+20 where i > 2 --1b
select * from tx where i < 3 --1c
rollback
commit --1d
--Transação T2
set tran isolation level repeatable read
begin tran --2a
update tx set j = j+20 where i > 2 --2b
select * from tx where i < 3 --2c
commit --2d
--Transação T3
set tran isolation level repeatable read
begin tran --3a
update tx set j = j+20 where i < 3 --3b
select * from tx where i > 2 --3c
commit --3d

/*
a) É possível gerar situações de deadlock com a execução concorrente de T1 e T2? Se sim indique o
escalonamento respetivo; se não, justifique.
não é possivel
pois as operaçoes de leitura não entram em conflitos com as de escrita
b) Idem entre T1 e T3.
é possivel
T1.a, t3.a, t1.c, t3.c, t1.b, t3.b, t1.d, t3.d

c) Repita a alínea a), mas admitindo que o nível de isolamento de ambas as transações é read committed .
não se alterava, dado que é um nivel de isolamento menos restrito e os lock de leitura sao libertados apos a query
d) Repita a alínea b), mas admitindo que o nível de isolamento de ambas as transações é read committed .
Não é possivel pois o lock de leitura é libertado após a query e as operaçoes de escrita não têm conflitos
/*