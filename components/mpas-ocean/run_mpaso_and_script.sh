CASE_DIR=/global/cscratch1/sd/cbegeman/MPAS-Ocean-test-case-output/smartsim/ocean/baroclinic_channel/10km/default/
MODEL_DIR=/global/homes/c/cbegeman/E3SM-new/components/mpas-ocean
conda activate smartsim
cp $MODEL_DIR/environ.sh $CASE_DIR/.
cp $CASE_DIR/db_debug.log $MODEL_DIR/.
cd $CASE_DIR
python $MODEL_DIR/get_ssdb.py
echo "completed get_ssdb"
source $CASE_DIR/environ.sh
echo $SSDB
echo "running compass"
compass run &

echo "running client script"
conda activate smartsim
python $MODEL_DIR/mpas_client_script.py &
