@echo off &cls
SETLOCAL EnableDelayedExpansion 

:CheckParanoid_IsRunning
:: Thanks to https://www.mkyong.com/linux/grep-for-windows-findstr-example/
tasklist | findstr -N "Paranoid PsTool" | find /c ":" | find "3" > nul 2> nul
if %ERRORLEVEL% NEQ 0 (
	echo.
	echo Please check the following processes are running:
	echo ParanoidAgent64.exe
	echo ParanoidLT.exe
	echo PsTool.exe	
	set /a ErrorNum=1
	goto :EXIT_with_Error	
)

sc query paranoid status | find "STATE" | find "RUNNING" > nul 2> nul
if %ERRORLEVEL% NEQ 0 (
	echo Nyotron Paranoid Service is not running
	set /a ErrorNum=2
	goto :EXIT_with_Error
)

sc query pf status | find "STATE" | find "RUNNING" > nul 2> nul
if %ERRORLEVEL% NEQ 0 (
	echo "pf Service is not running (Paranoid mini-filter driver)"
	set /a ErrorNum=3
	goto :EXIT_with_Error
)

:CheckLastIapTime
	set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Nyotron\Paranoid\Conf"
	set VALUE_NAME="LastIapTime"

	REG QUERY %KEY_NAME% /v %VALUE_NAME% > nul 2> nul

	if %ERRORLEVEL% NEQ 0 (
		call :LastIapTimeNotFound
		goto :EOF	
	)

:CheckDatFilesExist
	set ParanoidDatDir=C:\ProgramData\Nyotron\Paranoid
	if NOT EXIST %ParanoidDatDir% (
		call :FolderNotFound %ParanoidDatDir%
		goto :EOF
	)

	:: Thanks to https://stackoverflow.com/a/5552995
	set Newline=^& echo.
	set /a countMissing=0
	for %%f in (IAPVARIABLES.DAT IAPPUBLISHERFOLDERS.DAT CACHEDDATA.DAT) do (
		if NOT EXIST "%ParanoidDatDir%\%%f" (
			set /a countMissing+=1
			set Missing=!Missing!%%f ^!Newline!
		)
	)
	if %countMissing% GTR 0 (
		echo Error: missing the following file^(s^) in %ParanoidDatDir% :
		echo %Missing%
		set /a ErrorNum=5
		goto :EXIT_with_Error
	)

goto :CompletedMsg

:CompletedMsg
	::	  0A  means give me a Black background with Light Green text.
	color 0A
	echo.
	echo =======================================================
	echo Nyotron Paranoid Agent is ready for Performance testing
	echo =======================================================
	echo.
	pause
	cls
	::	  Return the screen color back to what it was before.
	color
	EXIT /B 0

:FolderNotFound
	echo.
	echo Directory %~1 does NOT exist!
	set /a ErrorNum=4
	goto :EXIT_with_Error	
	
:LastIapTimeNotFound
	echo.
	echo Please wait until IAP scan completes and then check again... 
	set /a ErrorNum=6
	goto :EXIT_with_Error	
	
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
