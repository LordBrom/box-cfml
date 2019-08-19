<cfcomponent name="boxAPILogHandler" output="false" hint="Submits api log information to the database">

	<cffunction name="init" returntype="boxAPILogHandler" access="public" output="false" hint="Constructor">
		<cfargument name="datasource"  type="string"  required="true" default=""      hint="" />
		<cfargument name="tableName"   type="string"  required="true" default=""      hint="" />
		<cfargument name="createTable" type="boolean" required="true" default="false" hint="" />

		<cfset variables.datasource = arguments.datasource />
		<cfset variables.tableName  = arguments.tableName />

		<cfif arguments.createTable>
			<cfset createLogDable() />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setLog" access="public" returntype="numeric" output="false" hint="Adds a BoxAPI log record.">
		<cfargument name="url"         type="string"  required="true" />
		<cfargument name="method"      type="string"  required="true" />
		<cfargument name="getasbinary" type="boolean" required="true" default="no"   />
		<cfargument name="httpParams"  type="array"   required="true" default="no"   />
		<cfset local.return = -1 />

		<cftry>
			<!--- QUERY - INSERT --->
			<cfquery datasource="#variables.datasource#" result="local.ins">
				INSERT INTO [#variables.tableName#]
				(
					url,
					method,
					getasbinary,
					httpParams,
					datetimeSent
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar"   value="#arguments.url#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar"   value="#arguments.method#" />,
					<cfqueryparam cfsqltype="cf_sql_bit"       value="#arguments.getasbinary#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar"   value="#reReplace(SerializeJSON(arguments.httpParams), 'Bearer ([^".]*)"', 'Bearer <access_token>"')#" />,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
				)
			</cfquery>
			<cfset local.return = local.ins.generatedKey />

			<cfcatch>

				<cfif structKeyExists(application,'bugTracker')>
					<cfset exceptionStruct = cfcatch />
					<cfset extraInfoStruct = structNew() />
					<cfset extraInfoStruct._callStack = CallStackGet() />
					<cfset extraInfoStruct.arguments  = arguments />
					<cfset extraInfoStruct.local      = local />
					<cfset extraInfoStruct.variables  = variables />

					<cfset application.bugTracker.notifyService(
						message      = "Error logging API interaction to [#variables.tableName#] on #cgi.server_name#",
						exception    = exceptionStruct,
						ExtraInfo    = extraInfoStruct,
						severityCode = "error"
					) />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn local.return />
	</cffunction>

	<cffunction name="updateLog" access="public" returntype="void" hint="Sets a log">
		<cfargument name="logID"        required="true"  type="numeric" hint="ID" />
		<cfargument name="responseCode" required="false" type="string"  hint="response statuscode (200 OK,401 message, etc)" />
		<cfargument name="response"     required="false" type="any"     hint="the API's full cfhttp response" />
		<cftry>
			<!--- Update log event with response --->
			<cfquery datasource="#variables.datasource#" result="local.update">
				UPDATE [#variables.tableName#]
				SET

					<cfif structKeyExists(arguments, "responseCode")>
						responseCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.responseCode#" />,
					</cfif>
					<cfif structKeyExists(arguments, "response")>
						response = <cfqueryparam cfsqltype="cf_sql_varchar" value="#serializeJSON(arguments.response)#" />,
					</cfif>
					datetimeReceived=getDate()
				WHERE
					boxApiLogID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.logID#" />

			</cfquery>

			<cfcatch>
				<cfif structKeyExists(application,'bugTracker')>
					<cfset exceptionStruct = cfcatch />
					<cfset extraInfoStruct = structNew() />
					<cfset extraInfoStruct._callStack = CallStackGet() />
					<cfset extraInfoStruct.arguments  = arguments />
					<cfset extraInfoStruct.local      = local />
					<cfset extraInfoStruct.variables  = variables />

					<cfset application.bugTracker.notifyService(
					   message      = "Error UPDATING API log to [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					) />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn />
	</cffunction>

	<cffunction name="hardDeleteLog" access="public" returntype="void" hint="Sets a log">
		<cfargument name="logID" required="true" type="numeric"    hint="ID" />
		<cftry>
			<!--- Update log event with response --->
			<cfquery datasource="#variables.datasource#" result="local.update">
				DELETE FROM [#variables.tableName#]
				WHERE
					boxApiLogID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.logID#" />
			</cfquery>

			<cfcatch>
				<cfif structKeyExists(application,'bugTracker')>
					<cfset exceptionStruct = cfcatch />
					<cfset extraInfoStruct = structNew() />
					<cfset extraInfoStruct._callStack = CallStackGet() />
					<cfset extraInfoStruct.arguments  = arguments />
					<cfset extraInfoStruct.local      = local />
					<cfset extraInfoStruct.variables  = variables />

					<cfset application.bugTracker.notifyService(
					   message      = "Error DELETING API log from [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					) />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn />
	</cffunction>

	<cffunction name="createLogDable" access="public" returntype="void" hint="Sets a log">
		<cftry>
			<!--- Update log event with response --->
			<cfquery datasource="#variables.datasource#" result="local.update">
				IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[#variables.tableName#]') AND type in (N'U'))
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
				END
			</cfquery>

			<cfcatch>
				<cfdump var="#cfcatch#" /><cfabort />
				<cfif structKeyExists(application,'bugTracker')>
					<cfset exceptionStruct = cfcatch />
					<cfset extraInfoStruct = structNew() />
					<cfset extraInfoStruct._callStack = CallStackGet() />
					<cfset extraInfoStruct.arguments  = arguments />
					<cfset extraInfoStruct.local      = local />
					<cfset extraInfoStruct.variables  = variables />

					<cfset application.bugTracker.notifyService(
					   message      = "Error CREATING API log table [#variables.tableName#] on #cgi.server_name#",
					   exception    = exceptionStruct,
					   ExtraInfo    = extraInfoStruct,
					   severityCode = "error"
					) />
				<cfelse>
					<cfrethrow />
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn />
	</cffunction>

</cfcomponent>
