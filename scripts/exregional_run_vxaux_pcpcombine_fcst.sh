#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source files defining auxiliary functions for verification.
#
#-----------------------------------------------------------------------
#
. $USHDIR/set_vx_params.sh
. $USHDIR/set_vx_fhr_list.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs METplus for grid-stat on
the UPP output files by initialization time for all forecast hours.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "cycle_dir" )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Set various verification parameters associated with the field to be
# verified.  Not all of these are necessarily used later below but are
# set here for consistency with other verification ex-scripts.
#
#-----------------------------------------------------------------------
#
FIELDNAME_IN_OBS_INPUT=""
FIELDNAME_IN_FCST_INPUT=""
FIELDNAME_IN_MET_OUTPUT=""
FIELDNAME_IN_MET_FILEDIR_NAMES=""
fhr_int=""

set_vx_params \
  obtype="${OBTYPE}" \
  field="$VAR" \
  accum2d="${ACCUM}" \
  outvarname_field_is_APCPgt01h="field_is_APCPgt01h" \
  outvarname_fieldname_in_obs_input="FIELDNAME_IN_OBS_INPUT" \
  outvarname_fieldname_in_fcst_input="FIELDNAME_IN_FCST_INPUT" \
  outvarname_fieldname_in_MET_output="FIELDNAME_IN_MET_OUTPUT" \
  outvarname_fieldname_in_MET_filedir_names="FIELDNAME_IN_MET_FILEDIR_NAMES" \
  outvarname_fhr_intvl_hrs="fhr_int"
