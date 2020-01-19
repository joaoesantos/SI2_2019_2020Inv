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
CREATE PROC insereManutencaoItem(@mat varchar(16),@km int, @linha int, @valor NUMERIC(4,2))
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
        VALUES(@mat, @km, CONVERT(date,GETDATE()))
    END

    INSERT INTO manutencaoItem(matricula, km, nLinha, valor)
    VALUES(@mat, @km, @linha, @valor)

    UPDATE m
    SET
    m.valorTotal = SOMA
    FROM manutencao m
    INNER JOIN 
    (
        -- Select rows from a Table or View '[TableOrViewName]' in schema '[dbo]'
        SELECT matricula, km, SUM(valor) AS SOMA
        FROM manutencaoItem mi
        GROUP BY mi.matricula, mi.km
    ) somatorios ON (somatorios.matricula = m.matricula AND somatorios.km = m.km)
    WHERE m.matricula = @mat AND m.km = @km

END
GO;


--1c
CREATE TRIGGER trg_insertManutencaoItem
ON manutencaoItem
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Matricula VARCHAR(16)
    DECLARE @KM int
    DECLARE @Linha int
    DECLARE @Valor NUMERIC(4,2)
 
    DECLARE crs_manItem CURSOR FOR
    SELECT 
    matricula,
    km,
    nLinha,
    valor
    FROM INSERTED

    OPEN crs_manItem
    FETCH NEXT FROM crs_manItem   
    INTO @Matricula, @KM, @Linha, @Valor

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF(
            NOT EXISTS(
                SELECT 1
                FROM
                manutencao
                WHERE matricula = @Matricula AND km = @KM
            )

        )
        BEGIN
            INSERT INTO manutencao (matricula, km, [data])
            VALUES(@Matricula, @KM, CONVERT(date,GETDATE()))
        END
        INSERT INTO manutencaoItem(matricula, km, nLinha, valor) VALUES(@Matricula, @KM, @Linha, @Valor)
        FETCH NEXT FROM crs_manItem   
        INTO @Matricula, @KM, @Linha, @Valor
    END

    CLOSE crs_manItem
    DEALLOCATE crs_manItem
END
go;

CREATE PROC insereManutencaoItem2(@mat varchar(16),@km int, @linha int, @valor NUMERIC(4,2))
AS
BEGIN

    INSERT INTO manutencaoItem(matricula, km, nLinha, valor)
    VALUES(@mat, @km, @linha, @valor)

    UPDATE m
    SET
    m.valorTotal = SOMA
    FROM manutencao m
    INNER JOIN 
    (
        -- Select rows from a Table or View '[TableOrViewName]' in schema '[dbo]'
        SELECT matricula, km, SUM(valor) AS SOMA
        FROM manutencaoItem mi
        GROUP BY mi.matricula, mi.km
    ) somatorios ON (somatorios.matricula = m.matricula AND somatorios.km = m.km)
    WHERE m.matricula = @mat AND m.km = @km

END
GO;