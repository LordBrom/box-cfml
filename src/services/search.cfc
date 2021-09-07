/**
 * Box service layer for searching for objects.
 */
component output="false" hint="Box service layer for searching for objects." {
	this.objectName = "search";

	public search function init(boxAPIHandler boxAPIHandler) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public any function searchForContent(required string query, required string file_extensions, required string type, required numeric limit, required string asUserID) output=false {
		local.return = structNew();
		local.queryParams = "query=#arguments.query#";
		if ( len(arguments.file_extensions) ) {
			local.queryParams &= "file_extensions=#arguments.file_extensions#";
		}
		if ( len(arguments.type) ) {
			local.queryParams &= "type=#arguments.type#";
		}
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object      = this.objectName,
			queryParams = local.queryParams,
			httpMethod  = "GET",
			userID      = arguments.asUserID
		);
		return local.apiResponse;
	}

}
