<cfcomponent name="boxFileService" output="false" hint="Box service layer for file objects.">

	<cffunction name="init" returntype="boxFileService" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfif structKeyExists(arguments, "boxAPIHandler")>
			<cfset variables.boxAPIHandler = arguments.boxAPIHandler />
		<cfelse>
			<cfset variables.boxAPIHandler = createObject("component", "boxAPIHandler").init(  ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="uploadFile" access="public" returntype="string" output="false" hint="">
	    <cfargument name="fileName" type="string" required="true"             hint="Name of uploaded file." />
	    <cfargument name="filePath" type="string" required="true"             hint="Path to file to be uploaded." />
	    <cfargument name="ParentID" type="string" required="true" default="0" hint="BoxID of folder to upload file to." />
	    <cfargument name="userID"   type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.fileName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "files",
			method     = "content",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.userID,
			filePath   = arguments.filePath
		) />

		<cfif structKeyExists(local.apiResponse, "BOXAPIHANDLERSUCCESS") and local.apiResponse.BOXAPIHANDLERSUCCESS>
			<cfset local.boxID = local.apiResponse.entries[1].id />
		</cfif>

		<cfreturn local.boxID />
	</cffunction>

	<cffunction name="getFileInfo" access="public" returntype="any" output="false" hint="">
	    <cfargument name="fileID" type="string" required="true" hint="BoxID of file to get info of." />
	    <cfargument name="userID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "files",
			objectID   = arguments.fileID,
			httpMethod = "GET",
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="updateFile" access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"  hint="BoxID of file to update." />
		<cfargument name="fileName" type="string" required="false" hint="Name to change the file to." />
		<cfargument name="parentID" type="string" required="false" hint="BoxID of folder to move the file to." />
		<cfargument name="tags"     type="array"  required="false" hint="Array of strings. These tags will by applied to the file." />
		<cfargument name="userID"   type="string" required="true"  hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.jsonBody = structNew() />
		<cfif structKeyExists(arguments, "fileName") and len(arguments.fileName)>
			<cfset local.jsonBody['name']   = arguments.fileName />
		</cfif>
		<cfif structKeyExists(arguments, "parentID") and len(arguments.parentID)>
			<cfset local.jsonBody['parent'] = structNew() />
			<cfset local.jsonBody['parent']['id'] = arguments.ParentID />
		</cfif>
		<cfif structKeyExists(arguments, "tags") and arrayLen(arguments.tags)>
			<cfset local.jsonBody['tags'] = arguments.tags />
		</cfif>

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "files",
			objectID   = arguments.fileID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="deleteFile" access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID" type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="userID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "files",
			objectID   = arguments.fileID,
			httpMethod = "DELETE",
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>