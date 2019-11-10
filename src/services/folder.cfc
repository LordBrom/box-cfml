<cfcomponent name="folder" output="false" hint="Box service layer for folder objects.">

	<cfset this.objectName = "folders" />

	<cffunction name="init" returntype="folder" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="create" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderName" type="string" required="true" hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" hint="BoxID of folder new folder will be created in." />
		<cfargument name="asUserID"   type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

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

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="copy" access="public" returntype="struct" output="false" hint="">
		<cfargument name="folderName" type="string" required="true" hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" hint="BoxID of folder new folder will be created in." />
		<cfargument name="SourceID"   type="string" required="true" hint="BoxID of folder to be copied." />
		<cfargument name="asUserID"   type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

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

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getContents" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to get contents of." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			method     = "items",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to get info of." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<!--- <cfset local.boxFolder = createObject("component", "objects.boxFolder").init(local.apiResponse) /> --->

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="update" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID"   type="string" required="true"  hint="BoxID of folder to update." />
		<cfargument name="folderName" type="string" required="false" hint="Name to change the folder to." />
		<cfargument name="parentID"   type="string" required="false" hint="BoxID of folder to move the folder to." />
		<cfargument name="tags"       type="array"  required="false" hint="Array of strings. These tags will by applied to the folder." />
		<cfargument name="asUserID"   type="string" required="true"  hint="BoxID of user to perform action oh behalf of." />

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

	<cffunction name="delete" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object      = this.objectName,
			objectID    = arguments.folderID,
			queryParams = "recursive=true",
			httpMethod  = "DELETE",
			userID      = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getCollaborations" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" hint="BoxID of folder to delete." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			method     = "collaborations",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>
</cfcomponent>