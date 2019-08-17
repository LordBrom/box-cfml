<cfcomponent name="boxAPIHandler" output="false" hint="Contains functions that interact with the Box.com API via http calls">

	<cfset this.boxAPIURL       = "https://api.box.com/" />
	<cfset this.boxAPIUploadURL = "https://upload.box.com/api/" /> <!--- used for file upload only --->
	<cfset this.boxAPIVersion   = "2.0" />

	<cffunction name="init" returntype="boxAPIHandler" access="public" output="false" hint="Constructor">

		<cfset variables.boxAuth      = createObject("component", "boxAuthentication") />
		<!--- <cfset variables.boxAPILog    = createObject("component", "boxAPILogService").init(request.DSN, "boxApiLog") /> --->
		<cfset variables.JWT          = createObject("component", "jwtTools.JsonWebTokens") />
		<cfset variables.access_token = "" />
		<cfset variables.expires_in   = "" />
		<cfset variables.issued_at    = "" />

		<cfreturn this />
	</cffunction>

	<cffunction name="makeRequest"      returntype="any"    access="public" output="false" hint="">
		<cfargument name="object"      type="string"  required="true" default=""              hint="{BoxURL}/[object]/[objectID]/[method]?[queryParams]; Object to affect (files|folders)                           " />
		<cfargument name="objectID"    type="string"  required="true" default=""              hint="{BoxURL}/[object]/[objectID]/[method]?[queryParams]; BoxID of object being affected                             " />
		<cfargument name="method"      type="string"  required="true" default=""              hint="{BoxURL}/[object]/[objectID]/[method]?[queryParams]; Action to be taken on the object.                          " />
		<cfargument name="queryParams" type="string"  required="true" default=""              hint="{BoxURL}/[object]/[objectID]/[method]?[queryParams]; Additional url parameters. " />
		<cfargument name="jsonBody"    type="struct"  required="true" default="#structNew()#" hint="Parameters to be passed as http body, or formfield for file upload." />
		<cfargument name="httpMethod"  type="string"  required="true" default="POST"          hint="cfhttp request method. GET,POST,PUT,DELETE,HEAD,TRACE,OPTIONS,PATCH" />
		<cfargument name="userID"      type="string"  required="true" default=""              hint="Box user ID of who the action is being taken on behalf of" />
		<cfargument name="filePath"    type="string"  required="true" default=""              hint="Path to a file to be uploaded" />
		<cfargument name="getasbinary" type="string"  required="true" default="no"            hint="If true, cfhttp request returns binary." />

		<cfset local.return = structNew() />
		<cfset local.httpParams = arrayNew(1) />

		<cfif NOT len(variables.access_token) OR
				dateCompare(now(), dateAdd('s', (variables.expires_in - 60), variables.issued_at)) NEQ -1>
			<cfset getAuthorization() />
		</cfif>

		<cfset arrayAppend(local.httpParams, { "type": "Header", "name": "Authorization", "value": variables.access_token }) />
		<cfif len(userID)>
			<cfset arrayAppend(local.httpParams, { "type": "Header", "name": "As-User", "value": arguments.userID }) />
		</cfif>

		<cfif arguments.object EQ "files" AND method EQ "content" AND httpMethod EQ "POST" AND len(arguments.filePath)>
			<cfset local.url = this.boxAPIUploadURL & this.boxAPIVersion & "/" & arguments.object & "/" />
			<cfset arrayAppend(local.httpParams, { "type": "formfield", "name": "attributes", "value": SerializeJSON(arguments.jsonBody) }) />
			<cfset arrayAppend(local.httpParams, { "type": "file",      "name": "file",       "file": arguments.filePath }) />
		<cfelse>
			<cfset local.url = this.boxAPIURL & this.boxAPIVersion & "/" & arguments.object & "/" />
			<cfset arrayAppend(local.httpParams, { "type": "Header", "name": "Content-Type", "value": "application/json" }) />
			<cfset arrayAppend(local.httpParams, { "type": "body",   "name": "json",         "value": SerializeJSON(arguments.jsonBody) }) />
		</cfif>

		<cfif len(arguments.objectID) >
			<cfset local.url &= arguments.objectID & "/" />
		</cfif>

		<cfif len(arguments.method) >
			<cfset local.url &= arguments.method />
		</cfif>

		<cfif len(arguments.queryParams) >
			<cfset local.url &= "?" & arguments.queryParams />
		</cfif>

		<cfset arrayAppend(local.httpParams, { "type": "Header", "name": "Accept", "value": "application/json" }) />

		<cfreturn send(
			url         = local.url,
			method      = arguments.httpMethod,
			getasbinary = arguments.getasbinary,
			httpParams  = local.httpParams
		) />
	</cffunction>

	<cffunction name="getAuthorization" returntype="void"   access="private" output="false" hint="Gets an autheToken from Box.">
		<!--- Initialize local function scope --->
		<cfset local.authorization = '' />

		<!--- Use variables.JWTTools to get the JWTAssertion --->
		<cfset local.jwtAssertion = getJWTAssertion() />

		<!--- call getToken to ping box and get the authToken  --->
		<cfset local.authorization = getOAUTHToken(local.jwtAssertion) />

		<cfset variables.access_token  = "Bearer #local.authorization.access_token#" />
		<cfset variables.expires_in    = local.authorization.expires_in />
	</cffunction>

	<cffunction name="getJWTAssertion"  returnType="string" access="private" output="false" hint="use the environment-based variables to get the ">
		<cfset local.JWTPayload = getJWTPayload() />

		<cfset local.jwtClient = variables.JWT.createClient(
			algorithm  = 'RS256',
			key        = variables.boxAuth.getPublicKey(),
			privateKey = variables.boxAuth.getPrivateKey()
		) />

		<cfset local.return = local.jwtClient.encode(local.JWTPayload, variables.boxAuth.getKeyID()) />
		<cfreturn local.return />
	</cffunction>

	<cffunction name="getJWTPayload"    returnType="struct" access="private" output="false" hint="return the default JWT values based on BOX APP console ">
		<cfset local.return = structNew() />

		<cfset variables.issued_at = now() />
		<cfset local.return["exp"] = "#Int(floor(variables.issued_at.getTime()/1000) + 15)#" />
		<cfset local.return["iss"] = variables.boxAuth.getClientID() />
		<cfset local.return["sub"] = " #trim(variables.boxAuth.getEnterpriseID())#" /> <!--- The space before the enterpriseID is required for ColdFusion. --->
		<cfset local.return["box_sub_type"] = "enterprise" />
		<cfset local.return["aud"] = "#this.boxAPIURL#oauth2/token" />
		<cfset local.return["jti"] = '#replace(createUUID(), "-", "", "all")#' />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getOAUTHToken"    returnType="struct" access="private" output="false" hint="perform the API Request to get the Auth Token ">
		<cfargument name="jwtAssertion" type="string" required="true" />

		<cfset local.url = "#this.boxAPIURL#oauth2/token" />
		<cfset local.httpParams = arrayNew(1) />

		<cfset arrayAppend(local.httpParams, { "type": "formfield", "name": "grant_type",    "value": "urn:ietf:params:oauth:grant-type:jwt-bearer" }) />
		<cfset arrayAppend(local.httpParams, { "type": "formfield", "name": "client_id",     "value": variables.boxAuth.getClientID() }) />
		<cfset arrayAppend(local.httpParams, { "type": "formfield", "name": "client_secret", "value": variables.boxAuth.getClientSecret() }) />
		<cfset arrayAppend(local.httpParams, { "type": "formfield", "name": "assertion",     "value": arguments.jwtAssertion }) />

		<cfset local.auth = send(
			url        = local.url,
			method     = "POST",
            httpParams = local.httpParams,
            logCall    = false
        ) />

		<cfreturn local.auth />
	</cffunction>

	<cffunction name="send"             returnType="struct" access="private" output="false" hint="send request to REST API">
		<cfargument name="url"         type="string"  required="true" />
		<cfargument name="method"      type="string"  required="true" />
		<cfargument name="getasbinary" type="boolean" required="true" default="no"   />
		<cfargument name="httpParams"  type="array"   required="true" default="no"   />
		<cfargument name="logCall"     type="boolean" required="true" default="true" />

		<cfset local.logID = 0 />
		<cfif structKeyExists(variables, "boxAPILog") AND arguments.logCall>
			<cfset local.logID = variables.boxAPILog.setLog( argumentCollection = arguments ) />
		</cfif>

		<cfhttp url="#arguments.url#" method="#arguments.method#" throwonerror="false" result="local.response" getasbinary="#arguments.getasbinary#">
			<cfloop array="#arguments.httpParams#" index="local.idx" item="local.itm">
				<cfif structKeyExists(local.itm, "value")>
					<cfhttpparam type="#local.itm.type#" name="#local.itm.name#" value="#local.itm.value#" />
				<cfelseif structKeyExists(local.itm, "file")>
					<cfhttpparam type="#local.itm.type#" name="#local.itm.name#" file="#local.itm.file#" />
				</cfif>
			</cfloop>
		</cfhttp>

		<cfif local.logID>
			<cfset variables.boxAPILog.updateLog(
				logID        = local.logID,
				responseCode = local.response.statusCode,
				response     = local.response
			) />
		</cfif>

		<cfset local.return = handleResponse(local.response, arguments.url, arguments.getasbinary) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="handleResponse"   returnType="struct" access="private" output="false" hint="parseResponse from Box API">
		<cfargument name="response"     type="struct" required="true" />
		<cfargument name="url"          type="string" required="true" />
		<cfargument name="returnBinary" type="string" required="false" default="no" />
		<cfset local.return = structNew() />

		<cfset local.return.BOXAPIHANDLERSUCCESS = false />
		<cfset local.return.BOXAPIHANDLERSTATUSCODE = arguments.response.statusCode />

		<cfif NOT ListFind('200 OK,201 Created', arguments.response.statusCode) >
			<cfset local.return.BOXAPIHANDLERSUCCESS = false />
			<!--- <cfdump var="#arguments.response#" /><cfabort /> --->
		<cfelse>
			<cftry>
				<cfif returnBinary EQ 'no'>
					<cfset local.return = deserializeJSON(arguments.response.fileContent) />
				<cfelse>
					<cfset local.return.content = arguments.response.fileContent />
				</cfif>
				<cfset local.return.BOXAPIHANDLERSUCCESS = true />
				<cfcatch>
					<!--- could not JSON Parse response; but it was a 200OK --->
					<cfset local.return.BOXAPIHANDLERSUCCESS = true />
					<cfrethrow />
					<!--- <cfdump var="#cfcatch#" /><cfabort /> --->
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn local.return />
	</cffunction>
</cfcomponent>