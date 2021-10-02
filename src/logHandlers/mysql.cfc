component output="false" accessors="true" hint="MySQL database handler for logging API interactions." {
	property name="datasource" type="string";
	property name="tableName" type="string";

	public mysql function init(
		required string datasource="",
		required string tableName="boxApiLog"
	) output=false {
		variables.datasource = arguments.datasource;
		variables.tableName = arguments.tableName;

		return this;
	}

	public numeric function setLog(
		required string url,
		required string method,
		required boolean getasbinary="no",
		required array httpParams="no"
	) output=false {
		local.return = -1;
		try {
			//  QUERY - INSERT
			queryExecute(
				"INSERT INTO #variables.tableName#
				(
					url,
					method,
					getasbinary,
					httpParams,
					datetimeSent
				) VALUES (
					:url,
					:method,
					:getasbinary,
					:httpParams,
					:datetimeSent
				);", {
					url = {
						value="#arguments.url#",
						cfsqltype="VARCHAR"
					},
					method = {
						value="#arguments.method#",
						cfsqltype="VARCHAR"
					},
					getasbinary = {
						value="#arguments.getasbinary#",
						cfsqltype="BIT"
					},
					httpParams = {
						value="#reReplace(SerializeJSON(arguments.httpParams), 'Bearer ([^"]*)"', 'Bearer <access_token>"')#",
						cfsqltype="VARCHAR"
					},
					datetimeSent = {
						value="#now()#",
						cfsqltype="TIMESTAMP"
					}
				},
				{
					datasource=variables.datasource,
					result="local.insert"
				}
			);
			local.return = local.insert.generatedKey;
		} catch (any cfcatch) {
			rethrow;
		}
		return local.return;
	}

	public void function updateLog(
		required numeric logID = 0,
		string responseCode = "",
		string response = ""
	) output=false {
		try {
			//  QUERY - UPDATE
			queryExecute(
				"UPDATE
					#variables.tableName#
				SET
					responseCode = :responseCode,
					response = :response,
					datetimeReceived = :datetimeReceived
				WHERE
					boxApiLogID = :boxApiLogID",
				{
					responseCode = {
						value="#arguments.responseCode#",
						cfsqltype="VARCHAR"
					},
					response = {
						value="#arguments.response#",
						cfsqltype="VARCHAR"
					},
					datetimeReceived = {
						value="#now()#",
						cfsqltype="TIMESTAMP"
					},
					boxApiLogID = {
						value="#arguments.logID#",
						cfsqltype="INTEGER"
					}
				},
				{
					datasource=variables.datasource
				}
			);
		} catch (any cfcatch) {
			rethrow;
		}
		return;
	}

	public void function deleteLog(
		required numeric logID = 0
	) output=false {
		try {
			//  QUERY - DELETE
			queryExecute(
				"DELETE
				FROM #variables.tableName#
				WHERE
					boxApiLogID = :boxApiLogID",
				{
					boxApiLogID = {
						value="#arguments.logID#",
						cfsqltype="INTEGER"
					}
				},
				{
					datasource=variables.datasource
				}
			);
		} catch (any cfcatch) {
			rethrow;
		}
		return;
	}
}
