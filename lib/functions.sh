# Useful functions that can be reused throughout the server bootstraps

# Global variables for including scripts to use as well as internal use
sb_text_black="[30m"
sb_text_blue="[34m"
sb_text_cyan="[36m"
sb_text_grey="[30;1m"
sb_text_green="[32m"
sb_text_magenta="[35m"
sb_text_red="[31m"
sb_text_white="[37m"
sb_text_normal="[0m"

# Log Levels available for the library
SB_DEBUG=10
SB_VERBOSE=20
SB_INFO=30
SB_WARNING=40
SB_ERROR=50
SB_CRITICAL=60

# Default log level is INFO
sb_log_level=${SB_INFO}


# Function: log
# Parameters: 1. Message
#             2. (Optional) Log Level
#              
# Writes log output (colour as necessary, TODO: depending on the terminal and options)
#
log() {
    # Work out the level of this log - a missing level definition results in
    # an INFO message by default
    local level=${SB_INFO}
    if [ $# -gt 1 ]; then
        level=$2
    fi

    # If the level of the log message is less than the current log level we
    # can quickly ignore it
    if [ ${level} -lt ${sb_log_level} ]; then
        return
    fi

    if [ ${level} -eq ${SB_CRITICAL} ]; then
        echo "${sb_text_red}CRITICAL: ${1}${sb_text_normal}"
    elif [ ${level} -eq ${SB_ERROR} ]; then
        echo "${sb_text_red}ERROR:    ${1}${sb_text_normal}"
    elif [ ${level} -eq ${SB_WARNING} ]; then
        echo "${sb_text_cyan}WARNING:  ${1}${sb_text_normal}"
    elif [ ${level} -eq ${SB_INFO} ]; then
        echo "INFO:     ${1}"
    elif [ ${level} -eq ${SB_VERBOSE} ]; then
        echo "VERBOSE:  ${1}"
    elif [ ${level} -eq ${SB_DEBUG} ]; then
        echo "DEBUG:    ${1}"
    else
        echo "UNKNOWN!${2}: ${1}"
    fi
}


# function: logc
# Params:   1. Message
#
# Logs a critical message
logc() {
    log "${1}" ${SB_CRITICAL}
}


# function: loge
# Params:   1. Message
#
# Logs an error message
loge() {
    log "${1}" ${SB_ERROR}
}


# function: logw
# Params:   1. Message
#
# Logs a warning message
logw() {
    log "${1}" ${SB_WARNING}
}


# function: logi
# Params:   1. Message
#
# Logs an info message
logi() {
    log "${1}" ${SB_INFO}
}


# function: logv
# Params:   1. Message
#
# Logs a verbose message
logv() {
    log "${1}" ${SB_VERBOSE}
}


# function: logd
# Params:   1. Message
#
# Logs a debug message
logd() {
    log "${1}" ${SB_DEBUG}
}



# Function: must_be_root_or_exit
#
# Checks that the executing user is root, otherwise exits the script
must_be_root_or_exit() {
    if [ "$(id -u)X" != "0X" ]; then
        error_exit "This script must be run by root (uid=0)"
    fi
}

# Function: must_succeed_or_exit
#
# Executes all parameters as a command and checks the exit code for success.
# If the command fails to return a success exit code then the function
# reports the error and exits the script
#
must_succeed_or_exit() {
    local _ec

    # Run the full command given
    # NOTE: Any wildcard in the command will fail to be expanded properly
    $@

    # Grab the exit code of the command that we run
    _ec=$?
    
    # If the result was not success, exit the script with the same error code
    if [ ${_ec} -ne 0 ]; then
        error_exit "$@ failed with exit code ${_ec}" ${_ec}
    fi
}


# Function: option
# Returns:  Exit code 0 (true/success) or 1 (false) depending on the option setting
# Example:  if option ${use_proxy}; then
#               export https_proxy=${proxy}  
#           fi
#
# Provides an easier interface to test when testing for boolean options.
# Runs in a subshell and exits with code 0 (success) if the option is NOT
# set to 0, otherwise exits with code 1 to indicate false.
#
option() (
    # If there were no arguments passed, or the argument passed was an empty
    # value, exit false
    if [ $# -lt 1 ] || [ "${1}X" = "X" ]; then
        exit 1
    fi

    # Otherwise assume the following settings as false, everything else as true
    if [ "${1}X" = "0X" ] || [ "${1}X" = "falseX" ]; then
        exit 1
    else
        exit 0
    fi
)


# Function detect_operating_system
#
# Detect which operating system we're running on which can set various global
# variables for the scripts to use
#
detect_operating_system() {
    sb_operating_system_detected=0

    _probe_fedora

    if [ ${sb_operating_system_detected} -eq 1 ]; then
        return
    fi

    sb_operating_system=unknown
    sb_operating_system_release=unknown
    error_exit "Cannot determine operating system type"
}


# Function error_exit
# Parameters: 1. The error message
#             2. (Optional) The code to exit the script with
#
# Print an error on stderr in Red and then exit with an optional error code.
# If no code is set, 1 is used
#
error_exit() {
    local error_code=1

    if [ $# -gt 1 ]; then
        error_code=$2
    fi

    loge "$1"
    exit ${error_code}
}


# Function:  _probe_fedora
# Returns: sb_operating_system
#          sb_operating_system_release
#          sb_package_manager
#          sb_exe_yum
#          sb_exe_dnf
#
# Probe the operating system to see if it is a Fedora release
_probe_fedora() {
    if ! operating_system_is_fedora ; then
        return
    fi

    # This is Fedora, so start setting up the global namespace
    sb_operating_system_detected=1
    sb_operating_system=fedora
    sb_operating_system_release=$(fedora_release)
    sb_package_manager=yum
    sb_exe_yum=$(which yum)
    sb_exe_dnf=$(which dnf)
}

# Function: operating_system_is_fedora (Subshell)
# Returns: 0 exit code when system is fedora, and 1 otherwise
# Usage: if operating_system_is_fedora; then
#            do_fedora_specific_stuff
#        fi
#
operating_system_is_fedora() (
    if [ -f /etc/system-release ] && [ "$(cat /etc/system-release | grep -i fedora)X" != X ]; then
        exit 0        
    fi

    exit 1
)

# Function: fedora_release
# Returns: stdout: The release number of this fedora install
fedora_release() {
    cat /etc/system-release-cpe | cut -d: -f5
}

detect_operating_system
