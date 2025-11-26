---- Parte 1: Crear un esquema relacional con datos de ejemplo

-- 1: Crear tablas
create table asistente(
id_asistente      number,
nombre_asistente  varchar2(128),
extras            JSON (object),
constraint pk_asistente primary key (id_asistente)
);

create table ponente(
id_ponente   number,
nombre       varchar2(128),
correo       varchar2(64),
calificacion number,
constraint pk_ponente primary key (id_ponente)
);

create table sesiones(
id_sesion    number,
nombre       varchar2(128),
sala         varchar2(128),
id_ponente   number,
constraint pk_sesion primary key (id_sesion),
constraint fk_sesion_ponente foreign key (id_ponente) references ponente(id_ponente)
);

create table inscripciones (
id_inscripcion number,
id_sesion      number,
id_asistente   number,
constraint pk_inscripcion primary key (id_inscripcion),
constraint fk_inscripcion_asistente foreign key (id_asistente) references asistente(id_asistente),
constraint fk_inscripcion_sesion foreign key (id_sesion) references sesiones(id_sesion)
);


-- 2. Insertar datos en las tablas:

insert into asistente(id_asistente, nombre_asistente) values(1, 'Shashank');
insert into asistente(id_asistente, nombre_asistente) values(2, 'Doug');

insert into ponente values(1, 'Bodo', 'bodo@universidad.edu', 7);
insert into ponente values(2, 'Tirthankar','mr.t@universidad.edu', 10);

insert into sesiones values (1, 'JSON y SQL', 'Sala 1', 1);
insert into sesiones values (2, 'PL/SQL o Javascript', 'Sala 2', 1);
insert into sesiones values (3, 'Oracle en iPhone', 'Sala 1', 2);

insert into inscripciones values (1,1,1);
insert into inscripciones values (2,2,1);
insert into inscripciones values (3,2,2);
insert into inscripciones values (4,3,1);
commit;

select * from asistente;
select * from ponente;
select * from sesiones;
select * from inscripciones;


---- Parte 2: Crear la vista dual  

-- 1. Crear vistas duales 1:1 (una vista representa una única tabla)
create or replace JSON Duality view asistenteV as 
asistente @update @insert @delete{
_id     : id_asistente,
nombre  : nombre_asistente,
extras  @flex 
};

create or replace JSON Duality view ponenteV as 
ponente  @update @insert @delete {
_id           : id_ponente,
nombre        : nombre,
calificacion  : calificacion @noupdate
};

-- 2. Vista Dual en varias tablas
create or replace JSON Duality view inscripcionesV AS
asistente 
{
_id        : id_asistente
nombre     : nombre_asistente
inscripciones : inscripciones  @insert @update @delete
{
    id_inscripcion : id_inscripcion
    sesiones @unnest
    {
        id_sesion : id_sesion
        nombre    : nombre
        ubicacion : sala
        ponente @unnest
        {
            id_ponente : id_ponente
            nombre_ponente : nombre
        }
    } 
}
} ;


select data from inscripcionesV;


---- Parte 3: Trabajar con las vistas duales

-- 1. Seleccionar los datos de manera relacional y en JSON
select * from asistente;
select * from asistenteV;

-- 2. Añadir otro asistente usando la vista dual, los datos se guardan automáticamente en la tabla relacional
insert into asistenteV values ('{"_id":3, "nombre":"Hermann"}');
commit;

select * from asistenteV;
select * from asistente;

-- 3. Los datos de las vistas duales también se pueden ver de forma relacional:
select data from inscripcionesV;

-- Extraer campos del JSON para ver la data en tabla 
select v.data.nombre, v.data.inscripciones[*].nombre_ponente
from inscripcionesV v;

-- 4. Corregir un error en los datos: 
select data
from ponenteV v
where v.data."_id" = 1;

update ponenteV v
set data = '{"_id":1,"nombre":"Beda","calificacion":7}'
where v.data."_id" = 1;

commit;

select data
from ponenteV v
where v.data."_id" = 1;

select v.data.nombre, v.data.inscripciones[*].nombre_ponente
from inscripcionesV v;


-- 4. Control granular:

update ponenteV v
set data = '{"_id":1,"nombre":"Beda","calificacion":11}'
where v.data."_id" = 1;


-- 5. Flexibilidad del esquema:
update asistenteV v
set v.data = '{"_id":3, "nombre":"Hermann", "apellido":"B"}'
where v.data."_id" = 3;

select v.data
from asistenteV v
where v.data."_id" = 3;

select * from asistente;


-- 6. Columnas generadas
create or replace JSON Duality view ponenteV as 
ponente @update @insert @delete {
_id           : id_ponente,
nombre        : nombre,
calificacion  : calificacion @noupdate,
sesiones      : sesiones {
    id_sesion     : id_sesion,
    nombre_sesion : nombre
},
numSesiones @generated (path : "$.sesiones.size()")
};

select json_serialize(data pretty) from ponenteV;


---- Parte 4: Bloqueo optimista

-- 1. Usar etags para el control de concurrencia optimista

-- Ejecutar esta consulta y copiar el resultado
select json_serialize(data pretty) 
from asistenteV v
where v.data."_id" = 2; 

update asistente
set nombre_asistente = 'Douglas'
where id_asistente = 2;

select json_serialize(data pretty) 
from asistenteV v
where v.data."_id" = 2; 


-- Ejecutar un UPDATE con el resultado copiado de la consulta anterior y añadiendo el campo 'cargo'
update asistenteV v
set data = '{
  "_id" : 2,
  "_metadata" :
  {
    "etag" : "5BE5D353486DDBE17E288B2CFF2B9C1F",
    "asof" : "000029B2F4CA37B1"
  },
  "nombre" : "Doug",
  "cargo" : "Gerente de Producto"
}'
where v.data."_id" = 2;

---- Parte 5: REST 

---- Parte 6: Limpiar las tablas y vistas
DROP TABLE inscripciones purge;
DROP TABLE sesiones purge;
DROP TABLE ponente purge;
DROP TABLE asistente purge;

DROP VIEW asistentev;
DROP VIEW ponentev;
DROP VIEW inscripcionesv;

