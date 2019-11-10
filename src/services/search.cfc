<cfcomponent name="search" output="false" hint="Box service layer for searching for objects.">

	<cfset this.objectName = "search" />

	<cffunction name="init" returntype="search" access="public" output="false" hint="Constructor">
		<cfargument name="boxAPIHandler" type="boxAPIHandler" required="false" />

		<cfset variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="searchForContent" access="public" returntype="any" output="false" hint="">
		<cfargument name="query"           type="string"  required="true" hint="The string to search for. Box matches the search string against object names, descriptions, text contents of files, and other data." />
		<cfargument name="file_extensions" type="string"  required="true" hint="Limit searches to specific file extensions like [pdf], [png], or [doc]. The value can be a single file extension or a comma-delimited list of extensions. For example: [png,md,pdf]" />
		<cfargument name="type"            type="string"  required="true" hint="The type of objects you want to include in the search results. The type can be [file], [folder], or [web_link]." />
		<cfargument name="limit"           type="numeric" required="true" hint="The maximum number of items to return. The default is 30 and the maximum is 200." />

		<cfargument name="asUserID" type="string" required="true" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = structNew() />
		<cfset local.queryParams = "query=#arguments.query#" />
		<cfif len(arguments.file_extensions)>
			<cfset local.queryParams &= "file_extensions=#arguments.file_extensions#" />
		</cfif>
		<cfif len(arguments.type)>
			<cfset local.queryParams &= "type=#arguments.type#" />
		</cfif>

		<cfset local.apiResponse = variables.boxAPIHandler.makeRequest(
			object      = this.objectName,
			queryParams = local.queryParams,
			httpMethod  = "GET",
			userID      = arguments.asUserID
		) />

		<cfreturn local.apiResponse />
	</cffunction>

</cfcomponent>