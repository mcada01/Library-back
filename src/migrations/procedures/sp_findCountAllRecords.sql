--SELECT * FROM sp_findCountAllRecords('2022-02-08 00:00:01','2022-02-25 23:59:59',null,null,null,null,null,null,null,null,null,null,null);
create or replace FUNCTION sp_findCountAllRecords(IN param_from date, IN param_to date, IN param_city INT, IN param_state INT,
IN param_record INT, IN param_user INT, IN param_observation INT, IN param_client INT, IN param_operator INT, IN param_isclient INT, IN param_isOperator INT, IN param_search TEXT,
IN param_high BOOL)
  returns TABLE (total INT) 
AS
$func$
  SELECT DISTINCT COUNT(1) 
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
        );
$func$ 
LANGUAGE sql;
