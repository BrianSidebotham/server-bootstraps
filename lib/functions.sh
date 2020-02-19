# Useful functions that can be reused throughout the server bootstraps

# Function: must_be_root_or_exit
#
# Checks that the executing user is root, otherwise exits the script
must_be_root_or_exit() {
    if [ "$(id -u)X" != "0X" ]; then
        echo "This script must be run by root (uid=0)" >&2
        exit 1
    fi
}

# Function: must_succeed_or_exit
#
# Executes all parameters as a command and checks the exit code for success.
# If the command fails to return a success exit code then the function
# reports the error and exits the script
#
must_succeed_or_exit() {
    local _result

    # Run the full command given
    # NOTE: Any wildcard in the command will fail to be expanded properly
    $@

    # Grab the exit code of the command that we run
    _result=$?
    
    # If the result was not success, exit the script with the same error code
    if [ ${_result} -ne 0 ]; then
        echo "$@ failed with exit code ${_result}" >&2
        exit ${_result}
    fi
}