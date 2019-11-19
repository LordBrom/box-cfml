<cfcomponent name="collaboration" output="false" hint="Box service layer for file objects.">

	<cfset this.objectName = "collaborations" />

	<cffunction name="init" returntype="collaboration" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="create" access="public" returntype="struct" output="false" hint="">
		<cfargument name="itemBoxID"         type="string" required="true" hint="The ID of the file or folder that access is granted to" />
		<cfargument name="accessibleByBoxID" type="string" required="true" hint="The ID of the user or group that is granted access" />
		<cfargument name="accessibleType"    type="string" required="true" hint="[user] or [group]" />
		<cfargument name="role"              type="string" required="true" hint="The level of access granted. Can be [editor], [viewer], [previewer], [uploader], [previewer uploader], [viewer uploader], or [co-owner]." />
		<cfargument name="asUserID"          type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['item'] = structNew() />
		<cfset local.jsonBody['item']['type'] = "folder" />
		<cfset local.jsonBody['item']['id']   = arguments.itemBoxID />
		<cfset local.jsonBody['accessible_by'] = structNew() />
		<cfset local.jsonBody['accessible_by']['type'] = arguments.accessibleType />
		<cfset local.jsonBody['accessible_by']['id']   = arguments.accessibleByBoxID />
		<cfset local.jsonBody['role'] = lCase(arguments.role) />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			queryparam = "notify=false",
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="get" access="public" returntype="struct" output="false" hint="">
		<cfargument name="collaborationID"   type="string" required="true" hint="The ID of the collaboration to get" />
		<cfargument name="asUserID"          type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.collaborationID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>