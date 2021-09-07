/**
 * Contains functions that interact with the Box.com API via http calls
 */
component output="false" hint="Contains functions that interact with the Box.com API via http calls" {
	this.boxAPIURL       = "https://api.box.com/";
	this.boxAPIUploadURL = "https://upload.box.com/api/"; //  used for file upload only
	this.boxAPIVersion   = "2.0";

	public boxAPIHandler function init(
		required string boxAPIlogDatasource="",
		required string boxAPIlogTableName=""
	) output=false {
		variables.boxAuth = createObject("component", "boxAuthentication");
		variables.JWT     = createObject("component", "jwtTools.lib.JsonWebTokens");

		variables.access_token = "";
		variables.expires_in   = "";
		variables.issued_at    = "";
		variables.defaultUserID = variables.boxAuth.getDefaultUserID();

		if ( len(arguments.boxAPIlogDatasource) && len(arguments.boxAPIlogTableName) ) {
			variables.boxAPILog = createObject("component", "boxAPILogHandler").init(arguments.boxAPIlogDatasource, arguments.boxAPIlogTableName);
		}

		return this;
	}

	public any function makeRequest(
		required string object="",
		required string objectID="",
		required string method="",
		required string queryParams="",
		required struct jsonBody="#structNew()#",
		required string httpMethod="POST",
		required string userID="",
		required string filePath="",
		required string getasbinary="no",
		required boolean debug="false"
	) output=false {
		local.return = structNew();
		local.httpParams = arrayNew(1);

		if ( !len(variables.access_token) OR
				dateCompare(now(), dateAdd('s', (variables.expires_in - 60), variables.issued_at)) != -1 ) {
			getAuthorization();
		}

		arrayAppend(local.httpParams, { "type": "Header", "name": "Authorization", "value": variables.access_token });

		if ( len(arguments.userID) ) {
			arrayAppend(local.httpParams, { "type": "Header", "name": "As-User", "value": arguments.userID });
		} else if ( len(variables.defaultUserID) ) {
			arrayAppend(local.httpParams, { "type": "Header", "name": "As-User", "value": variables.defaultUserID });
		}

		if ( arguments.object == "files/upload_sessions" && arguments.httpMethod != 'GET' ) {
			local.url = this.boxAPIUploadURL & this.boxAPIVersion & "/" & arguments.object & "/";
			arrayAppend(local.httpParams, { "type": "formfield",   "name": "attributes", "value": SerializeJSON(arguments.jsonBody) });
			arrayAppend(local.httpParams, { "type": "file",   "name": "file", "file": arguments.filePath });

		} else if ( arguments.object == "files" && arguments.method == "content" && httpMethod == "POST" && len(arguments.filePath) ) {
			local.url = this.boxAPIUploadURL & this.boxAPIVersion & "/" & arguments.object & "/";
			arrayAppend(local.httpParams, { "type": "formfield", "name": "attributes", "value": SerializeJSON(arguments.jsonBody) });
			arrayAppend(local.httpParams, { "type": "file",      "name": "file",       "file": arguments.filePath });

		} else if ( arguments.object == "files" && arguments.method == "content" && httpMethod == "OPTIONS" ) {
			local.url = this.boxAPIURL & this.boxAPIVersion & "/" & arguments.object & "/";
			arrayAppend(local.httpParams, { "type": "Header", "name": "Content-Type", "value": "multipart/form-data" });
			arrayAppend(local.httpParams, { "type": "formfield", "name": "attributes", "value": SerializeJSON(arguments.jsonBody) });

		} else {
			local.url = this.boxAPIURL & this.boxAPIVersion & "/" & arguments.object & "/";
			arrayAppend(local.httpParams, { "type": "Header", "name": "Content-Type", "value": "application/json" });
			arrayAppend(local.httpParams, { "type": "body",   "name": "json",         "value": SerializeJSON(arguments.jsonBody) });
		}

		if ( len(arguments.objectID) ) {
			local.url &= arguments.objectID & "/";
		}
		if ( len(arguments.method) ) {
			local.url &= arguments.method;
		}
		if ( len(arguments.queryParams) ) {
			local.url &= "?" & arguments.queryParams;
		}

		arrayAppend(local.httpParams, { "type": "Header", "name": "Accept", "value": "application/json" });

		return send(
			url         = local.url,
			method      = arguments.httpMethod,
			getasbinary = arguments.getasbinary,
			httpParams  = local.httpParams,
			debug       = arguments.debug
		);
	}

	/**
	 * Gets an autheToken from Box.
	 */
	private void function getAuthorization() output=false {
		//  Initialize local function scope
		local.authorization = '';
		//  Use variables.JWTTools to get the JWTAssertion
		local.jwtAssertion = getJWTAssertion();
		//  call getToken to ping box and get the authToken
		local.authorization = getOAUTHToken(local.jwtAssertion);

		if (not structKeyExists(local.authorization, 'access_token')) {
			throw( message="Did not receive authentication token." );
		}

		variables.access_token  = "Bearer #local.authorization.access_token#";
		variables.expires_in    = local.authorization.expires_in;
	}

	/**
	 * use the environment-based variables to get the
	 */
	private string function getJWTAssertion() output=false {
		local.JWTPayload = getJWTPayload();
		local.jwtClient = variables.JWT.createClient(
			algorithm  = 'RS256',
			key        = variables.boxAuth.getPublicKey(),
			privateKey = variables.boxAuth.getPrivateKey()
		);
		local.return = local.jwtClient.encode(local.JWTPayload, variables.boxAuth.getKeyID());

		return local.return;
	}

	/**
	 * return the default JWT values based on BOX APP console
	 */
	private struct function getJWTPayload() output=false {
		local.return = structNew();
		variables.issued_at = now();
		local.return["exp"] = "#Int(floor(variables.issued_at.getTime()/1000) + 15)#";
		local.return["iss"] = variables.boxAuth.getClientID();
		local.return["sub"] = " #trim(variables.boxAuth.getEnterpriseID())#";
		//  The space before the enterpriseID is required for ColdFusion.
		local.return["box_sub_type"] = "enterprise";
		local.return["aud"] = "#this.boxAPIURL#oauth2/token";
		local.return["jti"] = '#replace(createUUID(), "-", "", "all")#';

		return local.return;
	}

	/**
	 * perform the API Request to get the Auth Token
	 */
	private struct function getOAUTHToken(
		required string jwtAssertion
	) output=false {
		local.url = "#this.boxAPIURL#oauth2/token";
		local.httpParams = arrayNew(1);

		arrayAppend(local.httpParams, { "type": "formfield", "name": "grant_type",    "value": "urn:ietf:params:oauth:grant-type:jwt-bearer" });
		arrayAppend(local.httpParams, { "type": "formfield", "name": "client_id",     "value": variables.boxAuth.getClientID() });
		arrayAppend(local.httpParams, { "type": "formfield", "name": "client_secret", "value": variables.boxAuth.getClientSecret() });
		arrayAppend(local.httpParams, { "type": "formfield", "name": "assertion",     "value": arguments.jwtAssertion });

		local.auth = send(
			url        = local.url,
			method     = "POST",
			httpParams = local.httpParams,
			logCall    = false
		);

		return local.auth;
	}

	/**
	 * send request to REST API
	 */
	private struct function send(
		required string url,
		required string method,
		required boolean getasbinary="no",
		required array httpParams="no",
		required boolean logCall="true",
		required boolean debug="false"
	) output=false {
		local.logID = 0;

		if ( structKeyExists(variables, "boxAPILog") && arguments.logCall ) {
			local.logID = variables.boxAPILog.setLog( argumentCollection = arguments );
		}
		if ( arguments.debug ) {
			writeDump( var=arguments, abort=0 );
		}

		try {
			cfhttp( getasbinary=arguments.getasbinary, throwonerror=false, url=arguments.url, result="local.response", method=arguments.method ) {
				for ( local.itm in arguments.httpParams ) {
					if ( structKeyExists(local.itm, "value") ) {
						cfhttpparam( name=local.itm.name, type=local.itm.type, value=local.itm.value );
					} else if ( structKeyExists(local.itm, "file") ) {
						cfhttpparam( file=local.itm.file, name=local.itm.name, type=local.itm.type );
					}
				}
			}
		} catch (any cfcatch) {
			rethrow;
		}

		if ( local.logID ) {
			variables.boxAPILog.updateLog(
				logID        = local.logID,
				responseCode = local.response.statusCode,
				response     = local.response
			);
		}

		if ( arguments.debug ) {
			writeDump( var=local.response, abort=1 );
		}
		local.return = handleResponse(local.response, arguments.url, arguments.getasbinary);

		return local.return;
	}

	/**
	 * parseResponse from Box API
	 */
	private struct function handleResponse(
		required struct response,
		required string url, string returnBinary="no"
	) output=false {
		local.return = structNew();
		local.return.success = false;
		local.return.statusCode = arguments.response.statusCode;

		switch ( val(left(arguments.response.statusCode, 3)) ) {
			/*
				200 OK
				201 Created
				204 No Content
			 */
			case  200:
			case  201:
			case  204:
				try {
					if ( returnBinary == 'no' && len(arguments.response.fileContent) ) {
						structAppend(local.return, deserializeJSON(arguments.response.fileContent));
					} else {
						local.return.content = arguments.response.fileContent;
					}
					local.return.success = true;
				} catch (any cfcatch) {
					//  could not JSON Parse response; but it was a 200OK
					local.return.success = true;
					rethrow;
				}
				break;

			/*
				409 Conflict - name of object already in use
			 */
			case  409:
				if ( returnBinary == 'no' && len(arguments.response.fileContent) ) {
					structAppend(local.return, deserializeJSON(arguments.response.fileContent));
				} else {
					local.return.content = arguments.response.fileContent;
				}
				break;

			default:
				break;
		}

		return local.return;
	}

}
