create table Farmaco(
NumF int primary key,
NomeFarmaco varchar(100),
Stock int not null
)
create table Medico(
CodMed int primary key,
Nome varchar(100) not null,
Genero char not null,
Especialidade varchar(100)
)
create table Consulta(
NumCons int primary key,
codMed int not null,
NomePaciente varchar(100) not null,
Data datetime not null,
constraint c1 foreign key(codMed)
references Medico
)
create table Receita(
NumCons int not null,
NumF int not null,
quantidade int not null,
primary key(numcons,numf)
)
GO;
--a
create trigger trg_insertReceita
on Receita
INSTEAD OF INSERT
AS
BEGIN
DECLARE @quantidade int, @numF int, @numCons int
declare crs_receita CURSOR FOR
Select quantidade, NumF, NumCons from inserted

FETCH next from crs_receita into @quantidade, @numF, @numCons
while @@FETCH_Status = 0
BEGIN
declare @stock INT
select @stock = Stock
from Farmaco
where NumF = @numF

if(@stock > @quantidade)
BEGIN
    insert into Receita(numCons, NumF, quantidade) values(@numCons, @numF, @quantidade)

    update Farmaco
    set
    Stock = Stock - @quantidade
    where NumF = @numF
end

FETCH next from crs_receita into @quantidade, @numF, @numCons
end

end
go;
--b
---i
create trigger trg_deleteMedico
on Medico
INSTEAD OF DELETE
AS
BEGIN
declare @NumCons int
declare @CodMed INT

select @CodMed = CodMed
from deleted

declare crs_consulta cursor FOR
select NumCons from Consulta where CodMed = @CodMed

FETCH next from crs_consulta into @NumCons
while @@FETCH_Status = 0
BEGIN
delete from Consulta where NumCons = @NumCons
end

delete from Medico where CodMed = @CodMed
end
GO

---II
create trigger trg_deleteMedico
on Medico
INSTEAD OF DELETE
AS
BEGIN
declare @CodMed INT

select @CodMed = CodMed
from deleted

delete from Consulta where CodMed = @CodMed
delete from Medico where CodMed = @CodMed
end
GO;
---iii
/*
Sem cursores, os cursores têm um overhead no processamento além de se estar a criar novos artefactos em memoria
*/

--c
create function top_MedicosPorFarmaco(@NumF int)
returns @medicos table(
    Nome varchar(100),
    Quantidade int
)
AS
BEGIN
insert into @medicos(Nome, Quantidade)
SELECT TOP(10) m.Nome, SUM(r.quantidade)
FROM Farmaco f
inner join Receita r on r.NumF = f.NumF
inner join Consulta c on c.NumCons = r.NumCons
inner join Medico m on m.CodMed = c.CodMed
WHERE f.NumF = @NumF	
GROUP BY m.Nome, m.CodMed
ORDER BY SUM(r.quantidade) DESC
return
end

--d
create view FarmacosSemStock
AS
SELECT *
FROM Farmacos f
LEFT JOIN Receita r on r.NumF = f.NumF
WHERE f.Stock = 0 AND r.NumCons IS NULL

--e só faz ações na base de dados quando estritamente necessario
