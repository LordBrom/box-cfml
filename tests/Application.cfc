<cfcomponent>
	<cfset this.name = "Box Drive API Tests" />

	<cfset variables.here = getDirectoryFromPath(getCurrentTemplatePath()) />
	<cfset this.mappings['/mxunit'] = variables.here & "../testbox/system/compat" />
</cfcomponent>
