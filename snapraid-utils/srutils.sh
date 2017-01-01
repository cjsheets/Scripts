#!/bin/bash

#|
#| Script Information
#|

AUTHOR="Chad Sheets <chad@cjsheets.com>"
GIT="https://github.com/cjsheets/snapraid-utils"
URL="http://cjsheets.com/snapraid-utils"
VERSION="0.1"
LICENSE="MIT"


#* ---------------------------------------|
#*|  D E F A U L T    V A R I A B L E S
#*

# Thesse variabless are ignored if $CONF_FILE exists
CONF_FILE='/etc/snapraid_utils.conf'
LOG_FILE='/tmp/snapraid.log'
SNAPRAID="$( which snapraid )"
TEMP_DIR='/tmp'


#* ---------------------------------------|
#*|  M A I N    F U N C T I O N S
#*

snapraid_diff() {
  WORK_FILE="$( create_temp_file )"
  output "debug" "Initialized temporary file: $WORK_FILE"
  output "info" "Running: snapraid diff"
  _catch_error "$( $SNAPRAID diff >> $WORK_FILE)" "${?}" "$LINENO"
  NUM_EQUAL=$(grep "^ *[0-9]* equal" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_ADDED=$(grep "^ *[0-9]* added" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_REMOVE=$(grep "^ *[0-9]* removed" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_UPDATE=$(grep "^ *[0-9]* updated" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_MOVED=$(grep "^ *[0-9]* moved" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_COPIED=$(grep "^ *[0-9]* copied" | sed 's/^ *//g' | cut -d ' ' -f1)
  NUM_RESTORE=$(grep "^ *[0-9]* restored" | sed 's/^ *//g' | cut -d ' ' -f1)
  output "info" "Completed: $NUM_EQUAL equal, $NUM_ADDED added, $NUM_REMOVE removed"
  output "info" "  $NUM_UPDATE updated, $NUM_MOVED moved, $NUM_COPIED copied, $NUM_RESTORE restored"
  CLEANUP="${CLEANUP} ${WORK_FILE}"
  output "trace" "Tracing temporary file ${CLEANUP} in case of unclean exit"
}

snapraid_sync() {
  WORK_FILE="$( create_temp_file )"
  output "debug" "Initialized temporary file: $WORK_FILE"
  output "info" "Running: snapraid sync"
  _catch_error "$( $SNAPRAID sync >> $WORK_FILE)" "${?}" "$LINENO"

  output "info" "Completed:"
  #CLEANUP="${CLEANUP} ${WORK_FILE}"
  output "trace" "Tracing temporary file ${CLEANUP} in case of unclean exit"
}

snapraid_scrub() {
  WORK_FILE="$( create_temp_file )"
  output "debug" "Initialized temporary file: $WORK_FILE"
  output "info" "Running: snapraid scrub"
  _catch_error "$( $SNAPRAID scrub >> $WORK_FILE)" "${?}" "$LINENO"

  output "info" "Completed:"
  #CLEANUP="${CLEANUP} ${WORK_FILE}"
  output "trace" "Tracing temporary file ${CLEANUP} in case of unclean exit"
}

snapraid_smart() {
  WORK_FILE="$( create_temp_file )"
  output "debug" "Initialized temporary file: $WORK_FILE"
  output "info" "Running: snapraid smart"
  _catch_error "$( $SNAPRAID smart >> $WORK_FILE)" "${?}" "$LINENO"

  output "info" "Completed:"
  #CLEANUP="${CLEANUP} ${WORK_FILE}"
  output "trace" "Tracing temporary file ${CLEANUP} in case of unclean exit"
}

create_temp_file() {
  local TMP_FILE=""
  if ! TMP_FILE="$( mk_temp "${TEMP_DIR}/send-archives" "0600" 2>/dev/null)"; then
    _throw_error 0 "Unable to create temporary file in ${TEMP_DIR}"
  fi
  echo "${TMP_FILE}"
  return 0
}


#* ---------------------------------------|
#*|  S U P P O R T    F U N C T I O N S
#*

chmod_to_umask() {
  _chmod="${1}"
  _len="$(echo "${_chmod}" | awk '{print length()}')"
  if [ "${_len}" = "3" ]; then
    r=$(echo "${_chmod}" | awk '{print substr($0,1,1)}')
    w=$(echo "${_chmod}" | awk '{print substr($0,2,1)}')
    x=$(echo "${_chmod}" | awk '{print substr($0,3,1)}')
  elif  [ "${_len}" = "4" ]; then
    r=$(echo "${_chmod}" | awk '{print substr($0,2,1)}')
    w=$(echo "${_chmod}" | awk '{print substr($0,3,1)}')
    x=$(echo "${_chmod}" | awk '{print substr($0,4,1)}')
  fi
  ur="$(sub "7" "${r}")"
  uw="$(sub "7" "${w}")"
  ux="$(sub "7" "${x}")"
  echo "${ur}${uw}${ux}"
}

mk_temp() {
  _path="${1}_XXXXXXXXXXXXX"
  _chmod="${2}"
  umask "$(chmod_to_umask ${_chmod})";
  if ! _file="$( $(which mktemp) "${_path}" 2>/dev/null )"; then
    return $?
  else
    echo "${_file}"
  fi; return 0
}

timestamp() {
  echo $(date '+%Y-%m-%d %H:%M:%S')
  return 0
}

# Basic Math Functions
div() {     # Division
  echo | awk -v "a=${1}" -v "b=${2}" '{print a / b}'
}; isint(){ # Test if integer
  printf "%d" "${1}" >/dev/null 2>&1 && return 0 || return 1;
}; sum() { # Addition
  echo | awk -v "a=${1}" -v "b=${2}" '{print a + b}'
}; sub() { # Subtraction
  echo | awk -v "a=${1}" -v "b=${2}" '{print a - b}'
}


#* ---------------------------------------|
#*|  L O G G I N G   /   O U T P U T
#*

logging() {
  local _log_level="${1}"
  if [ ! -f "${LOG_FILE}" ]; then
    if [ ! -d "$(dirname "${LOG_FILE}")" ]; then
      if ! mkdir -p "$(dirname "${LOG_FILE}")" > /dev/null 2>&1 ; then
        output "warn" "Log directory does not exist $(dirname "${LOG_FILE}"). Logging is disabled."; return 0
    fi; fi; if [ "${_log_level}" != "0" ]; then
      if ! touch "${LOG_FILE}" > /dev/null 2>&1 ; then
        output "warn" "Log file does not exist: "${LOG_FILE}". Logging is disabled."; return 0
  fi; fi; fi; if [ "${_log_level}" != "0" ]; then
    if [ ! -w "${LOG_FILE}" ]; then
      output "warn" "Cannot write to the log: "${LOG_FILE}". Check permissions. Logging is disabled."; return 0
  fi; fi; if [ "${_log_level}" != "0" ]; then
    output "info" "Logging to: "${LOG_FILE}""
    echo "#* - - - - - - - - - - - - - - - - - - - - - - - -" >> ${LOG_FILE}
    echo "#* [ $(timestamp) ] Starting send-archives" >> ${LOG_FILE}
    echo "#*" >> ${LOG_FILE}
    [ -z "${_log_level}" ] && return 1 || return "${_log_level}"
  else
    output "info" "Logging is disabled: "${LOG_FILE}". See debugging messages for details (-v)."; echo "0";
  fi; return 0
}

output() {
  _lvl="${1}" # Message level - (str) trace, debug, info, note, warn, err or fatal
  _msg="${2}"   # Message: (str)
  _verb="${3}"  # Verbosity level - 0:fatal,err,warn, 1:normal, 2:debug, 3:trace
  _log="${4}"   # Logging level - 0:off, 1:normal, 2:debug, 3:trace
  _file="${5}"  # Logfile

  # Use defaults if options not set
  [ -z "${_verb}" ] && _verb="${OUT_V}"
  [ -z "${_log}" ] && _log="${LOG_V}"
  [ -z "${_file}" ] && _file="${LOG_FILE}"

  # Recover prefix if exists - example: 'err|(RUN)'
  _pre="$( echo "${_lvl}" | awk -F '|' '{print $2}' )"
  _lvl="$( echo "${_lvl}" | awk -F '|' '{print $1}' )"

  # Validate Inputs
  [ "${#}" != "2" ] && _throw_error 0 "Insufficient Message Parameters: \$# ${#}"
  case "${_lvl}" in
    trace|debug|info|note|ok|err|warn|fatal) ;;
    *) _throw_error 0 "Invalid Message Severity Level: \$_lvl=${_lvl}" ;; esac

  case "${_verb}" in
    0|1|2|3) ;;
    *) _throw_error 0 "Invalid Message Verbosity Level: \$_verb=${_verb}" ;; esac

  case "${_log}" in
    0|1|2|3) ;;
    *) _throw_error 0 "Invalid Message Log Level: \$_log=${_log}" ;; esac

  # Add Message Prefix
  _pre_lvl="$( _output_severity "${_lvl}" )"
  _pre_color="$( _output_color "${_lvl}" )"
  _rst_color="\033[m" # Reset tty color
  _pre_date="$(timestamp)"

  # Trim Message
  _msg="$( echo "${_msg}" | sed '/^[:space:]*$/d' )"

  # Output Message to stdout / stderr
  case "${_lvl}" in
    fatal|err|warn) _out "stderr" \
    "${_pre_color}${_pre_lvl} ${_pre}" "${_msg}" "${_rst_color}";; esac

  case "${_lvl}" in
    info|note|ok) [ "${_verb}" = "1" ] && _out "stdout" \
    "${_pre_color}${_pre_lvl} ${_pre}" "${_msg}" "${_rst_color}"; ;; esac

  case "${_lvl}" in
    debug|info|note|ok) [ "${_verb}" = "2" ] && _out "stdout" \
    "${_pre_color}${_pre_lvl} ${_pre}" "${_msg}" "${_rst_color}"; ;; esac

  case "${_lvl}" in
    trace|debug|info|note|ok) [ "${_verb}" = "3" ] && _out "stdout" \
    "${_pre_color}${_pre_lvl} ${_pre}" "${_msg}" "${_rst_color}"; ;; esac

  # Output Message to log file
  case "${_lvl}" in
    info|note|ok|warn|err|fatal) [ "${_log}" = "1" ] && _out \
    "${_file}" "${_pre_date} ${_pre_lvl} ${_pre}" "${_msg}" ""; ;; esac

  case "${_lvl}" in
    debug|info|note|ok|warn|err|fatal) [ "${_log}" = "2" ] && _out \
    "${_file}" "${_pre_date} ${_pre_lvl} ${_pre}" "${_msg}" ""; ;; esac

  [ "${_log}" = "3" ] && _out \
    "${_file}" "${_pre_date} ${_pre_lvl} ${_pre}" "${_msg}" ""

  return 0
}

