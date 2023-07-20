export SMARTREDIS_PATH=/global/cscratch1/sd/$USER/smartredis-v0.3.0/install/lib
export LD_LIBRARY_PATH=${SMARTREDIS_PATH}:$LD_LIBRARY_PATH
export SMARTREDIS_DEBUG_LEVEL=VERBOSE
export SSDB=None


source load_compass_env.sh
