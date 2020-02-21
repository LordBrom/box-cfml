<cfcomponent output="false" hint="I encode and decode values using JavaScript Object Notation (JSON).">

	<cffunction name="init" access="public" returntype="any" output="false" hint="I initialize the JSON encoder.">
		<cfreturn this />
	</cffunction>

	<cffunction name="decode" access="public" returntype="any" output="false" hint="I decode the given JSON-encoded value and return the original input.">
		<cfargument name="input"  type="string" required="true" hint="I am the encoded input that needs to be decoded." />

		<cfreturn( deserializeJson( arguments.input ) ) />
	</cffunction>

	<cffunction name="encode" access="public" returntype="any" output="false" hint="I encode the given value using JavaScript Object Notation.">
		<cfargument name="input"  type="any" required="true" hint="I am the data structure that needs to be encoded." />

		<cfreturn( serializeJson( arguments.input ) ) />
	</cffunction>
</cfcomponent>