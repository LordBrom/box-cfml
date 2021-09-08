/**
 * Box service layer for file objects.
 */
component output="false" hint="Box service layer for file objects." {
	this.objectName = "collaborations";

	public collaboration function init(
		boxAPIHandler boxAPIHandler
	) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public struct function create(
		required string itemBoxID,
		required string accessibleByBoxID,
		required string accessibleType,
		required string role,
		required string asUserID
	) output=false {
		local.boxID = "";
		local.jsonBody = structNew();
		local.jsonBody['item'] = structNew();
		local.jsonBody['item']['type'] = "folder";
		local.jsonBody['item']['id']   = arguments.itemBoxID;
		local.jsonBody['accessible_by'] = structNew();
		local.jsonBody['accessible_by']['type'] = arguments.accessibleType;
		local.jsonBody['accessible_by']['id']   = arguments.accessibleByBoxID;
		local.jsonBody['role'] = lCase(arguments.role);
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			queryparam = "notify=false",
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function get(
		required string collaborationID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.collaborationID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

}
