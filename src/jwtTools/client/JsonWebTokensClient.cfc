<cfcomponent name="JsonWebTokensClient" output="false" hint="I provide encoding and decoding methods for JSON Web Tokens (JWT).">

	<cffunction name="init" access="public" returntype="any" output="false" hint="I initialize the JSON Web Tokens client with the given signer.">
		<cfargument name="jsonEncoder"      type="any" required="true" hint="I am the JSON encoding utility." />
		<cfargument name="base64urlEncoder" type="any" required="true" hint="I am the base64url encoding utility." />
		<cfargument name="signer"           type="any" required="true" hint="I am the secure message signer and verifier." />

		<!--- Store the private variables. --->
		<cfset setJsonEncoder( jsonEncoder ) />
		<cfset setBase64urlEncoder( base64urlEncoder ) />
		<cfset setSigner( signer ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="decode" access="public" returntype="any" output="false" hint="I decode the given JSON Web Token and return the deserialized payload.">
		<cfargument name="token"      type="any" required="true" hint="I am the JWT token being decoded." />

		<!--- Extract the JSON Web token segments. --->
		<cfset local.segments = listToArray( arguments.token, "." ) />
		<cfset local.headerSegment = segments[ 1 ] />
		<cfset local.payloadSegment = segments[ 2 ] />
		<cfset local.signatureSegment = segments[ 3 ] />

		<!---
			CAUTION: We never use the algorithm defined in the header. Not only can we
			not be sure that we have the appropriate signer, we also open ourselves up
			to potential abuse. As such, the client will always use the predefined,
			internal signer when verifying the signature.
		--->

		<cfif NOT verifySignatureSegment( headerSegment, payloadSegment, signatureSegment )  >

			<cfthrow
				type         = "JsonWebTokens.SignatureMismatch"
				message      = "The JSON Web Token signature is invalid."
				detail       = "The given JSON Web Token signature [#signatureSegment#] could not be verified by the signer."
				extendedInfo = "JSON Web Token: [#arguments.token#]."
			 />
		</cfif>

		<cfreturn( parsePayloadSegment( payloadSegment ) ) />
	</cffunction>


	<cffunction name="encode" access="public" returntype="any" output="false" hint="I encode the given payload for JWT transportation.">
		<cfargument name="payload" type="any" required="true" hint="I am the payload being encoded for transport." />
		<cfargument name="kid"     type="any" required="true" hint="" />

		<cfif IsDefined('kid') >
			<!--- I am the standardized header for a secured JSON Web Token. --->
			<cfset local.header = {
				"typ" = "JWT",
				"alg" = "RS256",
				"kid" = arguments.kid
			} />
		<cfelse>
			<!--- I am the standardized header for a secured JSON Web Token. --->
			<cfset local.header = {
				"typ" = "JWT",
				"alg" = "RS256"
			} />
		</cfif>

		<!--- Generate segments of the token. --->
		<cfset local.headerSegment    = generateHeaderSegment( local.header ) />
		<cfset local.payloadSegment   = generatePayloadSegment( arguments.payload ) />
		<cfset local.signatureSegment = generateSignatureSegment( local.headerSegment, local.payloadSegment ) />

		<!--- Return the JSON web token. --->
		<cfreturn( local.headerSegment & "." & local.payloadSegment & "." & local.signatureSegment ) />
	</cffunction>

	<cffunction name="setJsonEncoder" access="public" returntype="any" output="false" hint="I set the JSON encoder implementation used to serialize and deserialize portions of the request. Returns [this].">
		<cfargument name="newJsonEncoder"      type="any" required="true" hint="I am the new JSON encoder." />

		<cfset jsonEncoder = arguments.newJsonEncoder />

		<cfreturn( this ) />
	</cffunction>


	<cffunction name="setBase64urlEncoder" access="public" returntype="any" output="false" hint="I set the base64url encoder implementation. Returns [this].">
		<cfargument name="newBase64urlEncoder"      type="any" required="true" hint="I am the new base64url encoder." />

		<cfset base64urlEncoder = arguments.newBase64urlEncoder />

		<cfreturn( this ) />
	</cffunction>

	<cffunction name="setSigner" access="public" returntype="any" output="false" hint="I set the message signer and verifier. Returns [this].">
		<cfargument name="newSigner"      type="any" required="true" hint="I am the new message signer." />

		<cfset signer = arguments.newSigner />

		<cfreturn( this ) />
	</cffunction>

	<!--- private --->
	<cffunction name="generateHeaderSegment" access="private" returntype="any" output="false" hint="I generate the header segment of the token using the given header.">
		<cfargument name="header" type="any" required="true" hint="I am the header to be serialized." />

		<cfset local.serializedHeader = jsonEncoder.encode( header ) />

		<cfreturn( base64urlEncoder.encode( local.serializedHeader ) ) />
	</cffunction>


	<cffunction name="generatePayloadSegment" access="private" returntype="any" output="false" hint="I generate the payload segment of the token using the given payload.">
		<cfargument name="payload" type="any" required="true" hint="I am the payload to be serialized." />

		<cfset local.serializedPayload = jsonEncoder.encode( arguments.payload ) />

		<cfreturn base64urlEncoder.encode( local.serializedPayload ) />
	</cffunction>


	<cffunction name="generateSignatureSegment" access="private" returntype="any" output="false" hint="I generate the signature for the given portions of the token. The signature is returned as a base64url-encoded string.">
		<cfargument name="header"  type="string" required="true" hint="I am the serialized header." />
		<cfargument name="payload" type="string" required="true" hint="I am the serialized payload." />

		<cfset local.hashedBytes = signer.sign( charsetDecode( "#arguments.header#.#arguments.payload#", "utf-8" ) ) />

		<cfreturn base64urlEncoder.encodeBytes( hashedBytes ) />
	</cffunction>
</cfcomponent>

