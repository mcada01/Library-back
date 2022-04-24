--SELECT * FROM sp_findCountAllSessions('2022-02-22',null,'feature:courier',null,null,null);
create or replace FUNCTION sp_findCountAllSessions(IN param_date date, IN param_city INT, IN param_permission TEXT, IN param_isclient INT, IN param_isOperator INT, IN param_search TEXT)
returns TABLE (total INT) 
AS
$func$

		SELECT count(distinct R."idUser")
			FROM public."TBL_ROUTE" R 
			INNER JOIN public."TBL_MTR_ADDRESS" A ON R."idAddress" = A."idAddress"
			INNER JOIN public."TBL_MTR_USER" U ON R."idUser" = U."idUser"
			INNER JOIN public."TBL_MTR_PERMISSION_ROLE" PR ON U."idRole" = PR."idRole"
			INNER JOIN public."TBL_MTR_PERMISSION" P ON PR."idPermission" = P."idPermission"
			LEFT OUTER JOIN public."TBL_MTR_CITY" C ON A."idCity" = C."idCity"
			LEFT OUTER JOIN public."TBL_SESSION" S ON R."idUser" = S."idUser"
		WHERE R."assignedDate" = param_date AND
			(param_city IS NULL OR C."idCity" = param_city) AND
			(param_isclient IS NULL OR  A."idCompany" = param_isclient) AND 
			(param_isOperator IS NULL OR  A."idOperator" = param_isOperator) AND 
			(param_search IS NULL OR 
			  (CONCAT(U."firstName",' ',CASE WHEN U."secondName" IS NOT NULL THEN  U."secondName" ELSE '' END,' ',U."lastName",' ',CASE WHEN U."secondLastName" IS NOT NULL THEN U."secondLastName" ELSE '' END)) LIKE CONCAT('%',param_search,'%') OR
			  (C."description" LIKE CONCAT('%',param_search,'%')) OR
			  (S."updatedAt"::text LIKE CONCAT('%',param_search,'%'))
			) AND
			R."state" IN (5,6,7,8,9) AND
			P."name" = param_permission AND
			A."deleted" = 0;
	
$func$ 
LANGUAGE sql;
