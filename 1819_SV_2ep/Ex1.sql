-- 1a
CREATE FUNCTION valorTotalManutencao(@matricula varchar(16), @km int)
RETURNS MONEY
AS
BEGIN
    DECLARE @res MONEY
    SELECT @res = SUM(valor)
    FROM
    manutencaoItem
    where matricula = @matricula AND km = @km

    RETURN @res
END
GO;

-- 1b
CREATE PROC insereManutencaoItem(@mat varchar(16),@km int, @dataP date, @linha int, @valor NUMERIC(4,2))
AS
BEGIN
    
    IF(
        NOT EXISTS(
            SELECT 1
            FROM
            manutencao
            WHERE matricula = @mat AND km = @km
        )

    )
    BEGIN
        INSERT INTO manutencao (matricula, km, [data])
        VALUES(@mat, @km, @dataP)
    END

    INSERT INTO manutencaoItem(matricula, km, nLinha, valor)
    VALUES(@mat, @km, @linha, @valor)

    DECLARE @total NUMERIC(4, 2)
    
    SET @total = dbo.valorTotalManutencao(@mat, @km)

    UPDATE manutencao
    SET valorTotal = @total
    WHERE matricula = @mat AND km = @km
END
GO;


--1c
CREATE TRIGGER trg_insertManutencaoItem
ON manutencaoItem
AFTER INSERT
AS
BEGIN
    DECLARE @Matricula VARCHAR(16)
    DECLARE @KM int
    DECLARE @total NUMERIC(4, 2)

    DECLARE crs_manItem CURSOR FOR
    SELECT DISTINCT
    matricula,
    km
    FROM INSERTED

    OPEN crs_manItem
    FETCH NEXT FROM crs_manItem   
    INTO @Matricula, @KM

    WHILE @@FETCH_STATUS = 0
    BEGIN
       
    
        SET @total = dbo.valorTotalManutencao(@Matricula, @KM)

        UPDATE manutencao
        SET valorTotal = @total
        WHERE matricula = @Matricula AND km = @KM

        FETCH NEXT FROM crs_manItem   
        INTO @Matricula, @KM
    END

    CLOSE crs_manItem
    DEALLOCATE crs_manItem
END
go;

CREATE PROC insereManutencaoItem(@mat varchar(16),@km int, @dataP date, @linha int, @valor NUMERIC(4,2))
AS
BEGIN
    
    IF(
        NOT EXISTS(
            SELECT 1
            FROM
            manutencao
            WHERE matricula = @mat AND km = @km
        )

    )
    BEGIN
        INSERT INTO manutencao (matricula, km, [data])
        VALUES(@mat, @km, @dataP)
    END

    INSERT INTO manutencaoItem(matricula, km, nLinha, valor)
    VALUES(@mat, @km, @linha, @valor)
END
GO;
--alternativa ao trigger, RODRIGO
CREATE TRIGGER  trg_insertManutencaoItem ON manutencaoItem AFTER INSERT
AS
BEGIN
    DECLARE @mat VARCHAR(16)
    DECLARE @km int
    DECLARE @valor NUMERIC(4,2)

    SELECT @mat = matricula, @km = km
    FROM Inserted

    SET @valor = dbo.valorTotalManutencao(@mat, @km)
    UPDATE manutencao
    SET valorTotal = @valor
    WHERE matricula = @mat AND km = @km
END


GO;
GO;