--SELECT * FROM sp_findDownloadAllAddressFinished('2022-02-27 00:00:01','2022-03-02 23:59:59',null,null,null,null,null,null,null);
create or replace FUNCTION sp_findDownloadAllAddressFinished(IN param_from date, IN param_to date, IN param_city INT,
                                                             IN param_operator INT, IN param_isclient INT,
                                                             IN param_isOperator INT, IN param_search TEXT,
                                                             IN param_client INT,
                                                             IN param_user INT, IN param_close_confirm anyenum
)
    returns TABLE
            (
                state             TEXT,
                idOperator        INT,
                trackingId        TEXT,
                name              TEXT,
                address           TEXT,
                declaredValue     TEXT,
                client            TEXT,
                operator          TEXT,
                city              TEXT,
                quantity          TEXT,
                amount           TEXT,
                courier           TEXT
            )
AS
$func$

SELECT DISTINCT A."idAddress",
                CASE
                    WHEN AR."idState" = 7 THEN 'Entregado'
                    WHEN AR."idState" = 8 THEN 'No entregado'
                    END                                                                           AS state,
                A."idOperator",
                A."trackingId",
                A."name",
                A."address",
                A."declaredValue",
                COALESCE(CO."description", '')                                                    AS client,
                COALESCE(CO2."description", '')                                                   AS operator,
                COALESCE(C."description", '')                                                     AS city,
                A."createdAt"::date                                                               AS createdDate,
                COALESCE(AR."date"::text, '')                                                     AS stateDate,
                COALESCE(A."collection"::text, '')                                                AS amount,
                TMAF."type"::anyenum as addressFinishedState,
                CASE
                    WHEN AR."idState" IN (7, 8) THEN CONCAT(U."firstName", ' ', U."lastName")
                    ELSE '' END                                                                   AS courier
FROM public."TBL_MTR_ADDRESS" A
         INNER JOIN "TBL_MTR_ADDRESS_FINISHED" TMAF on A."idAddress" = TMAF."idAddress"
         LEFT OUTER JOIN public."TBL_MTR_ADDRESS_RECORD" AR ON A."idAddress" = AR."idAddress"
         LEFT OUTER JOIN public."TBL_MTR_USER" U ON AR."idUser" = U."idUser"
         LEFT OUTER JOIN public."TBL_MTR_CITY" C ON A."idCity" = C."idCity"
         LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO ON A."idCompany" = CO."idCompany"
         LEFT OUTER JOIN public."TBL_MTR_COMPANY" CO2 ON A."idOperator" = CO2."idCompany"
     WHERE AR."date"::date between param_from and param_to AND
     (param_city IS NULL OR C."idCity" = param_city) AND
     (param_user IS NULL OR U."idUser" = param_user) AND
     (param_client IS NULL OR A."idCompany" = param_client) AND
     (param_operator IS NULL OR A."idOperator" = param_operator) AND
     (param_isclient IS NULL OR  A."idCompany" = param_isclient) AND
     (param_isOperator IS NULL OR  A."idOperator" = param_isOperator) AND
     (param_close_confirm IS NULL OR  TMAF."type" = param_close_confirm) AND
            (param_search IS NULL OR param_search = 'null' OR
			(
            A."address" LIKE CONCAT('%',param_search,'%') OR
            A."trackingId" LIKE CONCAT('%',param_search,'%')
            )
        )
$func$
    LANGUAGE sql;
