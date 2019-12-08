<cfcomponent output="false" hint="I provide sign and verify methods for RSA-based signing.">

	<!---
		NOTE: The algorithm uses the names provided in the Java Cryptography Architecture
		Standard Algorithm Name documentation:

		- SHA256withRSA
		- SHA384withRSA
		- SHA512withRSA

		CAUTION: The keys are assumed to be in PEM format.
	 --->
	<cffunction name="init" access="public" returntype="any" output="false" hint="I create a new RSA Signer using the given algorithm and public and private keys.">
		<cfargument name="algorithm"  type="string" required="true" hint="I am the RSA-based signature algorithm being used." />
		<cfargument name="publicKey"  type="string" required="true" hint="I am the plain-text public key." />
		<cfargument name="privateKey" type="string" required="true" hint="I am the plain-text private key." />

		<cfset setAlgorithm( algorithm ) />
		<cfset setPublicKeyFromText( publicKey ) />
		<cfset setPrivateKeyFromText( privateKey ) />

		<cfreturn this />
	</cffunction>

	<!---
		NOTE: The algorithm uses the names provided in the Java Cryptography Architecture
		Standard Algorithm Name documentation:

    	- SHA256withRSA
    	- SHA384withRSA
		- SHA512withRSA
	--->
	<cffunction name="setAlgorithm" access="public" returntype="any" output="false" hint="I set the given RSA algorithm. Returns [this].">
		<cfargument name="newAlgorithm" type="string" required="true" hint="I am the RSA-based signature algorithm being set." />

		<cfset testAlgorithm( arguments.newAlgorithm ) />

		<cfset algorithm = arguments.newAlgorithm />

		<cfreturn this />
	</cffunction>

	<!--- NOTE: Keys are expected to be in PEM format. --->
	<cffunction name="setPublicKeyFromText" access="public" returntype="any" output="false" hint="I set the public key using the plain-text public key content. Returns [this].">
		<cfargument name="newPublicKeyText" type="string" required="true" hint="I am the plain-text public key." />

		<cfset testKey( arguments.newPublicKeyText ) />

		<cfset local.publicKeySpec = createObject( "java", "java.security.spec.X509EncodedKeySpec" ).init(
			binaryDecode( stripKeyDelimiters( arguments.newPublicKeyText ), "base64" )
		) />

		<cfset publicKey = createObject( "java", "java.security.KeyFactory" )
			.getInstance( javaCast( "string", "RSA" ) )
			.generatePublic( local.publicKeySpec )
		/>

		<cfreturn this />
	</cffunction>

	<!--- NOTE: Keys are expected to be in PEM format. --->
	<cffunction name="setPrivateKeyFromText" access="public" returntype="any" output="false" hint="I set the private key using the plain-text private key content. Returns [this].">
		<cfargument name="newPrivateKeyText" type="string" required="true" hint="I am the plain-text private key." />

		<cftry>
			<cfset testKey( arguments.newPrivateKeyText ) />

			<cfset local.privateKeySpec = createObject( "java", "java.security.spec.PKCS8EncodedKeySpec" ).init(
				binaryDecode( stripKeyDelimiters( arguments.newPrivateKeyText ), "base64" )
			) />

			<cfset privateKey = createObject( "java", "java.security.KeyFactory" ).getInstance(
					javaCast( "string", "RSA" )
				).generatePrivate( local.privateKeySpec )
			/>

			<cfcatch type="any">
				<cfif cfcatch.message EQ "Invalid RSA private key encoding.">
					<cfset addBouncyCastleProvider() />
					<cfreturn setPrivateKeyFromText( arguments.newPrivateKeyText ) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

	<!---
		I add the BounceCastleProvider to the underlying crypto APIs.

		CAUTION: I don't really understand why this is [sometimes] required. But, if you
		run into the error, "Invalid RSA private key encoding.", adding BouncyCastle may
		solve the problem.

		This method only needs to be called once per ColdFusion application life-cycle.
		But, it can be called multiple times without error.
	--->
	<cffunction name="addBouncyCastleProvider" access="public" returntype="void" output="false" hint="I set the private key using the plain-text private key content. Returns [this].">
		<cfset createObject( "java", "java.security.Security" ).addProvider(
				createObject( "java", "org.bouncycastle.jce.provider.BouncyCastleProvider" ).init()
			)
		/>
	</cffunction>

	<cffunction name="testAlgorithm" access="public" returntype="void" output="false" hint="I test the given algorithm. If the algorithm is not valid, I throw an error.">
		<cfargument name="newAlgorithm" type="string" required="true" hint="I am the new RSA algorithm being tested." />

		<cfswitch expression="#arguments.newAlgorithm#">
			<cfcase value="SHA256withRSA,SHA384withRSA,SHA512withRSA">
				<cfreturn />
			</cfcase>
		</cfswitch>
		<cfthrow
			type    = "JsonWebTokens.RSASigner.InvalidAlgorithm"
			message = "The given algorithm is not supported."
			detail  = "The given algorithm [#newAlgorithm#] is not supported."
		/>
	</cffunction>

	<cffunction name="testKey" access="public" returntype="void" output="false" hint="I test the given key (public or private). If the key is not valid, I throw an error.">
		<cfargument name="newKey" type="string" required="true" hint="I am the new key being tested." />

		<cfif NOT len(stripKeyDelimiters( arguments.newKey )) >
			<cfthrow
				type    = "JsonWebTokens.RSASigner.InvalidKey"
				message = "The key cannot be blank."
			/>
		</cfif>
	</cffunction>

	<cffunction name="sign" access="public" returntype="binary" output="false" hint="I sign the given binary message using the current algorithm and private key.">
		<cfargument name="message" type="binary" required="true" hint="I am the message being signed." />

		<cfset local.signer = createObject( "java", "java.security.Signature" ).getInstance( javaCast( "string", algorithm ) ) />

		<cfset local.signer.initSign( privateKey ) />
		<cfset local.signer.update( arguments.message ) />

		<cfreturn local.signer.sign() />
	</cffunction>


	<!--- Private --->

	<cffunction name="stripKeyDelimiters" access="private" returntype="string" output="false" hint="I strip the plain-text key delimiters, to isolate the key content.">
		<cfargument name="keyText" type="string" required="true" hint="I am the plain-text key input." />

		<!--- Strips out the leading / trailing boundaries: --->
		<cfset arguments.keyText = reReplace( arguments.keyText, "-----(BEGIN|END)[^\r\n]+", "", "all" ) />

		<cfreturn( trim( arguments.keyText ) ) />
	</cffunction>
</cfcomponent>