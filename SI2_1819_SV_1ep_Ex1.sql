-- SI2_1819_SV_1ep

-- 1.a
CREATE FUNCTION anosSemCampeao(@anoInf int, @anoSup int)
RETURNS @result TABLE(
    ano int primary key NOT NULL
)
AS
BEGIN
    declare @ano int = @anoInf;

    WHILE @ano <= @anoSup
    BEGIN
        if not exists(
            select e.descr
            from equipas e
            inner join campeoes c on c.id = e.id
            where c.ano = @ano
        )
        BEGIN
            insert into result(ano) values(@ano)
        END

        set @ano = @ano + 1;
    end
    
    RETURN
END
GO;

-- 1.b
CREATE PROCEDURE insAnosSemCamp(@a1 int, @a2 int)
AS
BEGIN
    if not exists(
        select id
        from equipas
        where id = -1 AND descr = '**'
    )
    BEGIN
        insert into equipas(id, descr) VALUES (-1, '**')
    END

    insert into campeoes(id,ano, pontos)
    SELECT
    -1,
    ano,
    0
    from dbo.anosSemCampeao(@a1, @a2)

END
GO;

-- 1.c
create trigger trg_insert_campeao
on campeoes
after INSERT
as
BEGIN
if not exists(
        select id
        from equipas
        where id = -1 AND descr = '**'
    )
    BEGIN
        insert into equipas(id, descr) VALUES (-1, '**')
    END
end
GO;

CREATE PROCEDURE insAnosSemCamp2(@a1 int, @a2 int)
AS
BEGIN
    insert into campeoes(id,ano, pontos)
    SELECT
    -1,
    ano,
    0
    from dbo.anosSemCampeao(@a1, @a2)

END