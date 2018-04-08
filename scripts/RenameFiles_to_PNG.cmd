@echo off

set ScriptName=%~nx0
for %%f in (*.*) DO (
	REM Copy all files except the current script ...
	IF NOT %%f == %ScriptName% (
		copy %%f %%f.png		
	)
)
PAUSE