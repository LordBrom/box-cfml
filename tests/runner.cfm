<cfsetting showDebugOutput="false">

<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.directory"  default="tests" >

<!--- Include the TestBox HTML Runner --->
<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >
