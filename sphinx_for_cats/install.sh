#!/bin/bash

#  The contents of this file are subject to the CATS Public License
#   * Version 1.1a (the "License"); you may not use this file except in
#   * compliance with the License. You may obtain a copy of the License at
#   * http://www.catsone.com/
#   *
#   * Software distributed under the License is distributed on an "AS IS"
#   * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
#   * License for the specific language governing rights and limitations
#   * under the License.
#   *
#   * The Original Code is "CATS Standard Edition".
#   *
#   * The Initial Developer of the Original Code is Cognizo Technologies, Inc.
#   * Portions created by the Initial Developer are Copyright (C) 2005 - 2007
#   * (or from the year in which this file was created to the year 2007) by
#   * Cognizo Technologies, Inc. All Rights Reserved.
#
#   Andrew @ July 11, 2007

# DO NOT EDIT THE SETTINGS IN THIS FILE
# Most of the settings will be autodetected or asked for when the script
# executes. Changing anything below will only change what the suggested
# values are.

# Default settings (if not autodetected)
WWW_PATH='/var/www/html/cats'
DATABASE_NAME='cats'
DATABASE_USER='cats'
DATABASE_PASS='password'
DATABASE_PORT='3306'
DATABASE_HOST='localhost'

# Ascii Terminal Colors
ASCII_BOLD="\033[1m"
ASCII_NORMAL="\033[0m"

# Sphinx Configuration Template
CONF_IN_PATH="template.conf"
CONF_OUT_PATH="sphinx.conf"

clear

echo -e "${ASCII_BOLD}CATS Automated Sphinx Installer Setup${ASCII_NORMAL}"
echo
echo "Sphinx is an open source solution to considerably speed up text "
echo "searches in CATS. This setup will complete the following: "
echo
echo "1) Install and Setup Sphinx (if it's not already)"
echo "2) Configure Sphinx to work with CATS"
echo "3) Configure CATS to use Sphinx for its searches"
echo
echo "This script can autodetect most of what it needs to know. It will "
echo "present you with a suggested value, you may type a new value or "
echo "press ENTER to accept."
echo
echo "Further documentation can by found by reading INSTALL or browsing to "
echo "our forums @ www.catsone.com/forum"
echo

checkContinue()
{
    echo -en "Press ${ASCII_BOLD}ENTER${ASCII_NORMAL} to continue or ${ASCII_BOLD}Q${ASCII_NORMAL} to quit... "
    read -s -n1 yn
    echo
    if [ "$yn" = "q" ]
    then
        exit 0
    fi
    if [ "$yn" = "Q" ]
    then
        exit 0
    fi
    echo
}


checkContinue

# Check if this is a windows machine
CUR_DIR=`pwd`
if [ -d "/cygdrive" ]
then
    WINDOWS_OS=1
else
    WINDOWS_OS=0
fi
UNIX_OS_NAME=`cat "/etc/issue" | head -n 1 | sed -e "s/ .*$//"`
SPHINX_NEW_INSTALL=0


echo -e "[${ASCII_BOLD}Beginning Installation Wizard${ASCII_NORMAL} on ${UNIX_OS_NAME}]"
echo

echo "Searching for where CATS is installed... "
cd ..
AUTO_CATS_PATH="`pwd`/cats"
cd "$CUR_DIR"
if [ -d "$AUTO_CATS_PATH" ]
then
    CATS_PATH="$AUTO_CATS_PATH"
elif [ -d "/var/www/cats" ]
then
    CATS_PATH="/var/www/cats"
else
    AUTO_CATS_PATH=`locate -r "cats\/index\.php" | tail -n 1`
    if [ -e "$AUTO_CATS_PATH" ]
    then
        CATS_PATH="${AUTO_CATS_PATH:0:(${#AUTO_CATS_PATH}-10)}"
    fi
fi

echo -en "CATS path [${ASCII_BOLD}${CATS_PATH}${ASCII_NORMAL}]: "
read cats_path
if [ -n "$cats_path" ]
then
    CATS_PATH="$cats_path"
fi
if [ ! -d "${CATS_PATH}" ]
then
    echo
    echo "No CATS installation found at ${CATS_PATH}!"
    echo "Please install CATS and try again."
    exit 0
fi
echo


echo "Checking if Sphinx is installed... "
SPHINX_PATH="${CATS_PATH}/sphinx"
SPHINX_INSTALLED=0
if [ -d "$SPHINX_PATH" ]
then
    echo -e "Sphinx installed at \"${SPHINX_PATH}\"... [${ASCII_BOLD}Ok${ASCII_NORMAL}]"
    SPHINX_INSTALLED=1
    echo
else
    AUTO_SPHINX_PATH=`locate 'sphinx/etc' | head -n 1`

    if [ "${#AUTO_SPHINX_PATH}" -gt 5 ]
    then
        SPHINX_PATH="${AUTO_SPHINX_PATH:0:(${#AUTO_SPHINX_PATH}-4)}"
    else
        NO_SPHINX_INSTALLED=1

        if [ -d "/usr/local/sphinx" ]
        then
            AUTO_SPHINX_PATH="/usr/local/sphinx"
            NO_SPHINX_INSTALLED=0
        elif [ -d "${CATS_PATH}/sphinx" ]
        then
            AUTO_SPHINX_PATH="${CATS_PATH}/sphinx"
            NO_SPHINX_INSTALLED=0
        fi

        if [ $NO_SPHINX_INSTALLED -eq 1 ]
        then
            SPHINX_PATH="install"
            echo
            echo -e "${ASCII_BOLD}Sphinx has not been found on your system.${ASCII_NORMAL}"
            echo "* If you have Sphinx installed, enter the path (i.e.: /usr/local/sphinx)"
            echo "* To install Sphinx, press ENTER"
        else
            SPHINX_PATH="$AUTO_SPHINX_PATH"
        fi
    fi
    echo
fi

if [ "$SPHINX_INSTALLED" -ne 1 ]
then
    echo -en "Sphinx directory [${ASCII_BOLD}${SPHINX_PATH}${ASCII_NORMAL}]: "
    read sphinx_path
    if [ -n "$sphinx_path" ]
    then
        SPHINX_PATH="$sphinx_path"
    fi
    echo
fi

