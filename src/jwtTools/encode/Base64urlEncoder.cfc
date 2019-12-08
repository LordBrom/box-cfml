<cfcomponent output="false" hint="I encode and decode values using the Base64url character set (which is a variation of the Base64 standard intended for use with URLs).">

	<cffunction name="init" access="public" returntype="any" output="false" hint="I initialize the Base64url encoder.">
		<cfreturn this />
	</cffunction>

	<cffunction name="convertFromBase64" access="public" returntype="any" output="false" hint="I convert the given base64 value into the the base64url character set.">
		<cfargument name="input"  type="string" required="true" hint="I am the base64 value to convert to base64url." />

		<cfset arguments.input = replace( arguments.input, "+", "-", "all" ) />
		<cfset arguments.input = replace( arguments.input, "/", "_", "all" ) />
		<cfset arguments.input = replace( arguments.input, "=", "", "all" ) />

		<cfreturn( arguments.input ) />
	</cffunction>

	<cffunction name="convertToBase64" access="public" returntype="any" output="false" hint="I convert the given base64url value into the the base64 character set.">
		<cfargument name="input"  type="string" required="true" hint="I am the base64url value to convert to base64." />

		<cfset arguments.input = replace( arguments.input, "-", "+", "all" ) />
		<cfset arguments.input = replace( arguments.input, "_", "/", "all" ) />

		<cfset local.paddingLength = ( 4 - ( len( arguments.input ) % 4 ) ) />

		<cfreturn( arguments.input & repeatString( "=", local.paddingLength ) ) />
	</cffunction>

	<cffunction name="decode" access="public" returntype="any" output="false" hint="I decode the given base64url value and return the original UTF-8 input.">
		<cfargument name="input"  type="string" required="true" hint="I am the encoded input that needs to be decoded." />

		<cfreturn( charsetEncode( binaryDecode( convertToBase64( input ), "base64" ), "utf-8" ) ) />
	</cffunction>

	<cffunction name="decodeBytes" access="public" returntype="any" output="false" hint="I decode the given binary representation (of a base64url string) and return the original UTF-8 input.">
		<cfargument name="input"  type="binary" required="true" hint="I am the binary value that needs to be decoded." />

		<cfreturn( decode( charsetEncode( binary, "utf-8" ) ) ) />
	</cffunction>

	<cffunction name="encode" access="public" returntype="any" output="false" hint="I encode the given UTF-8 input using the base64url character set.">
		<cfargument name="input"  type="string" required="true" hint="I am the UTF-8 value that needs to be encoded using base64url." />

		<cfreturn( encodeBytes( charsetDecode( input, "utf-8" ) ) ) />
	</cffunction>

	<cffunction name="encodeBytes" access="public" returntype="any" output="false" hint="I encode the given binary value using the base64url character set.">
		<cfargument name="input"  type="binary" required="true" hint="I am the binary value to encode using base64url." />

		<cfreturn( convertFromBase64( binaryEncode( input, "base64" ) ) ) />
	</cffunction>
</cfcomponent>