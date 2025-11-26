---- Parte 1: Crear una tabla de vectores

-- 1: Crear la tabla
drop table if exists vector_table;  
create table if not exists vector_table (id number, v  vector);
desc vector_table;

-- 2: Añadir datos a la tabla
insert into vector_table values(1, '[5.238, -2.7, 7.93238, 8.472]'),
                  (2, '[-8.334, 48.20, 7.423, 3.673]'),
                  (3, '[0, 1, 0, 1, 0, 1, 0]');

select * from vector_table;

-- 2: Actualizar datos de la tabla
update vector_table 
set v ='[0]' where id = 1;

select * from vector_table;

-- 3: Eliminar datos de la tabla
delete from vector_table 
where id = 3;

select * from vector_table;
-- Operaciones prohibidas: https://docs.oracle.com/en/database/oracle/oracle-database/26/rnrdm/issues-all-platforms-2.html


---- Parte 2: Dimensiones y formatos

-- 1. Crear una tabla con dimensionalidad definida
drop table if exists vector_table_2;  
create table if not exists vector_table_2 (id number, v  vector(3, float32));
desc vector_table_2;

-- 2. Añadir data a la tabla:
insert into vector_table_2 
          values(1, '[0, 1, 2]'),
                (2, '[3, 4, 5]'),
                (3, '[6, 7, 8]');

select * from vector_table_2;

-- 3. ¿Qué pasa si intentamos añadir un vector con más o menos dimensiones?:
insert into vector_table_2
values (4, '[1, 0, 1, 0]');

-- 4. Crear una tabla con diferentes columnas de vectores, cada una con una dimensionalidad diferente:
create table if not exists vector_table_3
        (v1       vector(3, float64),
        v2        vector(3072, *),
        v3        vector(*, float32),
        v4        vector(*, *),
        v5        vector
        );

desc vector_table_3;


-- 5. Eliminar tablas vectoriales

DROP TABLE IF EXISTS vector_table;
DROP TABLE IF EXISTS vector_table_2;
DROP TABLE IF EXISTS vector_table_3;


---- Parte 3: Búsqueda por similitud

-- 1. Crear tablas
CREATE TABLE IF NOT EXISTS peliculas (
    pelicula_id NUMBER,
    titulo VARCHAR2(255) NOT NULL ANNOTATIONS (description 'Título de la película'),
    genero VARCHAR2(100) ANNOTATIONS (description 'Género de la película'),
    anio_estreno NUMBER(4) ANNOTATIONS (description 'Año en que se estrenó la película'),
    duracion_minutos NUMBER(3) ANNOTATIONS (description 'Duración de la película en minutos'),
    descripcion CLOB ANNOTATIONS (description 'Descripción detallada de la película'),
    vector_descripcion VECTOR ANNOTATIONS (description 'Contiene el valor de los embeddings de las descripciones de las películas después de pasarlas por el modelo'),
    director VARCHAR2(255) ANNOTATIONS (description 'Director de la película'),
 CONSTRAINT peliculas_pk PRIMARY KEY(pelicula_id)
);

CREATE TABLE IF NOT EXISTS clientes (
    cliente_id NUMBER ANNOTATIONS (description 'ID único para cada cliente'),
    nombre VARCHAR2(100) ANNOTATIONS (description 'Nombre del cliente'),
    apellido VARCHAR2(100) ANNOTATIONS (description 'Apellido del cliente'),
    correo VARCHAR2(255) UNIQUE NOT NULL ANNOTATIONS (description 'Correo electrónico del cliente'),
    fecha_registro DATE DEFAULT SYSDATE ANNOTATIONS (description 'Fecha en la que el cliente se registró'),
    tiene_suscripcion BOOLEAN ANNOTATIONS (description 'Indica si el cliente tiene una suscripción activa'),
 CONSTRAINT clientes_pk PRIMARY KEY (cliente_id)
);