_out() {
IFS='
';_target="${1}"  # 'stdout', 'stderr' or file
  _prefix="${2}"; _string="${3}"; _suffix="${4}"
  if [ "${_target}" = "stderr" ]; then
    for _line in ${_string}; do
      printf "${_prefix}%s${_suffix}\n" "${_line}"  1>&2
    done; unset IFS; return 0
  elif  [ "${_target}" = "stdout" ]; then
    for _line in ${_string}; do
      printf "${_prefix}%s${_suffix}\n" "${_line}"
    done; unset IFS; return 0
  elif [ -f "${_target}" ]; then
    for _line in ${_string}; do
      printf "${_prefix}%s${_suffix}\n" "${_line}" >> "${_target}"
    done; unset IFS; return 0
  fi; unset IFS; return 1
}

[ -t 1 ] && IS_TTY="yes" || IS_TTY="no"

_output_color() {
  _lvl="${1}"
  if [ ${IS_TTY} = "yes" ]; then
    case "${_lvl}" in
      trace) echo "\033[0;37m"; return 0 ;;
      debug) echo "\033[0;37m"; return 0 ;;  # Gray
      info) echo ""; return 0 ;;  # Gray
      note) echo "\033[0;36m"; return 0 ;;  # Cyan
      ok) echo "\033[0;32m"; return 0 ;;  # Green
      warn) echo "\033[0;33m"; return 0 ;;  # Yellow
      err) echo "\033[0;31m"; return 0 ;;  # Red
      fatal) echo "\033[0;31m"; return 0 ;;  # Red
      *) echo "" return 1 ;;  # Normal
    esac
  else
    echo ""; return 0;
  fi
}

