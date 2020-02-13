create table t_Conta(
    keycol int not null primary key,
    tipo char not NULL 
    check (tipo in ('S','C'))
)
go

create table t_titular(
    num_bi int not null primary key,
    nome varchar(30) not null
)
go
create table t_contaSingular(
    keycol int not null primary KEY REFERENCES t_Conta ,
    num_bi int not null references t_titular
)
go
create table t_contaSolidaria(
    keycol int not null PRIMARY key REFERENCES t_Conta,
    num_bi1 int not null references t_titular,
    num_bi2 int not null references t_titular
)
go