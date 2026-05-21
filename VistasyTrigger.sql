CREATE OR ALTER TRIGGER [DBO].validarNumTelefonos   
ON telefonosPersonas   
after INSERT
AS 
	declare @cantidad_telefonos int;

	set @cantidad_telefonos=
		(
			select count(t.telefono) 
			from telefonosPersonas as t
			where cedula in (select cedula from inserted)
		)

	if @cantidad_telefonos<=3
	begin
		print  'Insertando telefono! cantidad actual:'+cast (@cantidad_telefonos as varchar);
	end
	else
	begin
		print ('No se puede insertar un teléfono más!')
		Rollback;
	end

insert into telefonosPersonas values  ('2-0562-0727','1234-5679');

go
create view vista_telefonos_leo
as
	select p.cedula,p.nombre,count(t.telefono) as cantidad  
	from personas p left outer join telefonosPersonas as t
	on (p.cedula=t.cedula)
	where p.cedula='2-0562-0727'
	group by p.cedula,p.nombre