<cfcomponent name="boxService" output="false" hint="">

	<cffunction name="init" returntype="boxService" access="public" output="false" hint="Constructor">

		<cfset variables.boxAPIHandler = createObject("component", "boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>






	<!---------------------------------------------------------------------
	  -------------------------------FOLDERS-------------------------------
	  --------------------------------------------------------------------->

	<cffunction name="createFolder" access="public" returntype="string" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"             hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" default="0" hint="BoxID of folder new folder will be created in." />
		<cfargument name="userID"     type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.folderName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.userID
		) />

		<cfif structKeyExists(local.apiResponse, "BOXAPIHANDLERSUCCESS") and local.apiResponse.BOXAPIHANDLERSUCCESS>
			<cfset local.boxID = local.apiResponse.id />
		</cfif>

		<cfreturn local.boxID />
	</cffunction>

	<cffunction name="copyFolder" access="public" returntype="string" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"             hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true"             hint="BoxID of folder new folder will be created in." />
		<cfargument name="SourceID"   type="string" required="true" default="0" hint="BoxID of folder to be copied." />
		<cfargument name="userID"     type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.folderName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			objectID   = SourceID,
			method     = "copy",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.userID
		) />

		<cfif structKeyExists(local.apiResponse, "BOXAPIHANDLERSUCCESS") and local.apiResponse.BOXAPIHANDLERSUCCESS>
			<cfset local.boxID = local.apiResponse.id />
		</cfif>

		<cfreturn local.boxID />
	</cffunction>

	<cffunction name="getFolderContents" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0" hint="BoxID of folder to get contents of." />
		<cfargument name="userID"   type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			objectID   = arguments.folderID,
			method     = "items",
			httpMethod = "GET",
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getFolderInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0" hint="BoxID of folder to get info of." />
		<cfargument name="userID"   type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			objectID   = arguments.folderID,
			httpMethod = "GET",
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="updateFolder" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID"   type="string" required="true"  hint="BoxID of folder to update." />
		<cfargument name="folderName" type="string" required="false" hint="Name to change the folder to." />
		<cfargument name="parentID"   type="string" required="false" hint="BoxID of folder to move the folder to." />
		<cfargument name="tags"       type="array"  required="false" hint="Array of strings. These tags will by applied to the folder." />
		<cfargument name="userID"     type="string" required="true"  hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.jsonBody = structNew() />
		<cfif structKeyExists(arguments, "folderName") and len(arguments.folderName)>
			<cfset local.jsonBody['name']   = arguments.folderName />
		</cfif>
		<cfif structKeyExists(arguments, "parentID") and len(arguments.parentID)>
			<cfset local.jsonBody['parent'] = structNew() />
			<cfset local.jsonBody['parent']['id'] = arguments.ParentID />
		</cfif>
		<cfif structKeyExists(arguments, "tags") and arrayLen(arguments.tags)>
			<cfset local.jsonBody['tags'] = arguments.tags />
		</cfif>

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			objectID   = arguments.folderID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="deleteFolder" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to delete." />
		<cfargument name="userID"   type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "folders",
			objectID   = arguments.folderID,
			httpMethod = "DELETE",
			userID     = arguments.userID
		) />

		<cfreturn local.apiResponse />
	</cffunction>






	<!---------------------------------------------------------------------
	  --------------------------------FILES--------------------------------
	  --------------------------------------------------------------------->

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

