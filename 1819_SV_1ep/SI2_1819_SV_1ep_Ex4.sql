-- SI2_1819_SV_1ep
-- 4

/*a*/
create proc debitar @num int, @valor real 
as 
begin 
set transaction isolation level repeatable read 
begin tran 
    if not exists (select * from contas where numero = @num) 
    begin 
        --rollback; 
        return -1; 
    end 
    
    update contas 
    set saldo = saldo - @valor 
    where numero = @num and saldo >= @valor 
    
    if @@rowcount = 0 
    begin 
        --rollback; 
        return -2; 
        end 
    commit 
    return 0 
end
GO;

create proc creditar @num int, @valor real 
as 
begin 
set transaction isolation level repeatable read 
begin tran 
if not exists (select * from contas where numero = @num) 
begin 
    --rollback; 
    return -3; 
end 
update contas 
set saldo = saldo + @valor 
where numero = @num 

commit 
return 0 
end
GO;

create proc transferir @num1 int, @num2 int, @valor real 
as 
begin 
declare @r int 
begin tran 
exec @r = debitar @num1,@valor

if @r <> 0 
begin 
    rollback; 
    return @r; 
    end 
    
exec @r = creditar @num2,@valor 
if @r <> 0 
begin 
    rollback; 
    return @r; 
    end 
commit 
return 0; 
end
GO;
/*--a*/

/*--b*/
/*RODRI*/
(Slide 19 das TransaçõesII)
Regra de visibilidade – os objectos detidos por uma transação podem ser tornados visíveis
nas suas sub-transações. A terminação com sucesso de uma transação torna os seus
resultados visíveis na sua transação-pai

/*--b*/