_output_severity() {
  _lvl="${1}"
  case "${_lvl}" in
    trace) echo "[TRACE]"; return 0 ;;
    debug) echo "[DEBUG]"; return 0 ;;
    info) echo "[INFO] "; return 0 ;;
    note) echo "[NOTE] "; return 0 ;;
    ok) echo "[OK]   "; return 0 ;;
    warn) echo "[WARN] "; return 0 ;;
    err) echo "[ERR]  "; return 0 ;;
    fatal) echo "[FATAL]"; return 0 ;;
    *) echo "[UNDEF]"; return 1 ;;
  esac
}


#* ---------------------------------------|
#*|  E X C E P T I O N    H A N D L I N G
#*

#set -x     # Debugging
set -o errtrace
exec 3>&1
declare -a failures
declare -a CLEANUP
trap _cleanup EXIT

_catch_error() {
  local _stderr="${1}" # stderr->_stderr, regular output-> 3 (redirects to stdout)
  local _exit_code="${2}"
  local _lineno="${3}"
  if [ "${_exit_code}" -gt 0 ]; then
    [ -z "${_stderr}" ] && _stderr="(Line: ${_lineno} | Exit: ${_exit_code}): Failed" || _stderr="(Line: ${_lineno} | Exit: ${_exit_code}): ${_stderr}"
    failures[ ${#failures[@]} ]="${_stderr}"
    output "debug" "${_stderr}"
  fi
}
_cleanup() {
  if [ "${#CLEANUP[@]}" -eq 0 ]; then
    output "debug" "No files to cleanup"
    trap - EXIT; exit 0
  fi
  output "debug" "Cleaning up leftover files"
    _catch_error "$( rm ${CLEANUP} 2>&1)" "${?}" "$LINENO"
  trap - EXIT; exit 0
}

_summarize_run() {
  if [ ${#failures[@]} -eq 0 ]; then
    output "ok" "Script completed without errors"
    trap - EXIT; exit 0
  fi
  output "warn" "The script encountered errors durring execution"
  for failure in "${failures[@]}"; do
    output "err" "${failure}";
  done
  exit 1
}

_throw_error() {
  case "${1}" in
    0) output "err" "${2}"; exit 1 ;;
    1) output "err" "Multiple script instances detected, exiting..."; exit 1 ;;
    2) output "err" "The flag \"${2}\" is not recognized  [-h for help]"; exit 1 ;;
    *) output "err" "Unexpected error, exiting...  [-h for help]"; exit 1 ;;
  esac
}


