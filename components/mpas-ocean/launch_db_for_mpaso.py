from smartredis import Client
from smartsim import Experiment
from smartsim.database import Orchestrator
from smartsim.log import get_logger, log_to_file
import time
import os

BUILD_DIR="/global/homes/c/cbegeman/E3SM-new/components/mpas-ocean/"
print('Create Experiment object')
exp = Experiment("mpas-ocean_simulation", launcher="slurm")
print('Create database')
port = 6379
db = exp.create_database(db_nodes=1,
                         batch=True,
                         port=port,
                         time="00:30:00",
                         account="e3sm",
                         partition="standard",
                         batch_args={"C":"haswell"})

if os.path.exists('{}/db_debug.log'.format(BUILD_DIR)):
    os.system('rm {}/db_debug.log'.format(BUILD_DIR))
log_to_file('{}/db_debug.log'.format(BUILD_DIR))
logger = get_logger('db_launcher')

# define how simulation should be executed
print('Set run settings')
exp.generate(db, overwrite=True)
print('Start experiment')
exp.start(db) 

os.environ['SSDB'] = f"{db.hosts[0]}:{port}"
logger.debug('SSDB={}'.format(os.environ.get('SSDB')))
print(f"{db.hosts[0]}:{port}")

print(exp.get_status(db))

time.sleep(25*60)
#client = Client(address=f"{db.hosts[0]}:{port}", cluster=False)
#print('client initialized')
#key_found = client.poll_key("send_array", 200, 10000)
#print('key_found',key_found)
#if key_found:
#    dummy_array = client.get_tensor("send_array").astype(real)
#    print('dummy_array=',dummy_array)
#else:
#    print('key not found')
exp.stop(db)
