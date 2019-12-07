<cfcomponent name="user" output="false" hint="Box service layer for folder objects.">

	<cfset this.objectName = "users" />

	<cffunction name="init" returntype="user" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="userID"   type="string" required="true" hint="BoxID of user to get info of." />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.userID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getCurrentUserInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			method     = "me",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="createAppUser" access="public" returntype="any" output="false" hint="">
		<cfargument name="userName" type="string" required="true" hint="Name of user to create" />
		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action on behalf of." />

		<cfset local.boxID = "" />
		<cfset local.jsonBody = structNew() />
		<cfset local.jsonBody['name'] = arguments.userName />
		<cfset local.jsonBody['is_platform_access_only']       = true />
		<cfset local.jsonBody['can_see_managed_users']         = true />
		<cfset local.jsonBody['is_external_collab_restricted'] = false />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>