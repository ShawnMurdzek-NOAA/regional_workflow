#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that 
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"
#
# This test assumes the forecast files will be generated by running a
# an ensemble forecast.  Thus, specify the parameters needed to run
# such a forecast.  Note that the flag that turns on ensemble forecasts
# (IS_ENS_FCST) as well as the number of ensemble members are set further
# below.
#
PREDEF_GRID_NAME="RRFS_CONUS_25km"
LAYOUT_X="10"
LAYOUT_Y="4"
CCPP_PHYS_SUITE="FV3_GFS_2017_gfdlmp"

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DATE_FIRST_CYCL="20190701"
DATE_LAST_CYCL="20190702"
CYCL_HRS=( "00" "12" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"
#
# This test assumes the observation files will be fetched using the
# GET_OBS_... tasks.  Thus, activate these tasks and specify the
# locations for staging the files.
#
RUN_TASK_GET_OBS_CCPA="TRUE"
CCPA_OBS_DIR='$EXPTDIR/obs_data/ccpa/proc'
RUN_TASK_GET_OBS_MRMS="TRUE"
MRMS_OBS_DIR='$EXPTDIR/obs_data/mrms/proc'
RUN_TASK_GET_OBS_NDAS="TRUE"
NDAS_OBS_DIR='$EXPTDIR/obs_data/ndas/proc'
#
# This test assumes that the forecast(s) to be verified is an ensemble
# forecast, i.e. that the post-processed forecast files are in an ensemble
# directory structure.  Thus, turn the flag that specifies this on and
# specify the number of members in the ensemble.
#
IS_ENS_FCST="TRUE"
NUM_ENS_MEMBERS="2"
#
# Run deterministic vx on each member of the forecast ensemble.
#
RUN_TASKS_VXDET="TRUE"
#
# Run vx on the ensemble as a whole.
#
RUN_TASKS_VXENS="TRUE"
#
# Specify other vx parameters including ENS_TIME_LAG_HRS, which is the
# time-lagging that the vx tasks should assume for each ensemble member
# (in units of hours).
#
ENS_TIME_LAG_HRS=( "0" "0" )
VX_FCST_MODEL_NAME="FV3_RRFSE"
NET='RRFSE_CONUS'
#
# MET and METplus paths.  Move these to the machine files?
#
METPLUS_PATH="/contrib/METplus/METplus-4.1.1"
MET_INSTALL_DIR="/contrib/met/10.1.1"
#
# The following are for the old versions of the vx tasks.  Should remove
# at some point.
#
INCLUDE_OLD_VX_TASKS_IN_XML="FALSE"

RUN_TASK_VX_GRIDSTAT="TRUE"
RUN_TASK_VX_POINTSTAT="TRUE"
RUN_TASK_VX_ENSGRID="TRUE"
RUN_TASK_VX_ENSPOINT="TRUE"

WTIME_VX_ENSPOINT="08:00:00"
WTIME_VX_ENSGRID="08:00:00"