if [ ! -d "$SPHINX_PATH" ]
then
    if [ "${UNIX_OS_NAME}" == "Ubuntu" ]
    then
        echo
        echo "It appears that you are using the Ubuntu Operating System."
        echo "If you installed an out-of-the-box LAMP system for Ubuntu "
        echo "you will need some additional libraries to install Sphinx."
        echo
        echo "This installation wizard will attempt to install those libaries "
        echo "for you now (NOTE: you may need to type your root password)"
        echo
        sudo apt-get install build-essential libmysqlclient-dev || echo "Installation of these libraries failed! Continuing anyway (cross your fingers!)..." && echo "Ubuntu libraries have been installed successfully."
        echo
    fi


    echo -e "[${ASCII_BOLD}Install Sphinx${ASCII_NORMAL}]"
    echo
    echo "Sphinx is not currently on your system and will now be installed."
    echo
    checkContinue

    SPHINX_PATH="${CATS_PATH}/sphinx"
    SPHINX_NEW_INSTALL=1

    if [ "$WINDOWS_OS" -eq 1 ]
    then
        echo -en "Installing Sphinx to ${SPHINX_PATH}... "
        cp -R sphinx_win "${CATS_PATH}" || $success=0
        mv "${CATS_PATH}/sphinx_win" "${SPHINX_PATH}" || $success=0
        rm -Rf "${SPHINX_PATH}/.svn"
        rm -Rf "${SPHINX_PATH}/bin/.svn"
        rm -Rf "${SPHINX_PATH}/etc/.svn"
        rm -Rf "${SPHINX_PATH}/var/.svn"
        rm -Rf "${SPHINX_PATH}/var/log/.svn"
        rm -Rf "${SPHINX_PATH}/var/data/.svn"
        if [ "$success" -eq 0 ]
        then
            echo "This program is unable to install Sphinx. Please see above error."
            exit 0
        fi
        echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
        echo
    else
        SPHINX_TARBALL=`find . -name "*.tar.gz" -print | head -n 1 | sed -e "s/^\.\///"`
        while [ ! -e "$SPHINX_TARBALL" ]
        do
            echo "This installer cannot find a current copy of Sphinx to install. Please "
            echo "download the latest copy from http://www.sphinxsearch.com/downloads.html "
            echo "and save it to this directory to continue. This installer will handle "
            echo "the unpacking/installation for you."
            echo
            echo "Alternatively, you can specify the path of a Sphinx installation package. "
            echo "The package should be in a *.tar.gz format."
            echo
            echo "Enter the path to a Sphinx package, press ENTER to search the current "
            echo "directory or press CTRL-C to cancel this installation."
            echo
            echo -en "Sphinx Package Location [${ASCII_BOLD}search${ASCII_NORMAL}]: "
            read sphinx_tarball
            if [ -e "$sphinx_tarball" ]
            then
                SPHINX_TARBALL="$sphinx_tarball"
            else
                SPHINX_TARBALL=`find . -name "*.tar.gz" -print | head -n 1 | sed -e "s/^\.\///"`
            fi
            echo
        done

        if [ ! -e "$SPHINX_TARBALL" ]
        then
            echo "Cannot find a copy of Sphinx to install."
            echo "Please download the latest version of Sphinx to this folder and run "
            echo "this installation wizard again."
            echo
            exit 0
        fi

        echo "Found a copy of Sphinx \"${SPHINX_TARBALL}\""

        echo -n "Extracting the contents of ${SPHINX_TARBALL}... "
        tar -zxvf "$SPHINX_TARBALL"
        SPHINX_DIR=`tar -zxvf "$SPHINX_TARBALL" | head -n 1`
        if [ ! -d "${SPHINX_DIR}" ]
        then
            echo -e "[${ASCII_BOLD}Failed${ASCII_NORMAL}]"
            echo "The extraction of Sphinx has failed. This could be due to file permissions."
            echo "You can try to install Sphinx yourself."
            echo "Try:"
            echo "tar -zxvf ${SPHINX_TARBALL}"
            echo "cd sphinx*"
            echo "./configure"
            echo "make"
            echo "make install"
            echo
            echo "After Sphinx is installed, please run this installer again."
            exit 0
        else
            echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
        fi

        cd "${SPHINX_DIR}"

        echo -n "Running the Sphinx configuration script (this could take a few minutes)... "
        echo
        ./configure --prefix="${CATS_PATH}/sphinx"

        echo "Building and Installing Sphinx (this could take a few minutes)... "
        make
        make install
        echo
        echo
        echo

        if [ ! -d "${CATS_PATH}/sphinx" ]
        then
            echo "The installation of Sphinx has failed. This could be due to file permissions."
            echo "You can try to install Sphinx yourself."
            echo "Try:"
            echo "tar -zxvf ${SPHINX_TARBALL}"
            echo "cd sphinx*"
            echo "./configure"
            echo "make"
            echo "make install"
            echo
            echo "After Sphinx is installed, please run this installer again."
            exit 0
        fi

        echo -e "${ASCII_BOLD}Sphinx Installed Successfully!${ASCII_NORMAL}"
        echo
        echo "Sphinx is now installed in ${CATS_PATH}/sphinx"
        echo
        cd "$CUR_DIR"
    fi
fi


