component extends="testbox.system.BaseSpec" accessors="true" {


/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		try {
			request.boxTestFolderID = application.boxService.createFolder(folderName = "TestFolder_#createUUID()#");
		} catch (exType exName) {
			throw( message="Could not create test folder" );
		}
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		try {
			application.boxService.deleteFolder(folderID = request.boxTestFolderID);
		} catch (exType exName) {
			throw( message="Could not delete test folder" );
		}
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe("Uploading a file", function(){
			it( "upload file", function(){
				expect( true ).toBeTrue();
			});
		});
	}
}