#* ---------------------------------------|
#*|  U S A G E    A N D    H E L P
#*

version() {
  printf "\n"
  printf "Name:    %s\n" "srutils"
  printf "Author:  %s\n" "${AUTHOR}"
  printf "URL:     %s\n" "${URL}"
  printf "Version: %s\n" "${VERSION}"
  printf "License: %s\n" "${LICENSE}"
  printf "\n"
}



#* ---------------------------------------|
#*|  S T A R T    H E R E
#*

flag_conf="0"
flag_cron="0"
flag_help="0"
flag_version="0"
flag_v="3"
flag_quiet="0"

OUT_V="${flag_v}"   # Output verbosity
LOG_V="0"           # Log verbosity

output "debug" "Parsing command line options"
while [ $# -gt 0  ]; do
  case "$1" in
    --help|-h) help; exit 0 ;;
    --man) man | less; exit 0 ;;
    --version) version; exit 0 ;;
    --verbose|-v) [ "${flag_v}" = "1" ] && flag_v="2" ;;
    --very-verbose|-vv) flag_v="3" ;;
    --quiet|-q) flag_quiet="1" ;;
    --conf=*) flag_conf="1"; CONF_ALT="$(echo "$1" | sed 's/--conf=//g')" ;;
    --cron|-c) flag_cron="1" ;;
    --diff|-d) RUN_DIFF='1' ;;
    --sync|-s) RUN_SYNC='1' ;;
    --scrub|-b) RUN_SCRUB='1' ;;
    --smart|-t) RUN_SMART="1" ;;
    *) _throw_error 2 ${1} ;;
  esac; shift
done

output "debug" "Disabling verbosity if running as cronjob"
[ "${flag_quiet}" = "1" ] && $( flag_v="0"; LOG_LEVEL="0" )
[ "${flag_cron}" = "1" ] && OUT_V="0" || OUT_V="${flag_v}"

output "info" "|  Launching \`srutils\`  -  $(timestamp)"

output "debug" "Script Launched, ensuring no other copies are running"
[ `ps aux | grep --count "[s]rutils"` -gt 2 ] && _throw_error 1

[ "$(id -u)" != '0' ] && _throw_error 0 "Script must be run as root user, exiting"

output "debug" "Finished parsing options, continuing with script execution"

[ -z $RUN_DIFF ] && [ -z $RUN_SYNC ] && [ -z $RUN_SCRUB ] && [ -z $RUN_SMART ] && \
  _throw_error 0 "Please use flags to indicate what should be done  [-h for help]"
if [ "${flag_conf}" = "1" ]; then
  CONF_FILE="${CONF_ALT}"
else
  CONF_FILE='/etc//send-archives.conf'
fi

output "debug" "Loading configuration file"
[ -f $CONF_FILE ] && source $CONF_FILE

LOG_FILE=${LOG_FILE:-"/var/log/snapraid.log"}
[ "${flag_quiet}" = "1" ] && LOG_LEVEL="0" || LOG_LEVEL=${LOG_LEVEL:-"1"}

logging "${LOG_LEVEL}"
LOG_LEVEL="${?}"
LOG_V="${LOG_LEVEL}"
output "debug" "Logging level: ${LOG_V}"

output "debug" "Options configured -- Starting script execution"

output "debug" "Starting snapraid_diff function, if enabled"
[ -n "$RUN_DIFF" ] && snapraid_diff

output "debug" "Starting snapraid_scrub function, if enabled"
[ -n "$RUN_SCRUB" ] && snapraid_scrub

output "debug" "Starting snapraid_sync function, if enabled"
[ -n "$RUN_SYNC" ] && snapraid_sync

output "debug" "Starting smartctl function, if enabled"
[ -n "$RUN_SMART" ] && snapraid_smart


output "debug" "Completed Passes"
_summarize_run