echo -n "Attempting to retrieve MySQL database settings from \"${CATS_PATH}/config.php\"... "
DATABASE_USER=`sed -n "/define('DATABASE_USER', '.*');/p" "${CATS_PATH}/config.php" | sed -e "s/define('DATABASE_USER', '//" | sed -e "s/'.*$//"`
DATABASE_PASS=`sed -n "/define('DATABASE_PASS', '.*');/p" "${CATS_PATH}/config.php" | sed -e "s/define('DATABASE_PASS', '//" | sed -e "s/'.*$//"`
DATABASE_HOST=`sed -n "/define('DATABASE_HOST', '.*');/p" "${CATS_PATH}/config.php" | sed -e "s/define('DATABASE_HOST', '//" | sed -e "s/'.*$//"`
DATABASE_NAME=`sed -n "/define('DATABASE_NAME', '.*');/p" "${CATS_PATH}/config.php" | sed -e "s/define('DATABASE_NAME', '//" | sed -e "s/'.*$//"`
echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
echo


echo -en "MySQL Host Name     [${ASCII_BOLD}${DATABASE_HOST}${ASCII_NORMAL}]: "
read database_host
if [ -n "$database_host" ]
then
    DATABASE_HOST="$database_host"
fi


echo -en "MySQL Port          [${ASCII_BOLD}${DATABASE_PORT}${ASCII_NORMAL}]: "
read database_port
if [ -n "$database_port" ]
then
    DATABASE_PORT="$database_port"
fi


echo -en "MySQL Username      [${ASCII_BOLD}${DATABASE_USER}${ASCII_NORMAL}]: "
read database_user
if [ -n "$database_user" ]
then
    DATABASE_USER="$database_user"
fi


echo -en "MySQL Password      [${ASCII_BOLD}${DATABASE_PASS}${ASCII_NORMAL}]: "
read database_pass
if [ -n "$database_pass" ]
then
    DATABASE_PASS="$database_pass"
fi


echo -en "MySQL Database Name [${ASCII_BOLD}${DATABASE_NAME}${ASCII_NORMAL}]: "
read database_name
if [ -n "$database_name" ]
then
    DATABASE_NAME="$database_name"
fi

clear

echo -e "Summary of ${ASCII_BOLD}${CONF_OUT_PATH}${ASCII_NORMAL} Settings:"
echo
echo -e "[${ASCII_BOLD}MySQL Settings${ASCII_NORMAL}]"
echo "Username: $DATABASE_USER"
echo "Password: $DATABASE_PASS"
echo "Database: $DATABASE_NAME"
echo -e "Host: ${DATABASE_HOST}:${DATABASE_PORT}"
echo
echo -e "[${ASCII_BOLD}Sphinx${ASCII_NORMAL}]"
echo "Path to Installation: $SPHINX_PATH"
echo
echo -e "[${ASCII_BOLD}CATS${ASCII_NORMAL}]"
echo "Path to Installation: $CATS_PATH"

echo
echo

checkContinue
clear

if [ -e "$CONF_OUT_PATH" ]
then
    rm -f $CONF_OUT_PATH
fi

echo "Building new \"${CONF_OUT_PATH}\"..."
cp $CONF_IN_PATH $CONF_OUT_PATH
sed -i "s/\%DATABASE_USER\%/${DATABASE_USER}/" "$CONF_OUT_PATH"
sed -i "s/\%DATABASE_PASS\%/${DATABASE_PASS}/" "$CONF_OUT_PATH"
sed -i "s/\%DATABASE_HOST\%/${DATABASE_HOST}/" "$CONF_OUT_PATH"
sed -i "s/\%DATABASE_NAME\%/${DATABASE_NAME}/" "$CONF_OUT_PATH"
sed -i "s/\%DATABASE_PORT\%/${DATABASE_PORT}/" "$CONF_OUT_PATH"
sed -i "s/\%CATS_PATH\%/${CATS_PATH//\//\/}/" "$CONF_OUT_PATH"


