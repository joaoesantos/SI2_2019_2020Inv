use TestesSI2

---- CREATE
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

---- INSERT

insert into Farmaco(NumF, NomeFarmaco, Stock) values
(1, 'Farmaco 1', 10),
(2, 'Farmaco 2', 20),
(3, 'Farmaco 3', 30),
(4, 'Farmaco 4', 40),
(5, 'Farmaco 5', 50)

insert into Medico(CodMed, Nome, Genero, Especialidade) values
(1, 'Medico 1', 'M', 'Especialidade A'),
(2, 'Medico 2', 'M', 'Especialidade B'),
(3, 'Medico 3', 'F', 'Especialidade A'),
(4, 'Medico 4', 'F', 'Especialidade A'),
(5, 'Medico 5', 'F', 'Especialidade B')

insert into Consulta(NumCons, codMed, NomePaciente, Data) values
(1, 1, 'Paciente 1', GETDATE()),
(2, 1, 'Paciente 1', GETDATE()),
(3, 1, 'Paciente 2', GETDATE()),
(4, 2, 'Paciente 3', GETDATE()),
(5, 3, 'Paciente 4', GETDATE())

insert into Receita(NumCons, NumF, quantidade) values
(1, 1, 9),
(2, 2, 10),
(3, 2, 25),
(4, 3, 25),
(5, 5, 51)

--(a) Implemente, utilizando T-SQL, um trigger sobre a tabela Receita que garanta que uma
--receita apenas � emitida caso haja stock suficiente para todos os f�rmacos prescritos. Garanta a
--consist�ncia dos stocks guardados na base de dados.
CREATE TRIGGER trg_InsertReceita ON Receita
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @NumCons int
	DECLARE @NumF int
	DECLARE @quantidade int
	SELECT @NumCons=NumCons, @NumF=NumF, @quantidade=quantidade FROM INSERTED

	IF( EXISTS(
		 SELECT F.Stock
		 FROM Farmaco F
		 INNER JOIN RECEITA R ON F.NumF = @NumF
		 WHERE F.NumF = @NumF AND F.Stock >= @quantidade))
	BEGIN
		print 'Receita aviada'
		INSERT INTO Receita(NumCons, NumF, quantidade) VALUES (@NumCons, @NumF, @quantidade)
		UPDATE Farmaco SET Stock = @quantidade WHERE NumF = @NumF
	END
	ELSE BEGIN print 'Nao xiste stock para aviar a receita' END
END

-- testing nice cursor
INSERT INTO Receita (NumCons, NumF, quantidade) VALUES (111, 2, 100)
SELECT * FROM Farmaco WHERE NumF = 2
SELECT * FROM Receita WHERE NumF = 2
DELETE FROM Receita WHERE NumF=2 AND NumCons=111 

--(b) Imagine que pretende eliminar todas as consultas referente a um m�dico quando este �
--eliminado.
--i. Implemente um trigger T-SQL sobre a tabela Medico de forma a obter a funcionalidade
--pretendida fazendo uso de cursores.
CREATE TRIGGER trg_ApagaConsultaCursor ON Medico
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @CodMed int
	SELECT @CodMed=CodMed FROM DELETED

	DECLARE @MyCursor CURSOR;
	DECLARE @MyField int;

    SET @MyCursor = CURSOR FOR
    SELECT NumCons FROM Consulta WHERE CodMed = @CodMed      

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @MyField

    WHILE @@FETCH_STATUS = 0
    BEGIN
		DELETE FROM Consulta WHERE NumCons = @MyField
		FETCH NEXT FROM @MyCursor 
		INTO @MyField 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;

	DELETE FROM Medico WHERE CodMed = @CodMed
END

--ii. Implemente um trigger T-SQL sobre a tabela Medico de forma a obter a funcionalidade
--pretendida sem qualquer utiliza��o de cursores.
CREATE TRIGGER trg_ApagaConsulta ON Medico
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @CodMed int
	SELECT @CodMed=CodMed FROM DELETED
	DELETE FROM Consulta WHERE CodMed = @CodMed 
	DELETE FROM Medico WHERE CodMed = @CodMed
END

-- testing nicest triggers (don't forget to only have one active)
SELECT * FROM Medico
INSERT INTO Medico(CodMed, Nome, Genero, Especialidade) VALUES
(5, 'Medico 5', 'F', 'Especialidade B')
INSERT INTO Consulta(NumCons, codMed, NomePaciente, Data) VALUES
(10, 5, 'Paciente 0', GETDATE()),
(11, 5, 'Paciente 0', GETDATE()),
(12, 5, 'Paciente 0', GETDATE()),
(13, 5, 'Paciente 0', GETDATE()),
(14, 5, 'Paciente 0', GETDATE())
SELECT * FROM Consulta WHERE codMed = 5
DELETE FROM Medico WHERE codMed = 5


--iii. Qual dos triggers ter� melhor desempenho?
-- O cursor pode chorar no meu pau.

--(c) Defina a fun��o multi-statement T-SQL top_MedicosPorFarmaco(NumF) que apresenta
--os dez m�dicos (Nome) que mais prescreveram o f�rmaco indicado e o respectivo total da quantidade
--prescrita.
CREATE FUNCTION top_MedicosPorFarmaco(@NumF int)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT TOP 10 M.CodMed, M.Nome, SUM(R.quantidade) as quantidade
	FROM Medico M
	INNER JOIN Consulta C ON M.CodMed = C.codMed
	INNER JOIN Receita R ON C.NumCons = R.NumCons
	INNER JOIN Farmaco F ON R.NumF = F.NumF
	WHERE F.NumF = @NumF
	GROUP BY M.CodMed, M.Nome
	ORDER BY SUM(R.quantidade) DESC


---alternativa do joao como eu prefiro fazer
CREATE FUNCTION top_MedicosPorFarmaco(@NumF int)
RETURNS @medicos TABLE(
CodMed int,
Nome varchar(100),
Quantidade int	
)
AS
BEGIN
	insert into @medicos(CodMed, Nome, Quantidade)
	SELECT DISTINCT TOP 10 M.CodMed, M.Nome, SUM(R.quantidade) as quantidade
	FROM Medico M
	INNER JOIN Consulta C ON M.CodMed = C.codMed
	INNER JOIN Receita R ON C.NumCons = R.NumCons
	INNER JOIN Farmaco F ON R.NumF = F.NumF
	WHERE F.NumF = @NumF
	GROUP BY M.CodMed, M.Nome
	ORDER BY SUM(R.quantidade) DESC
	return
end

-- testing function
SELECT top_MedicosPorFarmaco(2)

--(d) Implemente uma vista que apresente todos os f�rmacos sem stock ainda n�o prescritos.
--Comente se a vista implementada � alter�vel.
CREATE VIEW view_name AS
SELECT F.*
FROM Farmaco F
WHERE F.Stock > 0