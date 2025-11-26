---- Parte 1: Crear tablas e insertar datos

-- 1: Crear la tabla customers
DROP TABLE if exists customer_relationships CASCADE CONSTRAINTS;
DROP TABLE if exists customers CASCADE CONSTRAINTS;

CREATE TABLE CUSTOMERS 
    ( 
    CUSTOMER_ID  NUMBER , 
    FIRST_NAME   VARCHAR2 (100) , 
    LAST_NAME    VARCHAR2 (100) , 
    EMAIL        VARCHAR2 (255)  NOT NULL , 
    SIGNUP_DATE  DATE DEFAULT SYSDATE , 
    HAS_SUB      BOOLEAN , 
    DOB          DATE , 
    ADDRESS      VARCHAR2 (200) , 
    ZIP          VARCHAR2 (10) , 
    PHONE_NUMBER VARCHAR2 (20) , 
    CREDIT_CARD  VARCHAR2 (20) 
    ) ;


INSERT INTO customers (customer_id, first_name, last_name, email, signup_date, has_sub, dob, address, zip, phone_number, credit_card)
VALUES
    (1, 'John', 'Doe', 'john.doe@example.com', SYSDATE, TRUE, NULL, NULL, NULL, NULL, NULL),
    (2, 'Jane', 'Smith', 'jane.smith@example.com', SYSDATE, TRUE, NULL, NULL, NULL, NULL, NULL),
    (3, 'Alice', 'Johnson', 'alice.johnson@example.com', SYSDATE, TRUE, NULL, NULL, NULL, NULL, NULL),
    (4, 'Bob', 'Brown', 'bob.brown@example.com', SYSDATE, TRUE, NULL, NULL, NULL, NULL, NULL),
    (5, 'Charlie', 'Davis', 'charlie.davis@example.com', SYSDATE, TRUE, NULL, NULL, NULL, NULL, NULL),
    (6, 'David', 'Wilson', 'david.wilson@example.com', SYSDATE, TRUE, TO_DATE('1985-08-15', 'YYYY-MM-DD'), '123 Elm Street', '90210', '555-1234', '4111111111111111'),
    (7, 'Jim', 'Brown', 'jim.brown@example.com', SYSDATE, TRUE, TO_DATE('1988-01-01', 'YYYY-MM-DD'), '456 Maple Street', '12345', NULL, NULL),
    (8, 'Suzy', 'Brown', 'suzy.brown@example.com', SYSDATE, TRUE, TO_DATE('1990-01-01', 'YYYY-MM-DD'), '123 Maple Street', '12345', '555-1234', '4111111111111111');



-- 2: Crear la tabla customers_relationships
CREATE TABLE if not exists customer_relationships(
    id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) not null constraint rel_pk primary key,
    source_id NUMBER,
    target_id NUMBER,
    relationship VARCHAR2(100));

INSERT INTO customer_relationships (SOURCE_ID, TARGET_ID, RELATIONSHIP)
VALUES
    (8, 7, 'Married'),
    (7, 8, 'Married'),
    (7, 4, 'Brother'),
    (4, 7, 'Brother'),
    (1, 2, 'Friend'),
    (3, 5, 'Colleague'),
    (6, 4, 'Neighbor'),
    (7, 6, 'Friend'),
    (6, 7, 'Friend'),
    (7, 3, 'Friend'),
    (3, 7, 'Friend'),
    (7, 1, 'Friend'),
    (1, 7, 'Friend');


---- Parte 2: Crear los property graphs

-- 1: Crear un Property Graph que modele la relación entre los clientes
DROP PROPERTY GRAPH IF EXISTS moviestreams_pg;

create property graph moviestreams_pg
vertex tables (
    customers
    key(customer_id)
    label customer
    properties (customer_id, first_name, last_name)
)
edge tables (
    customer_relationships as related
    key (id)
    source key(source_id) references customers(customer_id)
    destination key(target_id) references customers(customer_id)
    properties (id, relationship)
)

---- Parte 3: Trabajar en Graph Studio 

---- Parte 4: Eliminar los recursos creados
drop table if exists customer_relationships CASCADE CONSTRAINTS;
drop table if exists customers CASCADE CONSTRAINTS;
drop property graph moviestreams_pg;