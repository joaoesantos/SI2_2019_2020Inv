create table t_Conta(
    keycol int not null primary key,
    tipo char not NULL 
    check (tipo in ('S','C'))
)
go
insert into t_conta(keycol,tipo) values (1,'S'),(2,'S'),(3,'C'),(4,'C')

create table t_titular(
    num_bi int not null primary key,
    nome varchar(30) not null
)
go
insert into t_titular(num_bi,nome) values (1,'titular1'),(2,'titular2'),(3,'titular3'),(4,'titular4')

create table t_contaSingular(
    keycol int not null primary KEY REFERENCES t_Conta ,
    num_bi int not null references t_titular
)
go
insert into t_contaSingular(keycol,num_bi) values (1,1),(2,2)


create table t_contaSolidaria(
    keycol int not null PRIMARY key REFERENCES t_Conta,
    num_bi1 int not null references t_titular,
    num_bi2 int not null references t_titular
)
go
insert into t_contaSolidaria(keycol,num_bi1,num_bi2) values (3,1,3),(4,2,4)