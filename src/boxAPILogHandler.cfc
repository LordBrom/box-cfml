/**
 * Submits api log information to the database
 */
component output="false" hint="Submits api log information to the database" {

	public boxAPILogHandler function init(required string datasource="", required string tableName="", required boolean createTable="false") output=false {
		variables.datasource = arguments.datasource;
		variables.tableName  = arguments.tableName;
		if ( arguments.createTable ) {
			createLogTable();
		}
		return this;
	}

	/**
	 * Adds a BoxAPI log record.
	 */
	public numeric function setLog(required string url, required string method, required boolean getasbinary="no", required array httpParams="no") output=false {
		local.return = -1;
		try {
			//  QUERY - INSERT
			cfquery( datasource=variables.datasource, result="local.ins" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("INSERT INTO [#variables.tableName#]
				(
					url,
					method,
					getasbinary,
					httpParams,
					datetimeSent
				)
				VALUES (");
				cfqueryparam( cfsqltype="CF_SQL_VARCHAR", value=arguments.url );

				writeOutput(",");
				cfqueryparam( cfsqltype="CF_SQL_VARCHAR", value=arguments.method );

				writeOutput(",");
				cfqueryparam( cfsqltype="CF_SQL_BIT", value=arguments.getasbinary );

				writeOutput(",");
				cfqueryparam( cfsqltype="CF_SQL_VARCHAR", value=reReplace(SerializeJSON(arguments.httpParams), 'Bearer ([^".]*)"', 'Bearer <access_token>"') );

				writeOutput(",");
				cfqueryparam( cfsqltype="CF_SQL_TIMESTAMP", value=now() );

				writeOutput(")");
			}
			local.return = local.ins.generatedKey;
		} catch (any cfcatch) {
			if ( structKeyExists(application,'bugTracker') ) {
				exceptionStruct = cfcatch;
				extraInfoStruct = structNew();
				extraInfoStruct._callStack = CallStackGet();
				extraInfoStruct.arguments  = arguments;
				extraInfoStruct.local      = local;
				extraInfoStruct.variables  = variables;
				application.bugTracker.notifyService(
						message      = "Error logging API interaction to [#variables.tableName#] on #cgi.server_name#",
						exception    = exceptionStruct,
						ExtraInfo    = extraInfoStruct,
						severityCode = "error"
					);
			} else {
				rethrow;
			}
		}
		return local.return;
	}

	/**
	 * Updates a log with response data.
	 */
	public void function updateLog(required numeric logID, string responseCode, any response) {
		try {
			//  Update log event with response
			cfquery( datasource=variables.datasource, result="local.update" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("UPDATE [#variables.tableName#]
				SET");
				if ( structKeyExists(arguments, "responseCode") ) {

					writeOutput("responseCode =");
					cfqueryparam( cfsqltype="CF_SQL_VARCHAR", value=arguments.responseCode );

					writeOutput(",");
				}
				if ( structKeyExists(arguments, "response") ) {

					writeOutput("response =");
					cfqueryparam( cfsqltype="CF_SQL_VARCHAR", value=serializeJSON(arguments.response) );

					writeOutput(",");
				}

				writeOutput("datetimeReceived=getDate()
				WHERE
					boxApiLogID =");
				cfqueryparam( cfsqltype="CF_SQL_INTEGER", value=arguments.logID );
			}
		} catch (any cfcatch) {
			if ( structKeyExists(application,'bugTracker') ) {
				exceptionStruct = cfcatch;
				extraInfoStruct = structNew();
				extraInfoStruct._callStack = CallStackGet();
				extraInfoStruct.arguments  = arguments;
				extraInfoStruct.local      = local;
				extraInfoStruct.variables  = variables;
				application.bugTracker.notifyService(
					   message      = "Error UPDATING API log to [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					);
			} else {
				rethrow;
			}
		}
		return;
	}

	/**
	 * Deletes a log.
	 */
	public void function hardDeleteLog(required numeric logID) {
		try {
			//  Update log event with response
			cfquery( datasource=variables.datasource, result="local.update" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("DELETE FROM [#variables.tableName#]
				WHERE
					boxApiLogID =");
				cfqueryparam( cfsqltype="CF_SQL_INTEGER", value=arguments.logID );
			}
		} catch (any cfcatch) {
			if ( structKeyExists(application,'bugTracker') ) {
				exceptionStruct = cfcatch;
				extraInfoStruct = structNew();
				extraInfoStruct._callStack = CallStackGet();
				extraInfoStruct.arguments  = arguments;
				extraInfoStruct.local      = local;
				extraInfoStruct.variables  = variables;
				application.bugTracker.notifyService(
					   message      = "Error DELETING API log from [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					);
			} else {
				rethrow;
			}
		}
		return;
	}

	/**
	 * Creates the log database table, if it doesn't already exist.
	 */
	public void function createLogTable() {
		try {
			//  Update log event with response
			cfquery( datasource=variables.datasource, result="local.update" ) { //Note: queryExecute() is the preferred syntax but this syntax is easier to convert generically

				writeOutput("IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#variables.tableName#]') AND type in (N'U'))
				BEGIN
					CREATE TABLE [dbo].[boxApiLog](
						[boxApiLogID] [int] IDENTITY(1,1) NOT NULL,
						[url] [varchar](max) NOT NULL,
						[method] [varchar](max) NOT NULL,
						[getasbinary] [bit] NOT NULL,
						[httpParams] [varchar](max) NULL,
						[datetimeSent] [datetime] NOT NULL,
						[response] [text] NULL,
						[responseCode] [varchar](50) NULL,
						[datetimeReceived] [datetime] NULL,
					 CONSTRAINT [PK_boxApiLog] PRIMARY KEY CLUSTERED
					(
						[boxApiLogID] ASC
					)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
					) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
				END");
			}
		} catch (any cfcatch) {
			if ( structKeyExists(application,'bugTracker') ) {
				exceptionStruct = cfcatch;
				extraInfoStruct = structNew();
				extraInfoStruct._callStack = CallStackGet();
				extraInfoStruct.arguments  = arguments;
				extraInfoStruct.local      = local;
				extraInfoStruct.variables  = variables;
				application.bugTracker.notifyService(
					   message      = "Error CREATING API log table [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					);
			} else {
				rethrow;
			}
		}
		return;
	}

}
