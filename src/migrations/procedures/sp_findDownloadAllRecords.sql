--SELECT * FROM sp_findDownloadAllRecords('2022-02-27 00:00:01','2022-03-02 23:59:59',null,null,null,null,null,null,null,null,null,null,null);
create or replace FUNCTION sp_findDownloadAllRecords(IN param_from date, IN param_to date, IN param_city INT, IN param_state INT,
IN param_record INT, IN param_user INT, IN param_observation INT, IN param_client INT, IN param_operator INT, IN param_isclient INT, IN param_isOperator INT, IN param_search TEXT,
IN param_high BOOL)
  returns TABLE (idAddress INT,
        state TEXT,
        idOperator INT,
        trackingId TEXT,
        name TEXT,
        address TEXT,
        reference1 TEXT,
        reference2 TEXT,
        clientTrackingId TEXT,
        declaredValue TEXT,
        routeObservation TEXT,
        detailObservation TEXT,
		    record TEXT,
		    comment TEXT,
        descriptionRecord TEXT,
        neighborhood TEXT,
        zone TEXT,
        client TEXT,
        operator TEXT,
        city TEXT,
        createdDate TEXT,
        hourDate TEXT,
        externalId TEXT,
        orderDate TEXT,
        stateDate TEXT,
        product TEXT,
        quantity TEXT,
        ammount TEXT,
		    attempt INT,
		    delay INT,
        courier TEXT,
        finishedType      TEXT,
        finishedDescription TEXT) 