#
#-----------------------------------------------------------------------
#
# If performing ensemble verification, get the time lag (if any) of the
# current ensemble forecast member.  The time lag is the duration (in 
# seconds) by which the current forecast member was initialized before
# the current cycle date and time (with the latter specified by CDATE).
# For example, a time lag of 3600 means that the current member was
# initialized 1 hour before the current CDATE, while a time lag of 0
# means the current member was initialized on CDATE.
# 
# Note that if we're not running ensemble verification (i.e. if we're 
# running verification for a single deterministic forecast), the time
# lag gets set to 0.
#
#-----------------------------------------------------------------------
#
MEM_INDX_OR_NULL=$((10#${MEM_INDX_OR_NULL}))
time_lag=$(( (${MEM_INDX_OR_NULL:+${ENS_TIME_LAG_HRS[${MEM_INDX_OR_NULL}-1]}}+0)*${secs_per_hour} ))
#
#-----------------------------------------------------------------------
#
# Set paths for input to and output from pcp_combine.  Also, set the
# suffix for the name of the log file that METplus will generate.
#
#-----------------------------------------------------------------------
#
FCST_INPUT_BASE="${VX_FCST_INPUT_BASEDIR}"
FCST_OUTPUT_BASE="${VX_OUTPUT_BASEDIR}"
FCST_OUTPUT_DIR="${FCST_OUTPUT_BASE}/${CDATE}${SLASH_ENSMEM_SUBDIR_OR_NULL}/metprd/pcp_combine_fcst_cmn"
STAGING_DIR="${FCST_OUTPUT_BASE}/${CDATE}${SLASH_ENSMEM_SUBDIR_OR_NULL}/stage_cmn/${FIELDNAME_IN_MET_FILEDIR_NAMES}"
LOG_SUFFIX="_${FIELDNAME_IN_MET_FILEDIR_NAMES}${USCORE_ENSMEM_NAME_OR_NULL}_${CDATE}"

FCST_REL_PATH_TEMPLATE=$( eval echo ${FCST_SUBDIR_TEMPLATE}/${FCST_FN_TEMPLATE} )
FCST_REL_PATH_METPROC_TEMPLATE=$( eval echo ${FCST_SUBDIR_METPROC_TEMPLATE}/${FCST_FN_METPROC_TEMPLATE} )
#
#-----------------------------------------------------------------------
#
# Set the array of forecast hours for which to run pcp_combine.
#
# Note that for ensemble forecasts (which may contain time-lagged
# members), the forecast hours set below are relative to the non-time-
# lagged initialization time of the cycle regardless of whether or not
# the current ensemble member is time-lagged, i.e. the forecast hours
# are not shifted to take the time-lagging into account.
#
# The time-lagging is taken into account in the METplus configuration
# file used by the call below to METplus (which in turn calls MET's
# pcp_combine tool).  In that configuration file, the locations and
# names of the input grib2 files to MET's pcp_combine tool are set using
# the time-lagging information.  This information is calculated and
# stored below in the variable TIME_LAG (and MNS_TIME_LAG) and then
# exported to the environment to make it available to the METplus
# configuration file.
#
#-----------------------------------------------------------------------
#
set_vx_fhr_list \
  fhr_min="${ACCUM}" \
  fhr_int="${fhr_int}" \
  fhr_max="${FCST_LEN_HRS}" \
  cdate="${CDATE}" \
  base_dir="${VX_FCST_INPUT_BASEDIR}" \
  fn_template="${FCST_REL_PATH_TEMPLATE}" \
  check_hourly_files="TRUE" \
  accum="${ACCUM}" \
  outvarname_fhr_list="FHR_LIST"
#
#-----------------------------------------------------------------------
#
# Create the directory(ies) in which MET/METplus will place its output
# from this script.  We do this here because (as of 20220811), when
# multiple workflow tasks are launched that all require METplus to create
# the same directory, some of the METplus tasks can fail.  This is a
# known bug and should be fixed by 20221000.  See https://github.com/dtcenter/METplus/issues/1657.
# If/when it is fixed, the following directory creation step can be
# removed from this script.
#
#-----------------------------------------------------------------------
#
mkdir_vrfy -p "${FCST_OUTPUT_DIR}"
#
#-----------------------------------------------------------------------
#
# Check for existence of top-level OBS_DIR.
#
#-----------------------------------------------------------------------
#
if [ ! -d "${OBS_DIR}" ]; then
  print_err_msg_exit "\
OBS_DIR does not exist or is not a directory:
  OBS_DIR = \"${OBS_DIR}\""
fi
#
#-----------------------------------------------------------------------
#
# Export variables needed in the common METplus configuration file (at
# ${METPLUS_CONF}/common.conf).
#
#-----------------------------------------------------------------------
#
export MET_INSTALL_DIR
export METPLUS_PATH
export MET_BIN_EXEC
export METPLUS_CONF
export LOGDIR
#
#-----------------------------------------------------------------------
#
# Export variables needed in the METplus configuration file metplus_config_fp
# later defined below.  Not all of these are necessarily used in the 
# configuration file but are exported here for consistency with other
# verification ex-scripts.
#
#-----------------------------------------------------------------------
#
export CDATE
export FCST_INPUT_BASE
export FCST_OUTPUT_BASE
export STAGING_DIR
export LOG_SUFFIX
export VX_FCST_MODEL_NAME
export NET
export FHR_LIST

export FIELDNAME_IN_OBS_INPUT
export FIELDNAME_IN_FCST_INPUT
export FIELDNAME_IN_MET_OUTPUT
export FIELDNAME_IN_MET_FILEDIR_NAMES

export FCST_REL_PATH_TEMPLATE
export FCST_REL_PATH_METPROC_TEMPLATE
#
#-----------------------------------------------------------------------
#
# Need to add in variable for handling HREF data: IN_ACCUM
# Default will be 01, unless it is mem05/mem10, then it will be 03.
# Note: This is specifically hard-coded to this application.
#
#-----------------------------------------------------------------------
#
if [[ ${NET} == "HREF" ]]; then 
  if [[ ${USCORE_ENSMEM_NAME_OR_NULL} == "_mem05" || ${USCORE_ENSMEM_NAME_OR_NULL} == "_mem10" ]]; then
    IN_ACCUM="03"
  else
    IN_ACCUM="01"
  fi
else
  IN_ACCUM="01"
fi

export IN_ACCUM
#
#-----------------------------------------------------------------------
#
# Run METplus if there is at least one valid forecast hour.
#
#-----------------------------------------------------------------------
#
if [ -z "${FHR_LIST}" ]; then
  print_err_msg_exit "\
The list of forecast hours for which to run METplus is empty:
  FHR_LIST = [${FHR_LIST}]"
else
  print_info_msg "$VERBOSE" "
Calling METplus to run MET's PcpCombine tool for field(s): ${FIELDNAME_IN_MET_FILEDIR_NAMES}"
  metplus_config_fp="${METPLUS_CONF}/PcpCombine_fcst.conf"
  ${METPLUS_PATH}/ush/run_metplus.py \
    -c ${METPLUS_CONF}/common.conf \
    -c ${metplus_config_fp} || \
  print_err_msg_exit "
Call to METplus failed with return code: $?
METplus configuration file used is:
  metplus_config_fp = \"${metplus_config_fp}\""
fi
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
METplus pcp_combine tool completed successfully.

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
