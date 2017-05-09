@echo off
rem Generic Copy Script - Copies specified resources between folders with additional checks and cleanup options

rem Check for the latest version under https://github.com/chrfrantz/teaching-scripts.git

rem Revisions:
rem Revision 0.7 - Added ability to delete folders in target drive based on wildcard, e.g. to delete any folder with given prefix (15/11/2016, C. Frantz)
rem Revision 0.61 - Added automatic overwriting of files in target location (01/08/2016, C. Frantz)
rem Revision 0.6 - Added switch to make adjustment of attributes optional (since it requires privileges) (20/05/2016, C. Frantz)
rem Revision 0.5 - Added target location folder/files attributes change; fixed some instructions; added comprehensive checks of error codes (04/04/2015, C. Frantz)
rem Revision 0.4 - Separated source and target image folder variables; added feature to delete all content from target directory prior to copying (17/11/2015, C. Frantz)
rem Revision 0.3 - Internalisation of DELETE variable to overwrite existing content (13/07/2015, C. Frantz)
rem Revision 0.2 - Adaptation as generic copying script (21/04/2015, C. Frantz)
rem Revision 0.1 - Initial revision (19/02/2015, C. Frantz)

rem PARAMETERS

rem generic human-readable description of copied content
SET CONTENT_DESCRIPTION=VMware Image
SET SOURCE_DRIVE=L:
rem SOURCE_MIDFIX needs to contain at least a backslash (\). If specifying a path, add leading and tailing backslashes in folder definitions (ie. \ at start and end)
SET SOURCE_MIDFIX=\Virtual Machines\IN617\
rem Actual leaf folder to be copied from source location. No need to specify slashes.
SET SOURCE_IMAGE_FOLDER=Ubuntu_16.04

SET TARGET_DRIVE=D:
rem Midfix folder path. TARGET_MIDFIX needs to contain at least a backslash (\). If specifying a path, add leading and tailing backslashes in folder definitions (ie. \ at start and end)
SET TARGET_MIDFIX=\IN617_VMs\
rem Actual leaf folder to be created in target location (may differ from source SOURCE_IMAGE_FOLDER). No need to specify slashes.
SET TARGET_IMAGE_FOLDER=Ubuntu_16.04

rem Set to 1 to overwrite target without asking (e.g. spring cleaning) - default should be 0
SET DELETE=0
rem Set to 1 to delete all images in TARGET_MIDFIX prior to copying - WARNING: This may delete unrelated images!
SET DELETE_ALL=0
rem Folder prefix in TARGET_DRIVE that is to be cleaned if DELETE_ALL_IMAGES_IN_TARGET_STARTING_WITH_GIVEN_WILDCARD is activated
SET TARGET_TO_BE_CLEANED_WILDCARD=IN617*
rem Set to 1 to delete all images in TARGET_DRIVE starting with DELETE_ALL_IMAGES_IN_TARGET_STARTING_WITH_GIVEN_WILDCARD - WARNING: This is most broad deletion command!
SET DELETE_ALL_IMAGES_IN_TARGET_STARTING_WITH_GIVEN_WILDCARD=0
rem Set to 1 to change attributes as specified in code below
SET CHANGE_ATTRIBUTES=0

rem CLEAN UP TARGET IF NECESSARY

if %DELETE_ALL_IMAGES_IN_TARGET_STARTING_WITH_GIVEN_WILDCARD% == 1 (goto deleteAllFoldersWithWildcard)

if %DELETE_ALL% == 1 (goto deleteAll)

if %DELETE% == 1 (goto delete) ELSE (goto end)

:delete
echo Deleting original target data ...
if EXIST %TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER% (goto actuallyDelete) ELSE (goto end)
goto end

:actuallyDelete
rd %TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER% /s /q
goto end

:deleteAll
echo Deleting any existing target data ...
if EXIST %TARGET_DRIVE%%TARGET_MIDFIX% (goto actuallyDeleteAll) ELSE (goto end)
goto end

:deleteAllFoldersWithWildcard
echo Deleting any relevant existing folders in %TARGET_DRIVE% ...
rem Deletes all folders with given wildcard recursively without asking.
for /d %%i in (%TARGET_DRIVE%\%TARGET_TO_BE_CLEANED_WILDCARD%) do rd /s /q "%%i"
goto end

:actuallyDeleteAll
rd %TARGET_DRIVE%%TARGET_MIDFIX% /s /q
if %ERRORLEVEL% GEQ 1 (goto faildelete)
goto end


:end
rem PERFORM ACTUAL COPYING

rem Tests for network drive
IF EXIST %SOURCE_DRIVE% (goto yes)

:no
echo Could not find Drive %SOURCE_DRIVE% (Software). 
echo Check that network shares have been properly initialised at startup.
echo If not, open Windows Explorer, type \\op.ac.nz in the Address field on top of the window and press Enter.
echo You should then see the NETLOGON folder. Enter that and doubleclick on the file OTek-Logon.vbs. That should restore all your network shares. Once successful, you can rerun this script.
pause
exit


:yes
echo Copying %CONTENT_DESCRIPTION% %SOURCE_IMAGE_FOLDER% to path %TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER%. 
echo Note that this can take a few minutes!

rem overwrite without asking and manually append '> nul' to suppress any copy output
xcopy /K /R /E /I /S /C /H "%SOURCE_DRIVE%%SOURCE_MIDFIX%%SOURCE_IMAGE_FOLDER%" "%TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER%" /Y > nul
if %ERRORLEVEL% GEQ 1 (goto failcopy)

rem CHANGE ATTRIBUTES
if %CHANGE_ATTRIBUTES% GEQ 1 (goto setattr) else (goto finish)

:setattr
rem Unhide target folder
attrib -h "%TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER%"
if %ERRORLEVEL% GEQ 1 (goto failattr)
rem Unhide target files
attrib -h "%TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER%\*.*"
if %ERRORLEVEL% GEQ 1 (goto failattr)

:finish
echo %CONTENT_DESCRIPTION% copied. It is now ready for use.
echo ======================================================================
echo You can find the %CONTENT_DESCRIPTION% under %TARGET_DRIVE%%TARGET_MIDFIX%%TARGET_IMAGE_FOLDER%
echo ======================================================================
echo Press key to close the window.
pause
exit

:faildelete
echo Deleting of destination folder failed.
pause 
exit

:failcopy
echo File copying failed.
pause
exit

:failattr
echo Changing file attributes after copying failed.
pause
exit