AS
$func$

  SELECT DISTINCT A."idAddress",
  	  CASE WHEN AR."idState" = -1 THEN 'Falló'
	  	  WHEN AR."idState" = 1 THEN 'Procesada'
        WHEN AR."idState" = 2 THEN 'Asignada a un operador'
        WHEN AR."idState" = 3 THEN 'Sin guía'
        WHEN AR."idState" = 4 THEN 'En tránsito a ciudad destino'
        WHEN AR."idState" = 5 THEN 'Asignada a un mensajero'
        WHEN AR."idState" = 6 THEN 'En ruta/distribución'
        WHEN AR."idState" = 7 THEN 'Entregado'
        WHEN AR."idState" = 8 THEN 'No entregado'
        WHEN AR."idState" = 9 THEN 'Devuelto'
        WHEN AR."idState" = 10 THEN 'Devuelto al remitente'
        WHEN AR."idState" = 11 THEN 'Alistamiento'
      END AS state,
      A."idOperator",A."trackingId",A."name",A."address",A."reference1",A."reference2",A."clientTrackingId",A."declaredValue",
      COALESCE(N."description",'') AS routeObservation,COALESCE(AR."txtNote",'') AS detailObservation,COALESCE(NOTE."description",'') AS record,
	    COALESCE(A."comment",'') AS comment,
      COALESCE(AR."txtNote",'') AS descriptionRecord,COALESCE(Ne."description",'') AS neighborhood,COALESCE(Z."description",'') AS zone,
      COALESCE(CO."description",'') AS client, COALESCE(CO2."description",'') AS operator,
      COALESCE(C."description",'') AS city,
      DATE(A."createdAt") AS createdDate,
      CONCAT(EXTRACT(HOUR FROM A."createdAt"),':',EXTRACT(MINUTE FROM A."createdAt")) AS hourDate,
      COALESCE(O."externalId", '') AS externalId,
      COALESCE(O."date"::text,'') AS orderDate,
      COALESCE(AR."date"::text, '') AS stateDate,
      COALESCE(P."name", '') AS product,
      COALESCE(OD."quantity"::text,'') AS quantity,
      COALESCE(A."collection"::text,'') AS ammount,
	  CASE WHEN (SELECT COUNT(*) FROM public."TBL_MTR_ADDRESS_RECORD" AAR WHERE AAR."idAddress" = A."idAddress" AND AAR."idState" IN (7,8)) = 0 THEN 1
	  	ELSE (SELECT COUNT(*) FROM public."TBL_MTR_ADDRESS_RECORD" AAR WHERE AAR."idAddress" = A."idAddress" AND AAR."idState" IN (7,8)) 
		END AS attempt,
	  COALESCE((SELECT (SELECT DATE(AAR."date") FROM public."TBL_MTR_ADDRESS_RECORD" AAR WHERE AAR."idAddress" = A."idAddress" AND AAR."idState" IN (8,9) ORDER BY AAR."date" DESC LIMIT 1) - 
			   (SELECT CASE WHEN EXISTS(SELECT DATE(R2."assignedDate") FROM public."TBL_ROUTE" R2 WHERE R2."idAddress" = A."idAddress" ORDER BY R2."assignedDate" ASC LIMIT 1) 
							THEN (SELECT DATE(R2."assignedDate") FROM public."TBL_ROUTE" R2 WHERE R2."idAddress" = A."idAddress" ORDER BY R2."assignedDate" ASC LIMIT 1) 
					ELSE (SELECT DATE(AAR2."date") FROM public."TBL_MTR_ADDRESS_RECORD" AAR2 WHERE AAR2."idAddress" = A."idAddress" AND AAR2."idState" = 6 ORDER BY AAR2."date" ASC LIMIT 1)
					END)),0) AS delay,
      CASE WHEN AR."idState" IN (5,6,7,8,9,10) THEN CONCAT(U."firstName",' ',U."lastName")
        ELSE '' END AS courier,
      COALESCE(AF.type::text, '') as finishedType,
      COALESCE(AF.description, '') as finishedDescription
    FROM public."TBL_MTR_ADDRESS" A 
        LEFT OUTER JOIN public."TBL_ROUTE" R ON A."idAddress" = R."idAddress" 
        LEFT OUTER JOIN public."TBL_MTR_ADDRESS_RECORD" AR ON A."idAddress" = AR."idAddress"
        LEFT OUTER JOIN public."TBL_MTR_CITY" C ON A."idCity" = C."idCity"
        LEFT OUTER JOIN public."TBL_MTR_USER" U ON AR."idUser" = U."idUser"
        LEFT OUTER JOIN public."TBL_RECORD" N ON AR."idRecord" = N."idRecord"
 		LEFT OUTER JOIN public."TBL_MTR_NOTES" NOTE ON AR."idNote" = NOTE."idNote"
        LEFT OUTER JOIN public."TBL_MTR_NEIGHBORHOOD" Ne ON A."idNeighborhood" = Ne."idNeighborhood"
        LEFT OUTER JOIN public."TBL_MTR_ZONE" Z ON A."idZone" = Z."idZone"
        LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO ON A."idCompany" = CO."idCompany"
        LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO2 ON A."idOperator" = CO2."idCompany"
        LEFT OUTER JOIN public."TBL_MTR_ORDERS" O ON A."idAddress" = O."idAddress"
        LEFT OUTER JOIN public."TBL_MTR_ORDER_DETAILS" OD ON O."idOrder" = OD."idOrder"
        LEFT OUTER JOIN public."TBL_MTR_PRODUCTS" P ON OD."idProduct" = P."idProduct"
        LEFT OUTER JOIN public."TBL_MTR_ADDRESS_FINISHED" AF ON A."finishedId" = AF."id"
	  WHERE AR."date"::date between param_from and param_to AND
        (param_city IS NULL OR C."idCity" = param_city) AND
        (param_state IS NULL OR AR."idState" = param_state) AND
        (param_user IS NULL OR U."idUser" = param_user) AND 
        (param_client IS NULL OR A."idCompany" = param_client) AND 
        (param_operator IS NULL OR A."idOperator" = param_operator) AND
        (param_isclient IS NULL OR  A."idCompany" = param_isclient) AND 
        (param_isOperator IS NULL OR  A."idOperator" = param_isOperator) AND 
        (param_record IS NULL OR  N."idRecord" = param_record) AND 
		(param_high IS NULL OR param_high = false OR (N."description" = 'Cliente no recibe')) AND
        (param_search IS NULL OR param_search = 'null' OR
			(
            R."idAddress"::text LIKE CONCAT('%',param_search,'%') OR
            A."address" LIKE CONCAT('%',param_search,'%') OR
            C."description" LIKE CONCAT('%',param_search,'%') OR
            CO."description" LIKE CONCAT('%',param_search,'%') OR
            CO2."description" LIKE CONCAT('%',param_search,'%') OR
            A."name" LIKE CONCAT('%',param_search,'%') OR
            A."reference1" LIKE CONCAT('%',param_search,'%') OR
            A."reference2" LIKE CONCAT('%',param_search,'%') OR
            A."trackingId" LIKE CONCAT('%',param_search,'%') OR
            A."clientTrackingId" LIKE CONCAT('%',param_search,'%') OR
            A."declaredValue" LIKE CONCAT('%',param_search,'%') OR
            A."state"::text LIKE CONCAT('%',param_search,'%') OR
            Ne."description" LIKE CONCAT('%',param_search,'%') OR
            Z."description" LIKE CONCAT('%',param_search,'%') OR
            N."description" LIKE CONCAT('%',param_search,'%')
            ) 
        )
    ORDER BY routeObservation ASC;
	
$func$ 
LANGUAGE sql;
