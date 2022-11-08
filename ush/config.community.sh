MACHINE="hera"
ACCOUNT="an_account"
EXPT_SUBDIR="test_community"

COMPILER="intel"
VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

IS_ENS_FCST="FALSE"
NUM_ENS_MEMBERS="2"

CCPP_PHYS_SUITE="FV3_GFS_v16"
FCST_LEN_HRS="12"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "18" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="02:00:00"

MODEL="FV3_GFS_v16_CONUS_25km"
METPLUS_PATH="path/to/METPlus"
MET_INSTALL_DIR="path/to/MET"
CCPA_OBS_DIR="/path/to/processed/CCPA/data"
MRMS_OBS_DIR="/path/to/processed/MRMS/data"
NDAS_OBS_DIR="/path/to/processed/NDAS/data"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"
RUN_TASK_GET_OBS_CCPA="FALSE"
RUN_TASK_GET_OBS_MRMS="FALSE"
RUN_TASK_GET_OBS_NDAS="FALSE"
RUN_TASK_VX_GRIDSTAT="FALSE"
RUN_TASK_VX_POINTSTAT="FALSE"
RUN_TASK_VX_ENSGRID="FALSE"
RUN_TASK_VX_ENSPOINT="FALSE"

#
# Uncomment the following line in order to use user-staged external model 
# files with locations and names as specified by EXTRN_MDL_SOURCE_BASEDIR_ICS/
# LBCS and EXTRN_MDL_FILES_ICS/LBCS.
#
#USE_USER_STAGED_EXTRN_FILES="TRUE"
#
# The following is specifically for Hera.  It will have to be modified
# if on another platform, using other dates, other external models, etc.
# Uncomment the following EXTRN_MDL_*_ICS/LBCS only when USE_USER_STAGED_EXTRN_FILES=TRUE
#
#EXTRN_MDL_SOURCE_BASEDIR_ICS="/scratch2/BMC/det/UFS_SRW_App/develop/input_model_data/FV3GFS/grib2/2019061518"
#EXTRN_MDL_FILES_ICS=( "gfs.t18z.pgrb2.0p25.f000" )
#EXTRN_MDL_SOURCE_BASEDIR_LBCS="/scratch2/BMC/det/UFS_SRW_App/develop/input_model_data/FV3GFS/grib2/2019061518"
#EXTRN_MDL_FILES_LBCS=( "gfs.t18z.pgrb2.0p25.f006" "gfs.t18z.pgrb2.0p25.f012")
