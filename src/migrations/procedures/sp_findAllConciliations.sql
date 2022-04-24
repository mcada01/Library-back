--SELECT * FROM sp_findAllConciliations('2022-02-14 00:00:01','2022-02-23 23:59:59',null,null,null,null);
create or replace FUNCTION sp_findAllConciliations(IN param_from date, IN param_to date, IN param_client INT, IN param_state INT, IN param_isclient INT, IN param_isOperator INT)
returns TABLE (IDCLIENTE TEXT,
        BARRA TEXT,
        CLIENTE TEXT,
        AMBITO TEXT,
        PRODUCTO TEXT,
        CNT TEXT,
        DESTINATARIO TEXT,
        DIRECCION TEXT,
        TELEFONO TEXT,
        DEPARTAMENTO TEXT,
		PROVINCIA TEXT,
        DISTRITO TEXT,
        MNT_DEPOSITAR TEXT,
        SUPERESTADO TEXT,
        MNT_REPARTO TEXT,
        IDEXTERNO TEXT,
		ORDER_DATE TEXT,
		STATE_DATE TEXT
)
AS
$func$

	SELECT DISTINCT COALESCE(A."idCompany"::text,'') AS IDCLIENTE, COALESCE(A."trackingId",'') AS BARRA, COALESCE(C."description",'') AS CLIENTE, '' AS AMBITO,
		COALESCE(P."name",'') AS PRODUCTO, COALESCE(OD."quantity"::text,'') AS CNT, COALESCE(A."name",'') AS DESTINATARIO,
		A."address" AS DIRECCIÓN,COALESCE(A."reference1",'') AS TELÉFONO,'' AS DEPARTAMENTO,COALESCE(CI."description",'') AS PROVINCIA,
		'' AS DISTRITO, COALESCE(A."declaredValue",'') AS MNT_DEPOSITAR,
		CASE WHEN A."state" = 7 THEN 'Entregado' 
		 WHEN A."state" = -1 THEN 'Falló' 
		 WHEN A."state" = 1 THEN 'Procesada' 
		 WHEN A."state" = 2 THEN 'Asignada' 
		 WHEN A."state" = 3 THEN 'Guía' 
		 WHEN A."state" = 4 THEN 'En tránsito a ciudad  destino' 
		 WHEN A."state" = 5 THEN 'Asignada a un mensajero' 
		 WHEN A."state" = 6 THEN 'En ruta/distribución' 
		 WHEN A."state" = 9 THEN 'Devuelto' 
		 WHEN A."state" = 8 THEN 'No entregado' 
		 WHEN A."state" = 9 THEN 'Devuelto'
        WHEN A."state" = 10 THEN 'Devuelto al remitente'
        WHEN A."state" = 11 THEN 'Alistamiento'
		ELSE '' END AS SUPERESTADO,'' AS MNT_REPARTO,
		COALESCE(O."externalId",'') AS IDEXTERNO,
		COALESCE(O."date"::text,'') AS ORDER_DATE,
	  	(SELECT COALESCE(AR."date"::text, '') 
		  FROM public."TBL_MTR_ADDRESS_RECORD" AR 
		  WHERE A."idAddress" = AR."idAddress"
		  ORDER BY AR.date DESC
		  LIMIT 1) AS STATE_DATE
	FROM public."TBL_MTR_ADDRESS" A
		left outer join public."TBL_MTR_ORDERS" O ON A."idAddress" = O."idAddress"
		left outer join public."TBL_MTR_ORDER_DETAILS" OD ON O."idOrder" = OD."idOrder"
		left outer join public."TBL_ROUTE" R ON A."idAddress" = R."idAddress"
		left outer join public."TBL_MTR_COMPANY" C ON A."idCompany" = C."idCompany"
		left outer join public."TBL_MTR_PRODUCTS" P ON OD."idProduct" = P."idProduct"
		left outer join public."TBL_MTR_CITY" CI ON A."idCity" = CI."idCity"
	WHERE O."date" between param_from and param_to AND 
		(param_client IS NULL OR A."idCompany" = param_client) AND 
        (param_state IS NULL OR R."state" = param_state) AND
        (param_isclient IS NULL OR  A."idCompany" = param_isclient) AND 
        (param_isOperator IS NULL OR  A."idOperator" = param_isOperator) AND
        A."deleted" = 0 AND A."isActive" = true
	ORDER BY BARRA ASC, STATE_DATE ASC;
    
$func$ 
LANGUAGE sql;
