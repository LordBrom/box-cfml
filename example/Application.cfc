<cfcomponent>
	<cfset this.name = "BoxDriveApiExample" />
	<cfset this.wschannels = [
        {name:"box"}
	] />

	<cffunction name="onRequest" access="public">
		<cfargument name="template" type="string" required="true" />

		<cfset application.boxService = createObject("component", "src.box").init() />

		<cfinclude template="#arguments.template#" />
	</cffunction>

</cfcomponent>
