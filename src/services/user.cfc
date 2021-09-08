/**
 * Box service layer for folder objects.
 */
component output="false" hint="Box service layer for folder objects." {
	this.objectName = "users";

	public user function init(
		boxAPIHandler boxAPIHandler
	) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public any function getInfo(
		required string userID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.userID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function getCurrentUserInfo(
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			method     = "me",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function createAppUser(
		required string userName,
		required string asUserID
	) output=false {
		local.boxID = "";
		local.jsonBody = structNew();
		local.jsonBody['name'] = arguments.userName;
		local.jsonBody['is_platform_access_only']       = true;
		local.jsonBody['can_see_managed_users']         = true;
		local.jsonBody['is_external_collab_restricted'] = false;
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

}
