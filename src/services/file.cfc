<cfcomponent name="file" output="false" hint="Box service layer for file objects.">

	<cfset this.objectName = "files" />

	<cffunction name="init" returntype="file" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="upload" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileName"  type="string"  required="true" hint="Name of uploaded file." />
		<cfargument name="filePath"  type="string"  required="true" hint="Path to file to be uploaded." />
		<cfargument name="ParentID"  type="string"  required="true" hint="BoxID of folder to upload file to." />
		<cfargument name="fileID"    type="string"  required="true" hint="BoxID of file to update the version of." />
		<cfargument name="preflight" type="boolean" required="true" hint="Performs a Preflight check, to see if uploading the file would be successful." />
		<cfargument name="asUserID"  type="string"  required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.fileName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.httpMethod = (arguments.preflight) ? "OPTIONS" : "POST" />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "content",
			jsonBody   = local.jsonBody,
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID,
			filePath   = arguments.filePath
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getInfo" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true" hint="BoxID of file to get info of." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="update" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"  hint="BoxID of file to update." />
		<cfargument name="fileName" type="string" required="false" hint="Name to change the file to." />
		<cfargument name="parentID" type="string" required="false" hint="BoxID of folder to move the file to." />
		<cfargument name="tags"     type="array"  required="false" hint="Array of strings. These tags will by applied to the file." />
		<cfargument name="asUserID" type="string" required="true"  hint="BoxID of user to perform action on behalf of." />

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
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="delete" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "DELETE",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="copy" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileName" type="string" required="true" hint="Name of the newly created file." />
		<cfargument name="ParentID" type="string" required="true" hint="BoxID of folder new file will be created in." />
		<cfargument name="SourceID" type="string" required="true" hint="BoxID of folder to be copied." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.fileName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "copy",
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getCollaborations" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "collaborations",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="createUploadSession" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "upload_sessions",
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>


	<!---------------------------------------------------------------------
	  --------------------------VERSION FUNCTIONS--------------------------
	  --------------------------------------------------------------------->

	<cffunction name="ListVersions" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getVersion" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true" hint="Version number to retrieve." />
		<cfargument name="asUserID"  type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/#arguments.versionID#",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="revertVersion" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true" hint="Version number to retrieve." />
		<cfargument name="asUserID"  type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.return = structNew() />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['type'] = "file_version" />
		<cfset local.jsonBody['id'] = arguments.versionID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/current",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="deleteVersion" access="public" returntype="struct" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true" hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true" hint="Version number to retrieve." />
		<cfargument name="asUserID"  type="string" required="true" hint="BoxID of user to perform action on behalf of." />


		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/#arguments.versionID#",
			httpMethod = "DELETE",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>