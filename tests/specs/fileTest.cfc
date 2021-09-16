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
			//application.boxService.deleteFolder(folderID = request.boxTestFolderID);
		} catch (exType exName) {
			throw( message="Could not delete test folder" );
		}
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		describe("Managing Files", function(){
			it( "Uploads a file", function(){
				testFileName = "testFile#replace(createUUID(), "-", "", "ALL")#.txt";
				testFileContent = createUUID();
				local.testFilePath = getTempDirectory() & testFileName;
				fileWrite(local.testFilePath, testFileContent);

				fileTestID = application.boxService.uploadFile(
					fileName = testFileName,
					filePath = local.testFilePath,
					parentID = request.boxTestFolderID
				);
				expect( fileTestID ).toBeNumeric();
				fileDelete(local.testFilePath);
			});

			it( "Download a file", function(){
				local.testFile = application.boxService.downloadFile(
					fileID = fileTestID
				);
				expect( local.testFile.STATUSCODE ).toBe( '200 OK' );
				expect( trim(toString(local.testFile.CONTENT)) ).toBe( testFileContent );
			});

			it( "Update a file", function(){
				newTestFileName = "testFile#replace(createUUID(), "-", "", "ALL")#.txt";
				local.updatedFile = application.boxService.updateFile(
					fileID = fileTestID,
					fileName = newTestFileName
				);
				expect( local.updatedFile.STATUSCODE ).toBe( '200 OK' );
			});

			it( "Get info of a file", function(){
				local.testFileInfo = application.boxService.getFileInfo(
					fileID = fileTestID
				);
				expect( local.testFileInfo.STATUSCODE ).toBe( '200 OK' );
				expect( local.testFileInfo.name ).toBe( newTestFileName );
			});

			it( "Copy a file", function(){
				copiedTestFileName = "testFile#replace(createUUID(), "-", "", "ALL")#.txt";
				local.copyFile = application.boxService.copyFile(
					sourceID = fileTestID,
					parentID = request.boxTestFolderID,
					fileName = copiedTestFileName
				);
				expect( local.copyFile.STATUSCODE ).toBe( '201 Created' );
			});

			it( "Get collaborations for a file", function(){
				local.fileCollaborations = application.boxService.getFileCollaborations(
					fileID = fileTestID
				);
				expect( local.fileCollaborations.STATUSCODE ).toBe( '200 OK' );
				expect( structKeyExists(local.fileCollaborations, "entries") ).toBeTrue();
			});

			//it( "Create upload session a file", function(){
			//	expect( true ).toBeTrue();
			//});

			it( "Uploads a new version of a file", function(){
				testFileContent = createUUID();
				local.testFilePath = getTempDirectory() & testFileName;
				fileWrite(local.testFilePath, testFileContent);

				newTestFileVersionID = application.boxService.uploadFile(
					fileName = testFileName,
					fileID = fileTestID,
					filePath = local.testFilePath
				);
				expect( newTestFileVersionID ).toBeNumeric();
				expect( newTestFileVersionID ).toBe( fileTestID );
				fileDelete(local.testFilePath);
			});

			it( "List file versions", function(){
				local.fileVersions = application.boxService.listFileVersions(
					fileID = newTestFileVersionID
				);
				firstVersionID = local.fileVersions.entries[1].id;
				expect( local.fileVersions.STATUSCODE ).toBe( '200 OK' );
				expect( structKeyExists(local.fileVersions, "entries") ).toBeTrue();
			});

			it( "Get file version", function(){
				local.firstVersion = application.boxService.getFileVersion(
					versionID = firstVersionID,
					fileID = fileTestID
				);
				expect( local.firstVersion.STATUSCODE ).toBe( '200 OK' );
				expect( local.firstVersion.type ).toBe( 'file_version' );
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
