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
