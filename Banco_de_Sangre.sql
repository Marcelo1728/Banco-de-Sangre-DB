create database Banco_de_Sangre;
go
use Banco_de_Sangre;
go

create table tipo_sangre
(
	tipo_sangre_id int identity primary key,
	grupo_sanguineo char(2) not null,
	factor_rh char(1) not null,
	constraint CK_tipo_sangre_grupo_sanguineo check (grupo_sanguineo in ('A','B','AB','O')),
	constraint CK_tipo_sangre_factor_rh check (factor_rh in ('+','-')),
);
go
create table sexo
(
	id_sexo int identity primary key,
	descripcion char(1) not null,
	constraint CK__sexo__descripcion check (descripcion in ('F','M')),
);
go
create table tipo_hemocomponente
(
	id_hemocomponente int identity primary key,
	descripcion varchar(15),
);
go
create table estado
(
	id_estado int identity primary key,
	descripcion varchar(25),
);
go
create table donante 
(
	id_donante int primary key,
	dni char(8) not null,
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
go
create table paciente 
(
	dni char(8) not null,
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
go
create table bioanalista 
(
	id_bioanalista int primary key,
	dni char(8) not null,
	nombre varchar(20) not null,
	apellido varchar(20) not null,
	id_sexo int not null,
	fecha_nacimiento date not null,
	telefono varchar(20),
	direccion varchar(40),
	constraint UQ__bioanalista_dni unique (dni),
	constraint FK__bioanalista__sexo foreign key (id_sexo) references sexo (id_sexo),
);
go
create table bolsa 
(
	id_bolsa int primary key,
	fecha_extraccion smalldatetime not null,
	cantidad numeric(5,2) not null,
	fecha_vencimiento smalldatetime,
	id_donante int not null,
	id_hemocomponente int not null,
	id_estado int not null,
	constraint FK__bolsa__donante foreign key (id_donante) references donante (id_donante),
	constraint FK__bolsa__tipo_hemocomponente foreign key (id_hemocomponente) references tipo_hemocomponente (id_hemocomponente),
	constraint FK__bolsa_estado foreign key (id_estado) references estado (id_estado)
);
go
create table pruebas_donante (
	id_prueba int primary key,
	fecha smalldatetime not null,
	hcv bit not null,
	hiv bit not null,
	sifilis bit not null,
	ahbc bit not null,
	htlv bit not null,
	chagas bit not null,
	hbsag bit not null,
	t_prueba bit not null,
	id_bolsa int not null,
	id_bioanalista int not null,
	constraint UQ__pruebas_donante_bolsa unique (id_bolsa),
	constraint FK__pruebas_donante__bolsa foreign key (id_bolsa) references bolsa (id_bolsa),
	constraint FK__pruebas_donante__bioanalista foreign key (id_bioanalista) references bioanalista (id_bioanalista)
    );
go
create table solicitud_transfusion
(
	id_solicitud_transfusion int primary key,
	fecha smalldatetime not null,
	motivo varchar (40),
	cantidad numeric (5,2),
	paciente_dni char(8) not null,
	id_hemocomponente int not null,
	id_estado int not null,
	constraint FK__solicitud_transfusion__paciente foreign key (paciente_dni) references paciente (dni),
	constraint FK__solicitud_transfusion__tipo_hemocomponente foreign key (id_hemocomponente) references tipo_hemocomponente (id_hemocomponente),
	constraint FK__solicitud_transfusion_estado foreign key (id_estado) references estado (id_estado)
);
go
create table transfusion
(
	id_transfusion int primary key,
	fecha_transfusion smalldatetime not null,
	fecha_recepcion smalldatetime not null,
	muestra_reaccion varchar(40),
	modificacion varchar(20),
	id_solicitud_transfusion int not null,
	id_bolsa int not null,
	constraint FK__transfusion__solicitud_transfusion foreign key (id_solicitud_transfusion) references solicitud_transfusion (id_solicitud_transfusion),
	constraint FK__transfusion__bolsa foreign key (id_bolsa) references bolsa (id_bolsa)
);
go

------------------------------------RESTRICCIONES------------------------------------
ALTER table transfusion
add constraint CK_fecha_tf check(fecha_recepcion <= getdate())

alter table paciente
	add constraint CK__paciente_fecha_nacimiento CHECK (fecha_nacimiento <= CURRENT_TIMESTAMP);
go
alter table bioanalista
	add constraint CK__bioanalista_fecha_nacimiento CHECK (fecha_nacimiento <= CURRENT_TIMESTAMP);
go
alter table bolsa
	add constraint DF__bolsa__fecha_extraccion DEFAULT CURRENT_TIMESTAMP FOR fecha_extraccion;
go
alter table bolsa
	add constraint CK__bolsa_cantidad CHECK (cantidad >= 50 AND cantidad<= 300);
go
alter table bolsa
	add constraint DF__bolsa__fecha_vencimiento DEFAULT NULL FOR fecha_vencimiento;
go	
alter table bolsa
	add constraint DF__bolsa_estado DEFAULT 1 FOR id_estado;
go	
alter table pruebas_donante
	add constraint DF__pruebas_donante_fecha DEFAULT CURRENT_TIMESTAMP FOR fecha;
go
alter table solicitud_transfusion
	add constraint DF__solicitud_transfusion_fecha DEFAULT CURRENT_TIMESTAMP FOR fecha;
go	
alter table solicitud_transfusion
	add constraint DF__solicitud_transfusion_estado DEFAULT 1 FOR id_estado;
go
----------------------------------------------------------
----------------- TRANSACCIONES ----------------------------------------------------
------------------------------------
-- Modificacion de una transfusion, fecha y diagnostico
begin tran --> Inicio de la transaccion
update transfusion set muestra_reaccion = 'texto ejemplo'
where id_transfusion = 1
------------------------> fallo aproposito
update transfusion set fecha_recepcion = '2022-12-10'
where id_transfusion = 1
if @@ERROR <> 0 --> @ERROR es una variable del motor que devuelve un valor distinto
--de 0 cuando hay un error de restriccion
BEGIN
ROLLBACK --> Lo que hace el rollback es volver a un estado inicial del que
--estaba
END
-- Para verificar
SELECT * from transfusion tf;
------------------------------------------------------------------------------------
----------------------------------------

----------------------------CONSULTAS-------------------------------------

--MUESTRA TIPO DE SANGRE MAS DEMANDADO

SELECT TOP 1 grupo_sanguineo as tiposangre , factor_rh as factor, count(grupo_sanguineo) as cantidad
from solicitud_transfusion
right join paciente on(solicitud_transfusion.paciente_dni = paciente.dni)
inner join tipo_sangre on(tipo_sangre.tipo_sangre_id = paciente.tipo_sangre_id)
group by grupo_sanguineo, factor_rh order by cantidad DESC;
GO

-- Muestra bioanalista  que mas analisis hicieron en el año 2022 (Que mas trabajo)
SELECT b.nombre , b.apellido,
count(hc.id_bioanalista) as 'cantidad de analisis'
from pruebas_donante as hc
inner join bioanalista as b on hc.id_bioanalista = b.id_bioanalista
inner join bolsa as bolsa on hc.id_bolsa = bolsa.id_bolsa
where YEAR(hc.fecha) = 2022
GROUP by b.nombre , b.apellido,  hc.id_bioanalista
order by count(hc.id_bioanalista) DESC;
GO

/*Muestra las solicitudes de transfución que siguen en espera*/
select * from  solicitud_transfusion where id_solicitud_transfusion 
not in(select distinct (id_solicitud_transfusion) from transfusion );
GO

/*Muestra tipo de hemocomponente mas demandado*/

SELECT TOP 1 descripcion as hemocomponente , count(descripcion) as cantidad
from solicitud_transfusion
inner join tipo_hemocomponente on(tipo_hemocomponente.id_hemocomponente = solicitud_transfusion.id_hemocomponente)
group by descripcion order by cantidad DESC;
GO

---PACIENTES QUE MOSTRARON REACCION----

SELECT  paciente.nombre, paciente.dni, transfusion.muestra_reaccion from transfusion 
inner join solicitud_transfusion on solicitud_transfusion.id_solicitud_transfusion=transfusion.id_solicitud_transfusion
inner join paciente on paciente.dni=solicitud_transfusion.paciente_dni
where muestra_reaccion is not null group by paciente.nombre, paciente.dni, transfusion.muestra_reaccion;

go

-- Mostrar catidad de donantes por tipo de sangre
SELECT tipo_sangre.grupo_sanguineo, tipo_sangre.factor_rh , COUNT(bolsa.id_donante) as 'cantidad' from bolsa
inner join donante  on donante.id_donante = bolsa.id_donante
inner join tipo_sangre on tipo_sangre.tipo_sangre_id = donante.tipo_sangre_id
group by tipo_sangre.grupo_sanguineo,tipo_sangre.factor_rh
go
-- Muestra las bolsas que estan disponible
SELECT bolsa.id_bolsa, bolsa.fecha_extraccion, bolsa.cantidad, bolsa.fecha_vencimiento, bolsa.id_hemocomponente, 
donante.tipo_sangre_id from
transfusion 
right join bolsa on transfusion.id_bolsa = bolsa.id_bolsa
inner join donante on donante.id_donante= bolsa.id_donante 
inner join tipo_sangre on tipo_sangre.tipo_sangre_id=donante.tipo_sangre_id
where transfusion.id_bolsa is NULL
go

----------------------------FUNCIONES----------------------------
--retorna el tipo de componente (id_hemocomponente) de una bolsa a partir de la prueba realizada (id_prueba)

CREATE FUNCTION GetIdComponente (@idPrueba int)
RETURNS INT AS
BEGIN
	--declaramos la variable que contendra el id del componente
	DECLARE	 @idComponente int
	--selecciona el tipo de hemocomponente pasando como parametro el id de la prueba y lo almacena en la variable @idcomponente
	SELECT @idComponente = th.id_hemocomponente 
	FROM pruebas_donante as pd
		INNER JOIN bolsa as b
			ON pd.id_bolsa = b.id_bolsa
		INNER JOIN	tipo_hemocomponente as th
			ON b.id_hemocomponente = th.id_hemocomponente
	WHERE pd.id_prueba = @idPrueba

RETURN @idComponente

END
GO
------------------------------------VISTAS--------------------------------------
----
--ESTA VISTA NOS PERMITE PODER VISUALIZAR LOS DATOS DE DOS TABLAS SIN ACCEDER
--DIRECTAMENTE A ELLAS SOLO MOSTRANDO MUY DETERMINADAS.
--EN ESTE CASO ACCEDE A LAS TABLAS donante Y bioanalista, MOSTRANDO
--VISTAS donante_bioanalista
--drop view donante_bioanalista
create view donante_bioanalista with encryption
as
select	donante.id_donante, donante.nombre, bioanalista.nombre as nombrebio, bioanalista.id_bioanalista
	from donante,bioanalista;
go
select * from donante_bioanalista;
--Consulta sobre la vista 
select bioanalista.nombre as 'nombre bioanalista',
	donante.nombre as'nombre donante',
	pruebas_donante.id_bioanalista as 'ID DEL bioanalista',
	pruebas_donante.id_bolsa as 'id de bolsa'
from donante_bioanalista
	inner join pruebas_donante
		on donante_bioanalista.id_donante=pruebas_donante.id_bolsa and donante_bioanalista.id_bioanalista=pruebas_donante.id_bioanalista
	inner join bioanalista on donante_bioanalista.id_bioanalista = bioanalista.id_bioanalista
	inner join donante on donante_bioanalista.id_donante = donante.id_donante;

go

/*--esta vista nos permite ver los pacientes que tienen al menos una solicitud de transfusión*/
--VISTA pacientes
create view Pacientes with encryption
as
select solicitud_transfusion.paciente_dni ,solicitud_transfusion.id_estado from solicitud_transfusion
	inner join paciente on solicitud_transfusion.paciente_dni = paciente.dni
go
--SE COMPRUEBA QUE FUNCIONE
select * from Pacientes
---drop view Pacientes

select paciente.nombre as 'nombre de paciente', estado.descripcion as 'estado de solicitud de transfusion' from Pacientes
	inner join estado on Pacientes.id_estado=estado.id_estado
	inner join paciente on Pacientes.paciente_dni=paciente.dni;
go
------------------------------------TRIGGERS------------------------------------

--verifica si la bolsa contiene algun tipo de enfermedad, si no contiene ninuguna enfermedad la fecha de vencimiento de la bolsa segun el componente que contiene y un estado de aceptado (2)
--si contiene alguna enfermedad se actualiza el balor de id_estado de la bolsa a rechazado (3)

CREATE TRIGGER TR_bolsa_fechCaducidad
ON pruebas_donante
FOR INSERT	--se dispara al momento de realizar un insert en la tabla pruebas_donante
AS
	DECLARE @id_prueba int,
			@hcv bit,
			@hiv bit,
			@sifilis bit,
			@ahbc bit,
			@htlv bit,
			@chagas bit,
			@hbsag bit,
			@t_prueba bit,
			@id_bolsa int
	SELECT  
			@id_prueba = id_prueba,
			@hcv = hcv,
			@hiv = hiv,
			@sifilis = sifilis,
			@ahbc = ahbc,
			@htlv = htlv,
			@chagas = chagas,
			@hbsag = hbsag,
			@t_prueba = t_prueba,
			@id_bolsa = id_bolsa

	FROM inserted; --desde el registro a insertar
	

--	condicion si las prueba es exitosa asignar a bolsa estado = aceptado y una fecha de caducidad dependiendo del hemocomponente
	IF (@hcv=0 AND @hiv=0 AND @sifilis=0 AND @ahbc=0 AND @htlv=0 AND @chagas=0 AND @hbsag=0 AND @t_prueba=0) --si no se encuentra ninguna enfermedad
		BEGIN
			DECLARE @idcomponente int;--declaramos una variable para asignar el id
			SELECT @idcomponente = dbo.GetIdComponente(@id_prueba); --llamamos a la funcion para que nos retorne el id del componente y lo guardamos en la variable
			UPDATE bolsa SET id_estado=2 , fecha_vencimiento =		--estado 2 = aceptado
				CASE
					WHEN @idcomponente = 1 THEN DATEADD(DAY,42,fecha_extraccion)--agrega 42 dias a partir de la fecha de extraccion si el componente es 'globulos rojos'
					WHEN @idcomponente = 2 THEN DATEADD(DAY,7,fecha_extraccion)--agrega 7 dias a partir de la fecha de extraccion si el componente es 'plaquetas'
					WHEN @idcomponente = 3 THEN DATEADD(YEAR,2,fecha_extraccion)--agrega 2 años a partir de la fecha de extraccion si el componente es 'plasma'
				END
			WHERE id_bolsa=@id_bolsa
		END
		
	ELSE --si la bolsa contiene enfermedades se le asigna el estado rechazado
		UPDATE bolsa SET  id_estado=3 --3 = rechazado
		WHERE id_bolsa=@id_bolsa
GO

--verifica que la edad del donante se encuentra dentro de los valores permitidos antes de realizar la inserción

create trigger TR_donante_edad
on donante
instead of insert	--se dispara al momento que se realiza un insert sin que este se concrete
as
	declare 
			@id_donante int,
			@dni char(8),
			@nombre varchar(20),
			@apellido varchar(20),
			@id_sexo int,
			@fecha_nacimiento date,
			@telefono varchar(20),
			@direccion varchar(40),
			@tipo_sangre_id int,
			@edad int;

	select  @id_donante = id_donante,
			@dni = dni,
			@nombre = nombre,
			@apellido = apellido,
			@id_sexo = id_sexo,
			@fecha_nacimiento = fecha_nacimiento,
			@telefono = telefono,
			@direccion = direccion,
			@tipo_sangre_id = tipo_sangre_id 
	from inserted;
	
	select @edad = (cast(convert(varchar(8),getdate(),112) as int) - cast(convert(varchar(8),@fecha_nacimiento,112) as int) ) / 10000

	if	(@edad >= 18 and @edad <= 65)
		insert into donante Values (@id_donante,@dni,@nombre,@apellido,@id_sexo,@fecha_nacimiento,@telefono,@direccion,@tipo_sangre_id)
	else
		begin
			print ('ERROR: El donante debe tener entre 18 y 65 años de edad')
		end
go


-------------------------PROCEDIMIENTOS ALMACENADOS PARA INSERTAR REGISTROS-------------------------
--para ingresar transfucion
 create procedure pa_ingresar_transfucion(
	@id_transfusion int,
	@feha_transfusion smalldatetime,
	@feha_recepcion smalldatetime,
	@muestra_reaccion varchar (40),
	@modificacion varchar (20),
	@id_solicitud_transfusion int,
	@id_bolsa int)
	as
	insert into transfusion(id_transfusion,fecha_transfusion,fecha_recepcion,muestra_reaccion,modificacion,id_solicitud_transfusion,id_bolsa)
                     values (@id_transfusion,@feha_transfusion,@feha_recepcion,@muestra_reaccion,@modificacion,@id_solicitud_transfusion,@id_bolsa )
go

-- para ingresar tipo_hemocomponente
create procedure pa_ingresar_tipo_hemocomponente(
	@descripcion varchar (25))
      as
	insert into tipo_hemocomponente( descripcion)
				values (@descripcion )
go
				
--select * from tipo_hemocomponente;
--execute pa_ingresar_tipo_hemocomponente 'globulos blancos'

-- para ingresar solicitud transfusion
create procedure pa_ingresar_Solicitud_transfusion(
	@id_solicitud_transfusion int,
	@fecha smalldatetime,
	@motivo varchar(40),
	@cantidad numeric(5,2),
	@paciente_dni char(8),
	@id_hemocomponente int)
	as
	insert into solicitud_transfusion(id_solicitud_transfusion,fecha,motivo,cantidad,paciente_dni,id_hemocomponente,id_estado)
				values ( @id_solicitud_transfusion,@fecha,@motivo,@cantidad,@paciente_dni,@id_hemocomponente,default)
go

set dateformat dmy
go
--exec pa_ingresar_Solicitud_transfusion 15,'25/6/2021 12:45','transfusion globulos rojos','65.20','34667546',1;

-- para ingresar pruebas_donate
create procedure pa_ingresar_Pruebas_Donantes(
	@id_prueba int,
	@fecha smalldatetime,
	@hcv bit,
	@hiv bit,
	@sifilis bit,
	@ahbc bit,
	@htlv bit,
	@chagas bit,
	@hbsag bit,
	@t_prueba bit,
	@id_bolsa int,
	@id_bioanalista int)
	as
	insert into pruebas_donante(id_prueba,fecha,hcv,hiv,sifilis,ahbc,htlv,chagas,hbsag,t_prueba, id_bolsa,id_bioanalista)
                    	values(@id_prueba,@fecha,@hcv,@hiv,@sifilis,@ahbc,@htlv,@chagas,@hbsag,@t_prueba,@id_bolsa,@id_bioanalista)
go

-- para ingresar paciente
create procedure pa_ingresar_Paciente(
	@dni char(8),
	@nombre varchar(20),
	@apellido varchar(20),
	@id_sexo int,
	@fecha_nacimiento date,
	@telefono varchar(20),
	@direccion varchar(40),
	@tipo_sangre int)
	as
	insert into paciente(dni,nombre,apellido,id_sexo,fecha_nacimiento,telefono,direccion,tipo_sangre_id)
		values (@dni,@nombre,@apellido,@id_sexo,@fecha_nacimiento,@telefono,@direccion,@tipo_sangre)
go
--para ingresar estado
    create procedure pa_ingresar_estado(
        @descripcion varchar(25))
        as
        insert into estado(descripcion)
        values (@descripcion)
go

-- para ingresar bolsa
create procedure pa_ingresar_bolsa2(
	@id_bolsa int,
	@fecha_extracion smalldatetime,
	@cantidad numeric(5,2),
	@fecha_vencimiento smalldatetime,
	@id_donante int,
	@id_hemocomponente int,
	@id_estado int)
	as
	insert into bolsa(id_bolsa,fecha_extraccion,cantidad,fecha_vencimiento,id_donante,id_hemocomponente,id_estado)
	values (@id_bolsa,@fecha_extracion,@cantidad,@fecha_vencimiento,@id_donante,@id_hemocomponente,@id_estado)
go
 -- para ingresar donante
create procedure pa_ingresar_donante(
	@id_donante int,
	@dni char(8),
	@nombre varchar(20),
	@apellido varchar(20),
	@id_sexo int,
	@fecha_nacimiento date,
	@telefono varchar(20),
	@direccion varchar(40),
	@tipo_sangre_id int)
	as
	insert into donante(id_donante,dni,nombre,apellido,id_sexo,fecha_nacimiento,telefono,direccion,tipo_sangre_id)
	values (@id_donante,@dni,@nombre,@apellido,@id_sexo,@fecha_nacimiento,@telefono,@direccion,@tipo_sangre_id)
go
-- para ingresar bioanalista
create procedure pa_ingresar_bioanalista(
	@id_bioanalista int,
	@dni char(8),
	@nombre varchar(20),
	@apellido varchar(20),
	@id_sexo int,
	@fecha_nacimiento date,
	@telefono varchar(20),
	@direccion varchar(40))
	as
	insert into bioanalista(id_bioanalista,dni,nombre,apellido,id_sexo,fecha_nacimiento,telefono,direccion)
		values (@id_bioanalista,@dni,@nombre,@apellido,@id_sexo,@fecha_nacimiento,@telefono,@direccion)
go

-------------------------PROCEDIMIENTOS ALMACENADOS PARA ELIMINAR REGISTROS-------------------------
-- Para eliminar bolsa
create procedure pa_eliminar_bolsa
	(@id_bolsa int)
    as
	alter table pruebas_donante
		drop constraint FK__pruebas_donante__bolsa

	alter table transfusion
		drop constraint FK__transfusion__bolsa
		
	delete from bolsa where id_bolsa= @id_bolsa

	alter table pruebas_donante with nocheck 
		add	constraint FK__pruebas_donante__bolsa foreign key (id_bolsa) references bolsa (id_bolsa)
	alter table transfusion with nocheck
	 add constraint FK__transfusion__bolsa foreign key (id_bolsa) references bolsa (id_bolsa)
go


-- Para eliminar donante
create procedure pa_eliminar_donante
	(@dni char(8))
    as		
	alter table bolsa
	drop constraint FK__bolsa__donante
	delete from donante where dni= @dni
	alter table bolsa with check 
	add constraint FK__bolsa__donante foreign key (id_donante) references donante (id_donante)
go

-- Para eliminar estado
create procedure pa_eliminar_estado
	(@id_estado int)
      as		
	alter table bolsa
		drop constraint FK__bolsa_estado
	alter table solicitud_transfusion
		drop constraint FK__solicitud_transfusion_estado

	delete from estado where id_estado= @id_estado

	alter table bolsa with nocheck 
		add constraint FK__bolsa_estado foreign key (id_estado) references estado (id_estado)
	alter table solicitud_transfusion with nocheck
		add constraint FK__solicitud_transfusion_estado foreign key (id_estado) references estado (id_estado)
go

-- Para eliminar Paciente  este error me da "Ya hay un objeto con el nombre 'FK__solicitud_transfusion__paciente' en la base de datos."
create procedure pa_eliminar_paciente
	(@id_dni char(8))
	as		
	alter table solicitud_transfusion
		drop constraint FK__solicitud_transfusion__paciente 
	delete from paciente where dni= @id_dni
	alter table solicitud_transfusion with nocheck
		add constraint FK__solicitud_transfusion__paciente foreign key (paciente_dni) references paciente (dni)
go

	-- Para eliminar Pruebas Donantes
create procedure pa_eliminar_pruebas_donante
	(@id_prueba int)
	as
	delete from pruebas_donante where id_prueba= @id_prueba
go  

--select * from pruebas_donante;
--execute pa_eliminar_pruebas_donante 2;

-- Para eliminar Solicitud de Transfucion
create procedure pa_eliminar_solicitud_Transfusion
	(@id_solicitud_transfusion int)
	as		
	alter table transfusion
		drop constraint FK__transfusion__solicitud_transfusion     
	delete from solicitud_transfusion where id_solicitud_transfusion= @id_solicitud_transfusion
	alter table transfusion with nocheck
		add constraint FK__transfusion__solicitud_transfusion foreign key (id_solicitud_transfusion) references solicitud_transfusion (id_solicitud_transfusion)
go

--select * from solicitud_transfusion;
--execute pa_eliminar_solicitud_Transfusion 1

-- Para eliminar tipo Hemocomponente
create procedure pa_eliminar_tipo_hemocomponente
	(@id_hemocomponente int)
	as		
	delete from tipo_hemocomponente where id_hemocomponente= @id_hemocomponente
go 

--execute pa_eliminar_tipo_hemocomponente 4
--select * from tipo_hemocomponente;

-- Para eliminar transfusion
create procedure pa_eliminar_transfusion
	(@id_transfusion int)
	as		
	delete from transfusion where id_transfusion= @id_transfusion
go 

--select * from transfusion;
--execute pa_eliminar_transfusion 1
	