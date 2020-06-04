
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

detect_os() {
    if [ ! -e /etc/os-release ]; then
        echo "Unable to determine OS" >&2
        exit 1
    fi

    __os_name=$(source /etc/os-release; echo "${NAME}")
    __os_id=$(source /etc/os-release; echo "${ID}")
    __os_version_id=$(source /etc/os-release; echo "${VERSION_ID}")
}

os_name() {
    echo ${__os_name}
}

os_id() {
    echo ${__os_id}
}

os_version_id() {
    echo ${__os_version_id}
}
