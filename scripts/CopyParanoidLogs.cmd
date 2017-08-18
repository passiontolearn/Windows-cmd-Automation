@echo off &cls
SETLOCAL EnableDelayedExpansion 

set CurrentPath=%~dp0
set ParanoidDir=C:\ProgramData\Nyotron
set LogsZipFile=Logs.zip

::===== Error checking ===========
::
goto :Check7ZipExists
:LeftOversCheck
if NOT EXIST %ParanoidDir% (
 	call :FolderNotFound %ParanoidDir%
	goto :EOF
)
if EXIST %LogsZipFile% (
	call :ZipAlreadyExists
	goto :EOF
)

goto :set_DateTime
:Main
set LogsDirName=Logs__%DateTime%
set CurrentLogsDir="%CurrentPath%\%LogsDirName%"

echo Copying Logs and .DAT files from %ParanoidDir% ...
xcopy /s /i /y /q "%ParanoidDir%\Logs" "%CurrentLogsDir%\Logs"
xcopy /s /i /y /q "%ParanoidDir%\Paranoid\*.DAT" "%CurrentLogsDir%"

:: Zip our Logs folder and inform the User.
7z a %LogsZipFile% "%CurrentLogsDir%"
goto :CompletedMsg

:CompletedMsg
	::	  0A  means give me a Black background with Light Green text.
	color 0A
	echo.
	echo ==================
	echo Completed creating
	echo ==================
	echo %LogsDirName%
	echo Logs.zip
	echo.
	echo Enjoy and be Good. :)
	pause
	cls
	::	  Return the screen color back to what it was before.
	color
	EXIT /B 0
	
:FolderNotFound
	echo.
	echo Directory %~1 does NOT exist!
	set /a ErrorNum=1
	goto :EXIT_with_Error
	
:ZipAlreadyExists
	echo.
	echo *********************************************************************************
	echo * %LogsZipFile% already exists!							*
	echo * You don't just expect me to override it... now, do you ? :)			*
	echo *										*
 	echo * BACKUP the existing %LogsZipFile% file (if needed), delete it and then re-run.	* 
	echo *********************************************************************************
	set /a ErrorNum=2
	goto :EXIT_with_Error

:Check7ZipExists
	:: Thanks to https://stackoverflow.com/a/5552995
	set Newline=^& echo.
	set /a countMissing=0
	for %%f in (7z.exe 7z.dll) do (
		if NOT EXIST "%CurrentPath%\%%f" (
			set /a countMissing+=1
			set Missing=!Missing!%%f ^!Newline!
		)
	)
	if %countMissing% GTR 0 (
		echo Error: missing the following file^(s^) in the current directory :
		echo %Missing%
		set /a ErrorNum=3
		goto :EXIT_with_Error
	)
	goto :LeftOversCheck
	
:set_DateTime
:: Get the current Date and Time
	set year=%date:~10,4%
	set month=%date:~4,2%
	set day=%date:~7,2%
	set hour=%time:~0,2%
	if %hour% lss 12 set hour=0%hour:~1,1%
	set min=%time:~3,2%
	set sec=%time:~6,2%
	set DateTime=%year%-%month%-%day%__%hour%_%min%_%sec%
	::echo %DateTime%
	
	:: Go back to Main()....
	goto :Main	
	
:EXIT_with_Error
	::	  0C  means give me a Black background with Light Red text. See: http://www.dostips.com/DtCodeSnippets.php#Snippets.WindowColor
	color 0C
	echo.	
    echo Exiting ...
	pause
	cls
	
	::	  Return the screen color back to what it was before.
	color
	EXIT /B %ErrorNum%
