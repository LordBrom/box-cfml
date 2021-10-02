component {
	this.name = "BoxDriveApiExample";
	this.mappings = structNew();
	this.mappings['/src'] = getDirectoryFromPath(getCurrentTemplatePath()) & "../src/";
	this.wschannels = [
        {name:"box"}
	];

	public function onRequest(required string template) {
		application.boxService = new src.box();

		include arguments.template;
	}

}
