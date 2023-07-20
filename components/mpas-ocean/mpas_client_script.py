from smartredis import Client
from smartsim import Experiment
from smartsim.database import Orchestrator
from smartsim.log import get_logger, log_to_file
import time
import os
import numpy

#with open('db_debug.log') as f:
#    lines = f.readlines()
#    for line in lines:
#       if 'SSDB' in line:
#           SSDB = line.split('=')[1]
SSDB=os.environ.get("SSDB")
print(f'SSDB in client script {SSDB}')
client = Client(address=SSDB, cluster=False)

#recv_array = 20*numpy.ones(1)
#err = client.put_tensor("init_recv", recv_array)

# Test smartsend client recv
key_found = client.poll_key("ssh", 20, 10000)
print('key_found',key_found)
if key_found:
    dummy_array = client.get_tensor("ssh")
    print('smartsend =',dummy_array[0])
else:
    print('key not found')

# Test dataset capabilities
mpas_dataset = client.get_dataset('example_fortran_dataset')
mpas_tensor = mpas_dataset.get_tensor('ssh')
print(f'dataset_send tensor={mpas_tensor[0,0]}')
config_mom_del2 = mpas_dataset.get_meta_scalars('config_mom_del2')
print(f'dataset config_mom_del2={config_mom_del2}')
