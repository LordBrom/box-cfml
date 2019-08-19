<cfcomponent name="collaboration" output="false" hint="Box service layer for file objects.">

	<cfset this.objectName = "collaborations" />

	<cffunction name="init" returntype="collaboration" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfif structKeyExists(arguments, "boxAPIHandler")>
			<cfset variables.boxAPIHandler = arguments.boxAPIHandler />
		<cfelse>
			<cfset variables.boxAPIHandler = createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="createCollaboration" access="public" returntype="any" output="false" hint="">
		<cfargument name="itemBoxID"         type="string" required="true"                  hint="The ID of the file or folder that access is granted to" />
		<cfargument name="accessibleByBoxID" type="string" required="true"                  hint="The ID of the user or group that is granted access" />
		<cfargument name="accessibleType"    type="string" required="true" default="user"   hint="[user] or [group]" />
		<cfargument name="role"              type="string" required="true" default="editor" hint="The level of access granted. Can be [editor], [viewer], [previewer], [uploader], [previewer uploader], [viewer uploader], or [co-owner]." />
		<cfargument name="asUserID"          type="string" required="true"                  hint="BoxID of user to perform action oh behalf of." />

		<cfif NOT listFindNoCase("editor,viewer,previewer,uploader,previewer uploader,viewer uploader,co-owner", arguments.role) >
			<cfthrow message="Arugment ""role"" was passed with an invalide value" />
		</cfif>
		<cfif NOT listFindNoCase("user,group", arguments.accessibleType) >
			<cfthrow message="Arugment ""accessibleType"" was passed with an invalide value" />
		</cfif>

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
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>


</cfcomponent>