if [ "${#SPHINX_PATH}" -gt 5 ]
then
    echo
    echo -n "Copying configuration file into Sphinx... "
    if [ -e "${SPHINX_PATH}/etc/${CONF_OUT_PATH}" ]
    then
        mv "${SPHINX_PATH}/etc/${CONF_OUT_PATH}" "${SPHINX_PATH}/etc/${CONF_OUT_PATH}.old"
    fi
    mv $CONF_OUT_PATH "${SPHINX_PATH}/etc/${CONF_OUT_PATH}" && success=1 || sucess=0

    if [ "$success" -eq 1 ]
    then
        echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
    else
        echo -e "[${ASCII_BOLD}FAILED${ASCII_NORMAL}]"
        echo "You may not have permission to create or replace ${SPHINX_PATH}/etc/${CONF_OUT_PATH}"
        echo "You may need to change the file permissions (perhaps \"chmod a+rw ${SPHINX_PATH}/etc\") as yourself or root."
    fi
fi

echo -n "Installing the sphinx module into CATS... "
if [ -d "${CATS_PATH}/lib/sphinx" ]
then
    echo "Skipping (module already installed)"
else
    cp -R sphinx "${CATS_PATH}/lib" && success=1 || success=0
    if [ "$success" -eq 1 ]
    then
        echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
    else
        echo -e "[${ASCII_BOLD}Failed${ASCII_NORMAL}]"
        echo "You may not have permission to copy the module into the ${CATS_PATH}/lib"
        echo "You may need to change the directory permissions (perhaps \"chmod a+rw ${CATS_PATH}/lib\") as yourself or root."
    fi
fi

echo -n "Setting up ${CATS_PATH}/config.php to enable sphinx... "
if [ -w "${CATS_PATH}/config.php" ]
then
    sed -i "s/'ENABLE_SPHINX', false/'ENABLE_SPHINX', true/" "${CATS_PATH}/config.php"
    echo -e "[${ASCII_BOLD}Success${ASCII_NORMAL}]"
else
    echo -e "[${ASCII_BOLD}Failed${ASCII_NORMAL}]"
    echo "You may not have permission to write to ${CATS_PATH}/config.php"
    echo "You may need to change the file permissions (perhaps \"chmod a+w ${CATS_PATH}/config.php\") as yourself or root."
fi

echo

pushd .
cd "${SPHINX_PATH}/etc"

SPHINX_SEARCHD_BINARY=`find "${SPHINX_PATH}/bin" -name "searchd*" | head -n 1 | sed -e "s/${SPHINX_PATH//\//\/}\/bin\///"`
SPHINX_INDEXER_BINARY=`find "${SPHINX_PATH}/bin" -name "indexer*" | head -n 1 | sed -e "s/${SPHINX_PATH//\//\/}\/bin\///"`


if [ -e "../bin/${SPHINX_SEARCHD_BINARY}" ]
then
    if [ "$WINDOWS_OS" -eq 0 ]
    then
        SPHINX_SEARCHD_PID=`ps -A | grep "$SPHINX_SEARCHD_BINARY" | sed -e "s/ pts.*${SPHINX_SEARCHD_BINARY}//"`
        if [ "$SPHINX_SEARCHD_PID" != '' ]
        then
            echo
            echo "Sphinx searchd daemon process appears to be already running, attempting to restart... "
            kill "$SPHINX_SEARCHD_PID" && success=1 || success=0
            if [ "$success" -eq 1 ]
            then
                echo "Successfully stopped the searchd daemon."
            else
                echo "Failed to stop the searchd daemon. You will need to restart it manually."
            fi
            echo
        fi
    fi
fi

if [ -e "../bin/${SPHINX_INDEXER_BINARY}" ]
then
    echo "Building the Sphinx tables (this could take a few minutes)... "
    ../bin/"${SPHINX_INDEXER_BINARY}" --all
    echo
fi

if [ -e "../bin/${SPHINX_SEARCHD_BINARY}" ]
then
    echo "Starting the Sphinx searchd daemon process... "
    ../bin/"${SPHINX_SEARCHD_BINARY}" && success=1 || success=0
    if [ "$success" -eq 0 ]
    then
        echo "The Sphinx searchd daemon is already running or an error has occured."
        echo
    fi
