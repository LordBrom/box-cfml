/**
* Copyright Since 2005 Ortus Solutions, Corp
* www.ortussolutions.com
**************************************************************************************
*/
component{
	this.name = "A TestBox Runner Suite " & hash( getCurrentTemplatePath() );
	// any other application.cfc stuff goes below:
	this.sessionManagement = true;
	this.mappings = structNew();
	this.mappings['/src'] = getDirectoryFromPath(getCurrentTemplatePath()) & "../src/";

	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// request start
	public boolean function onRequestStart( String targetPage ){
		application.boxService = new src.box();

		return true;
	}
}
