<!-------------------------------------------------------------------------------------------------------------------------------
The files within jwtTools have been copied from Ben Nadel's code found here, https://github.com/bennadel/JSONWebTokens.cfc.
It has been abridged to just contain what is required for the Box API.
As well as converted to CFML.
------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent name="JsonWebTokens" output="false" hint="I provide a ColdFusion gateway for creating and consuming JSON Web Tokens (JWT).">

	<cffunction name="init" access="public" returntype="any" output="false" hint="I initialize the JSON Web Tokens gateway. The gateway can create clients; or, it can proxy a client for ease-of-use.">
		<cfreturn this />
	</cffunction>

	<!---
		I create a JSON Web Token client that can encode() and decode() JWT values. If the
		algorithm is an Hmac-based algorithm, only the secret key is required. If the
		algorithm is an RSA-based algorithm, both the public and private keys are required
		(and assumed to be in PEM format).
	--->
	<cffunction name="createClient" access="public" returntype="any" output="false" hint="I create a JSON Web Token client that can encode() and decode() JWT values">
		<cfargument name="key"        type="string" required="true" hint="If the algorithm is Hmac, I am the secret key. If RSA, I am the public key in PEM format." />
		<cfargument name="privateKey" type="string" required="true" hint="If the algorithm is RSA, I am the private key in PEM format." />

		<cfset local.return = structNew() />

		<cfset local.jwtClient = createObject("component", "client.JsonWebTokensClient").init(
				createObject("component", "encode.JsonEncoder").init(),
				createObject("component", "encode.Base64urlEncoder").init(),
				createObject("component", "sign.RSASigner").init( "SHA256withRSA", arguments.key, arguments.privateKey )
		) />
		<cfreturn local.jwtClient />
	</cffunction>

	<!---
		NOTE: If you plan to use the same key and algorithm for a number of operations,
		it would be more efficient to create and cache a web-tokens client instead of using
		this one-off method.
 	--->
	<cffunction name="decode" access="public" returntype="any" output="false" hint="I decode the given JSON Web Token and return the deserialized payload.">
		<cfargument name="token"      type="string" required="true"  hint="I am the JSON Web Token being decoded." />
		<cfargument name="algorithm"  type="string" required="true"  hint="I am the algorithm to be used to verify the signature." />
		<cfargument name="key"        type="string" required="true"  hint="If the algorithm is Hmac, I am the secret key. If RSA, I am the public key in PEM format." />
		<cfargument name="privateKey" type="string" required="false" hint="If the algorithm is RSA, I am the private key in PEM format." />

		<cfreturn( createClient( algorithm, key, privateKey ).decode( token ) ) />
	</cffunction>

	<!---
		NOTE: If you plan to use the same key and algorithm for a number of operations,
		it would be more efficient to create and cache a web-tokens client instead of using
		this one-off method.
	--->
	<cffunction name="encode" access="public" returntype="any" output="false" hint="I encode the given payload and return the JSON Web Token.">
		<cfargument name="payload"    type="string" required="true"  hint="I am the payload being encoded for transport." />
		<cfargument name="algorithm"  type="string" required="true"  hint="I am the algorithm to be used to generate the signature." />
		<cfargument name="key"        type="string" required="false" hint="If the algorithm is Hmac, I am the secret key. If RSA, I am the public key in PEM format." />
		<cfargument name="privateKey" type="string" required="false" hint="If the algorithm is RSA, I am the private key in PEM format." />

		<cfreturn( createClient( algorithm, key, privateKey ).encode( payload ) ) />
	</cffunction>
</cfcomponent>