fi

popd
if [ "$SPHINX_NEW_INSTALL" -eq 1 ]
then
    echo
    echo "*************************************************"
    echo
    echo
    if [ "$WINDOWS_OS" -eq 1 ]
    then
        WINDOWS_PATH="${SPHINX_PATH//\//\\\\}\\\\bin\\\\${SPHINX_SEARCHD_BINARY}"
        WINDOWS_PATH="${WINDOWS_PATH:13:(${#WINDOWS_PATH}-13)}"
        WINDOWS_PATH="c:\\${WINDOWS_PATH}"

        cp template.com install_service.com
        sed -i "s/\%PATH\%/${WINDOWS_PATH}/" "install_service.com"
        mv install_service.com "${SPHINX_PATH}/bin"

        echo "This installer has determined that you are running a Microsoft Windows "
        echo "operating system. Sphinx will need to be installed as a windows service "
        echo "in order for CATS to use it."
        echo
        echo "This installer has created an install file at:"
        echo "    \"${SPHINX_PATH}/bin/install_service.com\" "
        echo
        echo "Running this file will install the Windows service for you. You can either "
        echo "browse to the folder and run the file (in windows!) or click "
        echo "\"Start Menu -> Run\" and enter the above path."
        echo
        echo "Not installing Sphinx as a windows service will require to you run "
        echo "\"${SPHINX_SEARCHD_BINARY}\" everytime you restart your computer."
        echo
        echo "IMPORTANT NOTE:"
        echo "As of Sphinx 0.9.7 Microsoft Windows Sphinx services are only capable of "
        echo "one request at a time. If you are running a multi-user environment "
        echo "for CATS this may cause issues. If this is the case, you should consider "
        echo "hosting CATS with us at catsone.com, on a VPN, or on a UNIX-based operating "
        echo "system."
    else
        cp "${SPHINX_DIR}/contrib/scripts/searchd" ./
        sed -i "s/SUDO_USER=searchd/SUDO_USER=${USER}/" "./searchd"
        sed -i "s/BASE_PATH=\/release\/search/BASE_PATH=${SPHINX_PATH//\//\/}\/bin\/${SPHINX_SEARCHD_BINARY}/" "./searchd"
        echo "The Sphinx search daemon has been installed and started at "
        echo "    \"${SPHINX_PATH}/bin/${SPHINX_SEARCHD_BINARY}\""
        echo

        if [ -d "/etc/rc.d/init.d" ]
        then
            echo
            echo "It appears that you have an init.d compatible system. The installer "
            echo "will attempt to install Sphinx as a startup service. You may be ."
            echo "prompted for the root password."
            echo
            sudo cp "searchd" "/etc/rc.d/init.d/searchd" && success=1 || success=0
            echo
        fi

        if [ "$success" -eq 1 ]
        then
            sudo chkconfig --add searchd && echo "Sphinx has been installed as a startup service!" || echo "Failed to add Sphinx as a startup service. Please see INSTALL."
        else
            echo "This script was unable to automatically install this script for you. "
            echo "You can try these steps if you have an init.d compatible system, "
            echo "otherwise please consult INSTALL."
            echo
            echo "1)  Login as root"
            echo
            echo "    su"
            echo
            echo "2)  Copy the startup script to your init.d scripts directory"
            echo
            echo "    cp searchd /etc/rc.d/init.d"
            echo
            echo "3)  Add searchd as a startup service"
            echo
            echo "    chkconfig --add searchd"
            echo
            echo "Not adding searchd as a startup service will require you to run Sphinx "
            echo "using the following command:"
            echo "    \"${SPHINX_PATH}/bin/${SPHINX_SEARCHD_BINARY}\""
            echo "prior to using CATS everytime your computer is restarted."
            echo
        fi
    fi
fi

echo -e "${ASCII_BOLD}Installation of Sphinx with CATS is now complete!${ASCII_NORMAL}"
echo
exit 0
