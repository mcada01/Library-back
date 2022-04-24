--SELECT * FROM sp_findAllAddresses(null,null,'2022-02-27 00:00:01','2022-03-02 23:59:59');
create or replace FUNCTION sp_findAllAddresses(IN param_isclient INT, IN param_isOperator INT, IN param_from date, IN param_to date )
returns TABLE (
    idAddress INT,
    trackingId TEXT,
    name TEXT,
    address TEXT,
    reference1 TEXT,
    reference2 TEXT,
    clientTrackingId TEXT,
    declaredValue TEXT,
    state TEXT,
    city TEXT,
    neighborhood TEXT,
    client TEXT,
    senderName TEXT,
    collection TEXT,
    product TEXT,
    operator TEXT,
    externalId VARCHAR(100)
)
AS
$func$

    SELECT A."idAddress",A."trackingId",A."name",A."address",A."reference1",A."reference2",A."clientTrackingId",
		REPLACE(A."declaredValue",'�','') AS declaredValue,
        CASE WHEN A."state" = -1 THEN 'Falló'
            WHEN A."state" = 1 THEN 'Procesada'
            WHEN A."state" = 2 THEN 'Asignada'
            WHEN A."state" = 3 THEN 'Guía'
            WHEN A."state" = 4 THEN 'En transito a ciudad destino'
            WHEN A."state" = 5 THEN 'Asignada a un mensajero'
            WHEN A."state" = 6 THEN 'En ruta/distribución'
            WHEN A."state" = 7 THEN 'Entregado'
            WHEN A."state" = 8 THEN 'No entregado'
            WHEN A."state" = 9 THEN 'Devuelto'
            WHEN A."state" = 10 THEN 'Devuelto al remitente'
            WHEN A."state" = 11 THEN 'Alistamiento'
            END AS state,
		COALESCE(C."description",'') AS city,COALESCE(N."description",'') AS neighborhood,COALESCE(CO."description",'') AS client,
		COALESCE(REPLACE(A."senderName",'�',''),'') AS senderName, COALESCE(REPLACE(A."collection",'�',''),'') AS collection,
        COALESCE(REPLACE(A."product",'�',''),'') AS product,COALESCE(CO2."description",'') AS operator,
		COALESCE(O."externalId") AS externalId
    FROM public."TBL_MTR_ADDRESS" A
		LEFT OUTER JOIN public."TBL_MTR_ORDERS" O ON A."idAddress" = O."idAddress"
		LEFT OUTER JOIN public."TBL_MTR_CITY" C ON A."idCity" = C."idCity"
		LEFT OUTER JOIN public."TBL_MTR_NEIGHBORHOOD" N ON A."idNeighborhood" = N."idNeighborhood"
		LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO ON A."idCompany" = CO."idCompany"
        LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO2 ON A."idOperator" = CO2."idCompany"
	WHERE (param_isclient IS NULL OR  A."idCompany" = param_isclient) AND
        (param_isOperator IS NULL OR  A."idOperator" = param_isOperator) AND
        A."deleted" = 0  AND A."createdAt"::date between param_from and param_to;

$func$ 
LANGUAGE sql;
