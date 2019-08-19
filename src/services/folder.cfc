<cfcomponent name="folder" output="false" hint="Box service layer for folder objects.">

	<cfset this.objectName = "folders" />

	<cffunction name="init" returntype="folder" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfif structKeyExists(arguments, "boxAPIHandler")>
			<cfset variables.boxAPIHandler = arguments.boxAPIHandler />
		<cfelse>
			<cfset variables.boxAPIHandler = createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="createFolder" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"             hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" default="0" hint="BoxID of folder new folder will be created in." />
		<cfargument name="asUserID"     type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.folderName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfif structKeyExists(local.apiResponse, "BOXAPIHANDLERSUCCESS") and local.apiResponse.BOXAPIHANDLERSUCCESS>
			<cfset local.boxID = local.apiResponse.id />
		</cfif>

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="copyFolder" access="public" returntype="string" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"             hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true"             hint="BoxID of folder new folder will be created in." />
		<cfargument name="SourceID"   type="string" required="true" default="0" hint="BoxID of folder to be copied." />
		<cfargument name="asUserID"     type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name']   = arguments.folderName />
		<cfset local.jsonBody['parent'] = structNew() />
		<cfset local.jsonBody['parent']['id'] = arguments.ParentID />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = SourceID,
			method     = "copy",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfif structKeyExists(local.apiResponse, "BOXAPIHANDLERSUCCESS") and local.apiResponse.BOXAPIHANDLERSUCCESS>
			<cfset local.boxID = local.apiResponse.id />
		</cfif>

		<cfreturn local.boxID />
	</cffunction>

	<cffunction name="getFolderContents" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0" hint="BoxID of folder to get contents of." />
		<cfargument name="asUserID"   type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			method     = "items",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getFolderInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0" hint="BoxID of folder to get info of." />
		<cfargument name="asUserID" type="string" required="true"             hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<!--- <cfset local.boxFolder = createObject("component", "objects.boxFolder").init(local.apiResponse) /> --->

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="updateFolder" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID"   type="string" required="true"  hint="BoxID of folder to update." />
		<cfargument name="folderName" type="string" required="false" hint="Name to change the folder to." />
		<cfargument name="parentID"   type="string" required="false" hint="BoxID of folder to move the folder to." />
		<cfargument name="tags"       type="array"  required="false" hint="Array of strings. These tags will by applied to the folder." />
		<cfargument name="asUserID"     type="string" required="true"  hint="BoxID of user to perform action oh behalf of." />

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
			object     = this.objectName,
			objectID   = arguments.folderID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="deleteFolder" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to delete." />
		<cfargument name="asUserID"   type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object      = this.objectName,
			objectID    = arguments.folderID,
			queryParams = "recursive=true",
			httpMethod  = "DELETE",
			userID      = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>