CREATE TABLE IF NOT EXISTS calificaciones (
    calificacion_id NUMBER ANNOTATIONS (description 'ID único para cada calificación'),
    cliente_id NUMBER ANNOTATIONS (description 'ID del cliente que calificó'),
    pelicula_id NUMBER ANNOTATIONS (description 'ID de la película que fue calificada'),
    calificacion NUMBER(1) CHECK(calificacion BETWEEN 1 AND 5) ANNOTATIONS (description 'Calificación asignada, entre 1 y 5'),
    fecha_calificacion DATE DEFAULT SYSDATE ANNOTATIONS (description 'Fecha en que se realizó la calificación'),
 FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
 FOREIGN KEY (pelicula_id) REFERENCES peliculas(pelicula_id),
 CONSTRAINT calificaciones_pk PRIMARY KEY (calificacion_id)
);


-- 2.Añadir data a las tablas: 
INSERT INTO peliculas (pelicula_id, titulo, genero, anio_estreno, duracion_minutos, descripcion, vector_descripcion, director)
VALUES 
(1, 'El Gran Hotel Budapest', 'Comedia', 2014, 99, 
 'Ambientada en un famoso hotel europeo entre guerras, cuenta la historia del legendario conserje M. Gustave y su amistad con un joven empleado llamado Zero. La película combina aventura, humor y momentos conmovedores dentro del característico estilo visual de Wes Anderson.', NULL, 'Wes Anderson'),
(2, 'Superbad', 'Comedia', 2007, 113,
 'Superbad es una divertida comedia sobre dos inseparables amigos de secundaria que intentan asistir a una fiesta antes de graduarse. Su caótica búsqueda de alcohol los lleva a una serie de absurdas aventuras llenas de humor y torpeza adolescente.', NULL, 'Greg Mottola'),
(3, 'Muertos de Risa (Shaun of the Dead)', 'Comedia', 2004, 99,
 'Comedia británica que mezcla humor y zombis. Shaun intenta recuperar a su novia y reconciliarse con su madre justo cuando estalla un apocalipsis zombi. Llena de ingenio, sátira y reflexión sobre la madurez.', NULL, 'Edgar Wright'),
(4, 'En Brujas (In Bruges)', 'Comedia', 2008, 107,
 'Dos asesinos a sueldo se esconden en la ciudad medieval de Brujas tras un trabajo fallido. La película combina humor negro, drama y dilemas morales con una escenografía deslumbrante.', NULL, 'Martin McDonagh'),
(5, 'Chicas Pesadas (Mean Girls)', 'Comedia', 2004, 97,
 'Cady Heron entra por primera vez a una escuela en EE. UU. y se ve atrapada en la jerarquía social adolescente dominada por "Las Plásticas". Una sátira brillante sobre la vida escolar y la presión social.', NULL, 'Mark Waters'),
(6, 'Hermanastros (Step Brothers)', 'Comedia', 2008, 98,
 'Dos hombres inmaduros se ven obligados a convivir cuando sus padres se casan. Lo que empieza con odio termina en una amistad absurda llena de situaciones ridículas y memorables.', NULL, 'Adam McKay'),
(7, 'El Reportero (Anchorman)', 'Comedia', 2004, 94,
 'Una sátira sobre el mundo de las noticias en los años 70. Ron Burgundy, un egocéntrico presentador, se enfrenta a una nueva compañera que desafía su machismo y su carrera.', NULL, 'Adam McKay'),
(8, 'Sin Lugar para los Débiles (No Country for Old Men)', 'Thriller', 2007, 122,
 'Un hombre encuentra una maleta con dinero tras un fallido intercambio de drogas, desatando una cacería mortal con un asesino implacable. Un retrato oscuro sobre el destino y la violencia.', NULL, 'Joel Coen, Ethan Coen'),
(9, 'El Gran Lebowski', 'Comedia', 1998, 117,
 'Jeff "El Nota" Lebowski es confundido con un millonario y termina involucrado en un absurdo caso de secuestro. Una comedia de culto con personajes excéntricos y humor surrealista.', NULL, 'Joel Coen'),
(10, 'Memento', 'Thriller', 2000, 113,
 'Leonard, un hombre con pérdida de memoria a corto plazo, intenta encontrar al asesino de su esposa. La historia está contada en orden inverso, sumergiendo al espectador en su confusión y obsesión.', NULL, 'Christopher Nolan');



