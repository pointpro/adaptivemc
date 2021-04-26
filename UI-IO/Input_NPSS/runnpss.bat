@echo off
rem ******************************************************************************
rem © Copyright 2003. The U.S. Government, as Represented by the Administrator of
rem the National Aeronautics and Space Administration (NASA). All rights reserved.
rem Includes content licensed from the U.S. Government, National Aeronautics and
rem Space Administration under United States Copyright Registration Numbers
rem V3503D364 and V3482D344.
rem © 2008-2016 NPSS® Consortium, www.NPSSConsortium.org/AllRightsReserved
rem ******************************************************************************

rem ******************************************************************************
rem NPSS® software and related documentation is export controlled with an Export
rem Control Classification Number(ECCN) of 9D991, controlled for Anti-Terrorism
rem reasons, under U.S. Export Administration Regulations 15 CFR 730-774. It may
rem not be transferred to a country checked under anti-terrorism on the Commerce
rem Country Chart structure or to foreign nationals of those countries in the U.S.
rem or abroad without first obtaining a license from the Bureau of Industry and
rem Security, United States Department of Commerce. Violations are punishable by
rem fine, imprisonment, or both.
rem ******************************************************************************

rem ******************************************************************
rem *** This batch file will run NPSS under Windows
rem ******************************************************************
rem *** runNPSS
rem *** runNPSS help
rem *** runNPSS [[options] filename]
rem ******************************************************************

if [%1] == [?]    goto HELP
if [%1] == [help] goto HELP
if [%1] == [HELP] goto HELP
goto START

:HELP
echo Enter one of the following:
echo   runNPSS
echo   runNPSS help
echo   runNPSS [[options] filename]
goto EXIT

rem ***************************************************************************
rem ** set up the NPSS environment
rem ** if running from an NPSS directory structure, then use the local version
rem ** of NPSS, otherwise use any existing values for the NPSS environment
rem ** variables: %NPSS_TOP%, %NPSS_CONFIG% and %VBS_HOME%
rem ***************************************************************************

:START
set ORIG_DIR=%CD%
cd ..
if NOT exist bin\npssle.nt.exe  goto TOP
set NPSS_TOP=%CD%
cd "%ORIG_DIR%"
goto CONFIG

:TOP
cd "%ORIG_DIR%"
if NOT "%NPSS_TOP%"=="" goto CONFIG

:NOTOP
echo %%NPSS_TOP%% has not been set.
echo Tried %CD%, but bin\npss.nt.exe not found.
echo Your NPSS environment does not appear to be set up correctly.
cd "%ORIG_DIR%"
goto EXIT

:CONFIG
if "%NPSS_CONFIG%"==""  set NPSS_CONFIG=nt

rem ******************************************************************
rem ** Verify that the executable can be found.
rem ******************************************************************

if exist "%NPSS_TOP%\bin\npssle.nt.exe" goto PATHS
echo "%NPSS_TOP%\bin\npssle.nt.exe not found"
goto EXIT


rem ******************************************************************
rem ** Some sites may not want to postpend these paths for all their
rem ** users, as they may want to allow them not to specify the NPSS
rem ** standard interpreted includes nor the DLM components.
rem ******************************************************************

:PATHS
setlocal

:NPSSPATH
if not "%NPSS_PATH%"=="" goto DCLODPATH
set NPSS_PATH=%NPSS_TOP%\InterpIncludes
if not "%META_PATH%"=="" set NPSS_PATH=%NPSS_PATH%;%META_PATH%


:DCLODPATH
if not "%DCLOD_PATH%"=="" goto ICLODPATH
set DCLOD_PATH=%NPSS_TOP%\DLMComponents\%NPSS_CONFIG%

set TMPDIR=%NPSS_TOP%\AirBreathing\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\Contributions\Components\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\DataViewers\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\DLMdevkit\Examples\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\Executive\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\ExternalComponents\FileWrapper\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\HDFFile\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\FluidNetwork\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\ThermoPackages\DLMComponents\%NPSS_CONFIG%
if exist "%TMPDIR%" set DCLOD_PATH=%DCLOD_PATH%;%TMPDIR%


:ICLODPATH
if not "%ICLOD_PATH%"=="" goto RUN
set ICLOD_PATH=%NPSS_TOP%\InterpComponents

set TMPDIR=%NPSS_TOP%\AirBreathing\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\Contributions\Components\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\DataViewers\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\DLMdevkit\Examples\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\ExternalComponents\FileWrapper\InterpComponent
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\HDFFile\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\FluidNetwork\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%

set TMPDIR=%NPSS_TOP%\ThermoPackages\InterpComponents
if exist "%TMPDIR%" set ICLOD_PATH=%ICLOD_PATH%;%TMPDIR%


:RUN

rem **
rem ** Now set up, run npss
rem **

rem **
rem ** Parse the inputs to make sure that if display info is requested, 
rem ** that -v is not overly applied (no -v)
rem **
set ARGS=
:Loop
IF "%1"=="" GOTO OutLoop
	IF "%1"=="-version" GOTO NoDashV
	IF "%1"=="-arch" GOTO NoDashV
	IF "%1"=="-comp" GOTO NoDashV
	IF "%1"=="-v" GOTO NoDashV
	IF "%1"=="-build" GOTO NoDashV
	set ARGS= -v
    :NoDashV
SHIFT
GOTO Loop
:OutLoop

rem ** Run npss
"%NPSS_TOP%\bin\npssle.nt.exe" %ARGS% %*
endlocal

:EXIT
