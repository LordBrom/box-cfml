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


		describe("Managing Folders", function(){
			folderTestID = "";
			it( "Create a folder", function(){
				folderTestID = application.boxService.createFolder(
					parentID = request.boxTestFolderID,
					folderName = "TestFolder"
				);
				expect( folderTestID ).toBeNumeric();
			});

			copyFolderTestID = "";
			it( "Copy a folder", function(){
				copyFolderTestID = application.boxService.createFolder(
					parentID = request.boxTestFolderID,
					folderName = "TestFolder_copy"
				);
				expect( folderTestID ).toBeTrue();
			});

			it( "Get contents of a folder", function(){
				local.folderContents = application.boxService.getFolderContents(
					folderID = request.boxTestFolderID
				);
				expect( structKeyExists(local.folderContents, 'entries') ).toBeTrue();
				expect( local.folderContents.entries ).toBeTypeOf( 'array' );
				expect( arrayLen(local.folderContents.entries) ).toBe( 2 );
			});

			it( "Update a folder", function(){
				local.updateFolderTest = application.boxService.updateFolder(
					folderID = folderTestID,
					folderName = "TestFolder EDITED"
				);
				expect( local.updateFolderTest.STATUSCODE ).toBe( '200 OK' );
			});

			it( "Get info of a folder", function(){
				local.folderInfo = application.boxService.getFolderInfo(
					folderID = folderTestID
				);
				expect( structKeyExists(local.folderInfo, 'id') ).toBeTrue();
				expect( structKeyExists(local.folderInfo, 'item_collection') ).toBeTrue();
				expect( structKeyExists(local.folderInfo, 'name') ).toBeTrue();
				expect( structKeyExists(local.folderInfo, 'description') ).toBeTrue();
				expect( local.folderInfo.name ).toBe( 'TestFolder EDITED' );
			});

			it( "get collaborations a folder", function(){
				local.folderCollaborationTest = application.boxService.getFolderCollaborations(
					folderID = folderTestID
				);
				expect( structKeyExists(local.folderCollaborationTest, 'entries') ).toBeTrue();
				expect( local.folderCollaborationTest.entries ).toBeTypeOf( 'array' );
				expect( arrayLen(local.folderCollaborationTest.entries) ).toBe( 0 );
			});

			it( "Delete a folder", function(){

				local.deleteFolderTest = application.boxService.deleteFolder(folderID = folderTestID);
				expect( local.deleteFolderTest.STATUSCODE ).toBe( '204 No Content' );

				local.deleteCopyFolderTest = application.boxService.deleteFolder(folderID = copyFolderTestID);
				expect( local.deleteCopyFolderTest.STATUSCODE ).toBe( '204 No Content' );
			});
		});
	}
}
