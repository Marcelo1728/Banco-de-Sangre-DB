CREATE DATABASE Banco_de_Sangre;
GO
USE Banco_de_Sangre;
GO

CREATE TABLE tipo_sangre
(
	tipo_sangre_id INT IDENTITY PRIMARY KEY,
	grupo_sanguineo CHAR(2) not null,
	factor_rh CHAR(1) not null,
	CONSTRAINT CK_tipo_sangre_grupo_sanguineo CHECK (grupo_sanguineo in ('A','B','AB','O')),
	CONSTRAINT CK_tipo_sangre_factor_rh CHECK (factor_rh in ('+','-')),
);

CREATE TABLE sexo
(
	id_sexo INT IDENTITY PRIMARY KEY,
	descripcion CHAR(1) not null,
	CONSTRAINT CK__sexo__descripcion CHECK (descripcion in ('F','M')),
);

create table tipo_hemocomponente
(
	id_hemocomponente int identity primary key,
	descripcion varchar(15),
);

create table donante 
(
	id_donante int primary key,
	dni char(8) unique not null,
	nombre varchar(20) not null,
	apellido varchar(20) not null,
	id_sexo int not null,
	fecha_nacimiento date not null,
	telefono varchar(20),
	direccion varchar(40),
	tipo_sangre_id int not null,
	constraint UQ__donante_dni unique (dni),
	constraint FK__donante__sexo foreign key (id_sexo) references sexo (id_sexo),
	constraint FK__donante__tipo_sangre foreign key (tipo_sangre_id) references tipo_sangre (tipo_sangre_id)
);

create table paciente 
(
	dni char(8) unique not null,
	nombre varchar(20) not null,
	apellido varchar(20) not null,
	id_sexo int not null,
	fecha_nacimiento date not null,
	telefono varchar(20),
	direccion varchar(40),
	tipo_sangre_id int not null,
	constraint UQ__paciente_dni unique (dni),
	constraint FK__paciente__sexo foreign key (id_sexo) references sexo (id_sexo),
	constraint FK__paciente__tipo_sangre foreign key (tipo_sangre_id) references tipo_sangre (tipo_sangre_id)
);

create table bioanalista 
(
	id_bioanalista int primary key,
	dni char(8) unique not null,
	nombre varchar(20) not null,
	apellido varchar(20) not null,
	id_sexo int not null,
	fecha_nacimiento date not null,
	telefono varchar(20),
	direccion varchar(40),
	constraint UQ__bioanalista_dni unique (dni),
	constraint FK__bioanalista__sexo foreign key (id_sexo) references sexo (id_sexo),
);
create table bolsa (
    id_bolsa int not null primary key,
    fecha_extraccion date,
    cantidad float (4),
    fecha_vencimiento date,
    hora_vencimiento time,
    id_hemocomponente int,
    id_donante int,
    constraint FK_hemocomponente foreign key (id_hemocomponente) references tipo_hemocomponente (id_hemocomponente),
    constraint FK_donante foreign key (id_donante) references donante (id_donante),
    );
    
    create table pruebas_donantes (
    id_prueba int not null primary key,
    id_bolsa int,
    id_bioanalista int,
    fecha date,
    hcv bit,
    hiv bit,
   sifilis bit,
   ahbc bit,
   htlv bit,
   chagas bit,
   hbsag bit,
   t_prueba bit,
   
    constraint FK_bolsa foreign key (id_bolsa) references bolsa (id_bolsa),
    constraint FK_bioanalista foreign key (id_bioanalista) references bioanalista(id_donaid_bioanalistante),
    );
