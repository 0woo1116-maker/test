@echo off

rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.

if not "%JAVA_HOME%" == "" goto gotJdkHome
if not "%JRE_HOME%" == "" goto gotJreHome
echo Neither the JAVA_HOME nor the JRE_HOME environment variable is defined
echo At least one of these environment variable is needed to run this program
goto eof

:gotJreHome
if not exist "%JRE_HOME%\bin\java.exe" goto noJavaHome
if not exist "%JRE_HOME%\bin\javaw.exe" goto noJavaHome
goto okJavaHome

:gotJdkHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javaw.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\jdb.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javac.exe" goto noJavaHome
if not "%JRE_HOME%" == "" goto okJavaHome
set "JRE_HOME=%JAVA_HOME%"
goto okJavaHome

:noJavaHome
echo The JAVA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
echo NB: JAVA_HOME should point to a JDK not a JRE
goto eof

:okJavaHome
set ERS_HOME=..
set JAVA_EXE="%JRE_HOME%\bin\java.exe"

:check_ers_home
if not "%ERS_HOME%"== "" goto start
echo [ERROR] Unable to determine the value of ERS_HOME.
goto eof

:start

rem --------------------------------------------------------------------------
rem  Start Script for the ERS Command Line Manager 8.0
rem --------------------------------------------------------------------------
rem
rem  Environment Variable Prequisites
rem
rem  ERS_HOME         May point at your ERS "installation" directory.
rem  JRE_HOME         Must point at your Java Runtime Environment installation. (jre6 or later version)
rem  JAVA_HOME        Must point at your Java Development Kit installation. (jdk1.6 or later version)
rem  JAVA_EXE         Excution path of your Java Runtime Environment.
rem  JAVA_OPTION      (Optional) Java runtime options used when the "start"
rem  ERS_LIB          ERS jar files
rem  WEB_INF_LIB      ERS Server jar files
rem  ERS_CONFIG       ERS Server conf directory. If you changed it in web.xml, you need to change it the same.
rem  ERS_LOG          ERS Server log directory. If you changed it in web.xml, you need to change it the same.
rem  ERS_LICENSE      ERS Server license directory. If you changed it in web.xml, you need to change it the same.
rem  ERS_TEMP         ERS Server temp directory. If you changed it in web.xml, you need to change it the same.

rem  $Id: ers_command.bat,v 8.0 2024/07/19
rem ---------------------------------------------------------------------------

set ERS_HOME=..
set ERS_LOG=%ERS_HOME%\WEB-INF\log
set ERS_CONFIG=%ERS_HOME%\WEB-INF\conf
set WEB_INF_LIB=%ERS_HOME%\WEB-INF\lib

set ERS_LIB=.
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\gwt-servlet.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\ers-manager-ctrl.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\ers-manager.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\ers-reporting-core.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\activation-1.1.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\commons-email-1.2.jar
set ERS_LIB=%ERS_LIB%;%WEB_INF_LIB%\mail.jar
set ERS_LIB=%ERS_LIB%;commons-cli-1.3.1.jar
set ERS_LIB=%ERS_LIB%;ers-common.jar
set ERS_LIB=%ERS_LIB%;ers-command.jar

set JAVA_OPTIONS=-Dserver.home="%ERS_HOME%" -Dserver.config="%ERS_CONFIG%" -Dserver.log="%ERS_LOG%" -Dserver.license="%ERS_LICENSE%" -Dserver.temp="%ERS_TEMP%"

REM 프로그램 실행
echo Running Command Line Manager...
echo Using JAVA_PATH: %JAVA_EXE%
echo Using ERS_HOME: %ERS_HOME%
echo Using CLASSPATH: %ERS_LIB%

%JAVA_EXE% %JAVA_OPTIONS% -cp %ERS_LIB% m2soft.ers.command.ErsCommand %*
