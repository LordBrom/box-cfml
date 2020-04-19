<cfcomponent extends="mxunit.framework.TestCase" >

	<cffunction name="setup"  hint="This function is called before any of the tests.">
	</cffunction>

	<cffunction name="testOne">
		<cfset assertEquals(1,1) />
	</cffunction>
	<cffunction name="testTwo">
		<cfset assertEquals(1,1) />
	</cffunction>
</cfcomponent>

