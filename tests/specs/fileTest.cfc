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
		describe("Managing Files", function(){
			it( "Uploads a file", function(){
				expect( true ).toBeTrue();
			});

			it( "Download a file", function(){
				expect( true ).toBeTrue();
			});

			it( "Get info of a file", function(){
				expect( true ).toBeTrue();
			});

			it( "Update a file", function(){
				expect( true ).toBeTrue();
			});

			it( "Copy a file", function(){
				expect( true ).toBeTrue();
			});

			it( "Get collaborations for a file", function(){
				expect( true ).toBeTrue();
			});

			//it( "Create upload session a file", function(){
			//	expect( true ).toBeTrue();
			//});

			it( "Uploads a new version of a file", function(){
				expect( true ).toBeTrue();
			});

			it( "List file versions", function(){
				expect( true ).toBeTrue();
			});

			it( "Get file version", function(){
				expect( true ).toBeTrue();
			});

			it( "Revert file to version", function(){
				expect( true ).toBeTrue();
			});

			it( "Delete file version", function(){
				expect( true ).toBeTrue();
			});

			it( "Delete a file", function(){
				expect( true ).toBeTrue();
			});
		});
	}
}