INSERT INTO clientes (cliente_id, nombre, apellido, correo, fecha_registro, tiene_suscripcion)
VALUES 
(1, 'Juan', 'Pérez', 'juan.perez@ejemplo.com', SYSDATE, TRUE),
(2, 'Ana', 'Gómez', 'ana.gomez@ejemplo.com', SYSDATE, TRUE),
(3, 'Laura', 'Jiménez', 'laura.jimenez@ejemplo.com', SYSDATE, TRUE),
(4, 'Pedro', 'Ruiz', 'pedro.ruiz@ejemplo.com', SYSDATE, TRUE),
(5, 'Carlos', 'Díaz', 'carlos.diaz@ejemplo.com', SYSDATE, TRUE);



INSERT INTO calificaciones (calificacion_id, cliente_id, pelicula_id, calificacion, fecha_calificacion)
VALUES
(1, 1, 1, 5, SYSDATE),
(2, 2, 3, 4, SYSDATE),
(3, 3, 5, 4, SYSDATE),
(4, 4, 8, 5, SYSDATE),
(5, 5, 10, 3, SYSDATE);



SELECT * FROM peliculas;
SELECT * FROM clientes;
SELECT * FROM calificaciones;

-- 3. Cargar el modelo de embeddings:
-- https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx
-- BEGIN
--     DBMS_CLOUD.GET_OBJECT(                            
--         credential_name => NULL,
--         directory_name => 'DATA_PUMP_DIR',
--         object_uri => 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/eLddQappgBJ7jNi6Guz9m9LOtYe2u8LWY19GfgU8flFK4N9YgP4kTlrE9Px3pE12/n/adwc4pm/b/OML-Resources/o/all_MiniLM_L12_v2.onnx');
-- END;


BEGIN
    DBMS_VECTOR.LOAD_ONNX_MODEL(
        directory => 'DATA_PUMP_DIR',
        file_name => 'all_MiniLM_L12_v2.onnx',
        model_name => 'ALL_MINILM_L12_V2');
END;

SELECT model_name, algorithm, mining_function, model_size
FROM user_mining_models 
WHERE model_name='ALL_MINILM_L12_V2';


-- 4. Convertir las descripciones a vectores y añadirlas a la columna 'questions':
SELECT VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING descripcion as data) AS embedding
FROM peliculas WHERE pelicula_id = 1;


UPDATE peliculas
SET vector_descripcion = VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING descripcion AS data);


SELECT * FROM peliculas
ORDER BY pelicula_id;


-- 5. Hacer búsquedas de similitud

-- Películas que podrían gustarle a una adolescente
SELECT titulo, genero, director, descripcion
FROM peliculas 
ORDER BY VECTOR_DISTANCE(
    vector_descripcion, 
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'Sugerir películas que le podrían gustar a mi sobrina adolescente' AS data),
    EUCLIDEAN
)
FETCH FIRST 4 ROWS ONLY;

-- Películas ambientadas en la época medieval
SELECT titulo, genero, director, descripcion
FROM peliculas 
ORDER BY VECTOR_DISTANCE(
    vector_descripcion, 
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'Me gustan las películas ambientadas en la época medieval, ¿qué me recomiendas?' AS data),
    EUCLIDEAN
)
FETCH FIRST 4 ROWS ONLY;

-- Películas con humor pero con temas oscuros o serios
SELECT titulo, genero, director, descripcion
FROM peliculas 
ORDER BY VECTOR_DISTANCE(
    vector_descripcion, 
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'Recomiéndame películas con temas oscuros o serios, pero que aún tengan humor' AS data),
    EUCLIDEAN
)
FETCH FIRST 4 ROWS ONLY;

-- Películas que transmitan buenas sensaciones
SELECT titulo, genero, director, descripcion
FROM peliculas 
ORDER BY VECTOR_DISTANCE(
    vector_descripcion, 
    VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING '¿Qué películas te hacen sentir bien o te levantan el ánimo?' AS data),
    EUCLIDEAN
)
FETCH FIRST 4 ROWS ONLY;



-- Eliminar tablas del ejercicio de películas

DROP TABLE IF EXISTS calificaciones;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS peliculas;


-- Eliminar el modelo de embeddings

BEGIN
    DBMS_VECTOR.DROP_ONNX_MODEL('ALL_MINILM_L12_V2');
END;


-- Eliminar el archivo ONNX descargado al directorio

-- BEGIN
--     UTL_FILE.FREMOVE('DATA_PUMP_DIR', 'all_MiniLM_L12_v2.onnx');
-- END;



