---- Parte 1: Habilitar SQL Firewall

-- 1: Habilitar SQL Firewall desde el usuario admin
EXEC DBMS_SQL_FIREWALL.ENABLE;

-- 2: Iniciar la captura para un usuario
BEGIN
    DBMS_SQL_FIREWALL.CREATE_CAPTURE(
        username => '',
        top_level_only => TRUE,
        start_capture => TRUE
    );
END;
/

-- 3: Desde otro usuario ejecutar operaciones SQL típicas

-- 4: Detener la captura para el usuario
EXEC DBMS_SQL_FIREWALL.STOP_CAPTURE('');


---- Parte 2: Revisar los datos capturados

-- 1: Revisar los datos capturados
SELECT sql_text
FROM DBA_SQL_FIREWALL_CAPTURE_LOGS
WHERE username = '';

-- 2: Revisar la 'Allow list' que debe estar inicialmente vacía
SELECT sql_text
FROM DBA_SQL_FIREWALL_ALLOWED_SQL
WHERE username = '';

-- 3: Convertir los logs que tenemos en la lista permitida
EXEC DBMS_SQL_FIREWALL.GENERATE_ALLOW_LIST('');

-- 4: Habilitar la lista permitida para que solo los SQL de la lista puedan entrar a la DB
EXEC DBMS_SQL_FIREWALL.ENABLE_ALLOW_LIST(username=>'', enforce=>DBMS_SQL_FIREWALL.ENFORCE_SQL, block=>TRUE);

-- 5. Volver a ejecutar un SQL desde el otro usuario, que sea uno no permitido

-- 6. Volver al usuario admin y revisar la violación
SELECT SQL_TEXT, FIREWALL_ACTION, IP_ADDRESS, CAUSE, OCCURRED_AT
FROM DBA_SQL_FIREWALL_VIOLATIONS WHERE USERNAME = '';

-- 7. Deshabilitar la lista permitida:
EXEC DBMS_SQL_FIREWALL.DISABLE_ALLOW_LIST(username=>'');