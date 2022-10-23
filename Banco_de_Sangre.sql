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
	id_donante int identity primary key,
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
	id_bioanalista int identity primary key,
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
