<cfcomponent name="boxUserService" output="false" hint="Box service layer for folder objects.">

	<cffunction name="init" returntype="boxUserService" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfif structKeyExists(arguments, "boxAPIHandler")>
			<cfset variables.boxAPIHandler = arguments.boxAPIHandler />
		<cfelse>
			<cfset variables.boxAPIHandler = createObject("component", "boxAPIHandler").init(  ) />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="getUserInfo" access="public" returntype="any" output="false" hint="">
	    <cfargument name="userID" type="string" required="true" hint="BoxID of user to get info of." />
	    <cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "users",
			objectID   = arguments.userID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

	<cffunction name="getCurrentUserInfo" access="public" returntype="any" output="false" hint="">
	    <cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = "users",
			method     = "me",
			httpMethod = "GET",
			userID     = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>