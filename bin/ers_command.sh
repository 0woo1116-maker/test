#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# OS specific support.  $var _must_ be set to either true or false.
darwin=false
case "`uname`" in
Darwin*) darwin=true;;
esac

#------------- Find JRE_HOME or JAVA_HOME -----------------
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  if $darwin; then
    if [ -x '/usr/libexec/java_home' ] ; then
      export JAVA_HOME=`/usr/libexec/java_home`
    elif [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home" ]; then
      export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
    fi
  else
    JAVA_PATH=`which java 2>/dev/null`
    if [ "x$JAVA_PATH" != "x" ]; then
      JAVA_PATH=`dirname $JAVA_PATH 2>/dev/null`
      JRE_HOME=`dirname $JAVA_PATH 2>/dev/null`
    fi
    if [ "x$JRE_HOME" = "x" ]; then
      # XXX: Should we try other locations?
      if [ -x /usr/bin/java ]; then
        JRE_HOME=/usr
      fi
    fi
  fi
  if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
    echo "Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
    echo "At least one of these environment variable is needed to run this program"
    exit 1
  fi
fi
if [ -z "$JRE_HOME" ]; then
  JRE_HOME="$JAVA_HOME"
fi

#---------------------------------------------------------
# Start Script for the ERS Command Line Manager 8.0
#---------------------------------------------------------
# Environment Variables
#
# ERS_HOME           May point at your ERS installation directory
# JRE_HOME           Must point at your Java Runtime Environment installation. (jre6 or later version)
# JAVA_HOME          Must point at your Java Development Kit installation. (jdk6 or later version) 
# JAVA_OPTIONS       (Optional) Java runtime options used when the java(start) command is executed
# ERS_LIB            jar files or directories to the RD Server
# WEB_INF_LIB        ERS Server jar files
# ERS_CONFIG         ERS Server conf directory. If you changed it in web.xml, you need to change it the same.
# ERS_LOG            ERS Server log directory. If you changed it in web.xml, you need to change it the same.
# ERS_LICENSE        ERS Server license directory. If you changed it in web.xml, you need to change it the same.
# ERS_TEMP           ERS Server temp directory. If you changed it in web.xml, you need to change it the same.

# $Id: ers_command.sh,v 8.0 2024/07/19
#---------------------------------------------------------------------------


#------------------ Set ERS Environments ------------------
ERS_HOME=`cd "../";pwd`

ERS_LOG="$ERS_HOME"/WEB-INF/log
ERS_CONFIG="$ERS_HOME"/WEB-INF/conf
WEB_INF_LIB="$ERS_HOME"/WEB-INF/lib

ERS_LIB=.
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/gwt-servlet.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/ers-manager-ctrl.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/ers-manager.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/ers-reporting-core.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/activation-1.1.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/commons-email-1.2.jar
ERS_LIB="$ERS_LIB":"$WEB_INF_LIB"/mail.jar
ERS_LIB="$ERS_LIB":"$ERS_HOME"/bin/commons-cli-1.3.1.jar
ERS_LIB="$ERS_LIB":"$ERS_HOME"/bin/ers-common.jar
ERS_LIB="$ERS_LIB":"$ERS_HOME"/bin/ers-command.jar

#Add on java options 
JAVA_OPTIONS="-Dserver.home="$ERS_HOME" -Dserver.config="$ERS_CONFIG" -Dserver.log="$ERS_LOG" -Dserver.license="$ERS_LICENSE" -Dserver.temp="$ERS_TEMP

# -------------------- Start ERS Daemon --------------------
echo "Running Command Line Manager...."
echo "Using ERS_HOME: $ERS_HOME"
echo "Using JRE_HOME: $JRE_HOME"
echo "Using CLASSPATH: $ERS_LIB"

"$JRE_HOME"/bin/java $JAVA_OPTIONS -classpath .:"$ERS_LIB" m2soft.ers.command.ErsCommand $*
