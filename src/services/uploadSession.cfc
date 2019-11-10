<cfcomponent name="uploadSession" output="false" hint="Box service layer for upload session objects.">

	<cfset this.objectName = "files/upload_sessions" />

	<cffunction name="init" returntype="uploadSession" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="get" access="public" returntype="struct" output="false" hint="">
		<cfargument name="uploadSessionID" type="string"  required="true" hint="Name of uploaded file." />
		<cfargument name="asUserID"        type="string"  required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.httpMethod = "GET" />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.uploadSessionID,
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="listParts" access="public" returntype="struct" output="false" hint="">
		<cfargument name="uploadSessionID" type="string"  required="true" hint="Name of uploaded file." />
		<cfargument name="asUserID"        type="string"  required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.httpMethod = "GET" />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.uploadSessionID,
			method     = "list",
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="create" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileName" type="string" required="true" hint="Name of the newly created file." />
		<cfargument name="fileSize" type="numeric" required="true" hint="Size of the newly created file." />
		<cfargument name="filePath" type="string"  required="true" hint="Path to file to be uploaded." />
		<cfargument name="ParentID" type="string" required="true" hint="BoxID of folder new file will be created in." />
		<cfargument name="asUserID" type="string"  required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['file_name'] = arguments.fileName />
		<cfset local.jsonBody['file_size'] = arguments.fileSize />
		<cfset local.jsonBody['folder_id'] = arguments.ParentID />

		<cfset local.httpMethod = "POST" />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			httpMethod = local.httpMethod,
			jsonBody   = local.jsonBody,
			filePath   = arguments.filePath,
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>