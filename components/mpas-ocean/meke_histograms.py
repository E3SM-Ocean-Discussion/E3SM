import numpy
import xarray
import matplotlib.pyplot as plt 

comparison=True
if comparison:
    master_path = '/compyfs/bege567/mpaso_scratch/compass-v1.2.0-E3SM-master/ocean/global_ocean/QU240/PHC/performance_test'
meke_path = '/compyfs/bege567/mpaso_scratch/compass-v1.2.0-E3SM-meke-off/ocean/global_ocean/QU240/PHC/performance_test'
#meke_path = '/compyfs/bege567/mpaso_scratch/compass-v1.2.0-E3SM-meke/ocean/global_ocean/QU240/PHC/performance_test'
subdir='forward'
if comparison:
    master_data = xarray.open_dataset(f'{master_path}/{subdir}/output.nc')
meke_data = xarray.open_dataset(f'{meke_path}/{subdir}/output.nc')

nt = meke_data.sizes['Time']

if comparison:
    gmBolusKappa1 = master_data.gmBolusKappa
    gmCellsAvg1 = numpy.mean(gmBolusKappa1, axis=1) # nt
    gmCellsMin1 = numpy.amin(gmBolusKappa1, axis=1) # nt
    gmCellsMax1 = numpy.amax(gmBolusKappa1, axis=1) # nt

gmBolusKappa = meke_data.gmBolusKappa
gmCellsAvg = numpy.mean(gmBolusKappa, axis=1) # nt
gmCellsMin = numpy.amin(gmBolusKappa, axis=1) # nt
gmCellsMax = numpy.amax(gmBolusKappa, axis=1) # nt


mekeSource = meke_data.mekeSourceTopOfEdge.values
mekeSink = meke_data.mekeSink.values
meke = meke_data.meke.values

mekeCellsAvg = numpy.mean(meke, axis=(1,2)) # nt, nVertLevels
mekeCellsMin = numpy.amin(meke, axis=(1,2)) # nt
mekeCellsMax = numpy.amax(meke, axis=(1,2)) # nt

mekeSourceEdgesAvg = numpy.mean(mekeSource, axis=(1,2)) # nt, nVertLevels
mekeSourceEdgesMin = numpy.amin(mekeSource, axis=(1,2)) # nt
mekeSourceEdgesMax = numpy.amax(mekeSource, axis=(1,2)) # nt

mekeSinkCellsAvg = numpy.mean(mekeSink, axis=(1,2)) # nt, nVertLevels
mekeSinkCellsMin = numpy.amin(mekeSink, axis=(1,2)) # nt
mekeSinkCellsMax = numpy.amax(mekeSink, axis=(1,2)) # nt

tidx = 0
#tidx = nt-1

fig = plt.figure()
if comparison:
    plt.hist(gmBolusKappa1[tidx,:],label='master',bins=100)
plt.hist(gmBolusKappa[tidx,:],label='meke',bins=100)
plt.legend()
plt.savefig(f'{meke_path}/gm_histogram.png')
plt.close(fig)

fig,ax = plt.subplots(2)
ax[0].hist(mekeSource[tidx,:].flatten(),label='source',bins=100)
ax[0].hist(mekeSink[tidx,:].flatten(),label='sink',bins=100)
ax[0].set_xlabel('MEKE terms')
ax[0].set_xscale('log')
ax[0].legend()

ax[1].hist(meke[tidx,:].flatten(),bins=100)
ax[1].set_xlabel('MEKE')
ax[1].set_xscale('log')
ax[1].legend()
fig.savefig(f'{meke_path}/meke_histogram.png')
plt.close(fig)

fig,ax = plt.subplots(3,1)
ax[0].plot(mekeSourceEdgesMin, '--b')
ax[0].plot(mekeSourceEdgesAvg, '-b', label='Source')
ax[0].plot(mekeSourceEdgesMax, ':b')
ax[0].plot(mekeSinkCellsMin, '--k')
ax[0].plot(mekeSinkCellsAvg, '-k', label='Sink')
ax[0].plot(mekeSinkCellsMax, ':k')
ax[0].set_yscale('log')
ax[0].legend()
ax[1].plot(mekeCellsMin, '--k')
ax[1].plot(mekeCellsAvg, '-k', label='MEKE')
ax[1].plot(mekeCellsMax, ':k')
ax[1].set_yscale('log')
ax[1].legend()
ax[2].plot(gmCellsMin, '--k')
ax[2].plot(gmCellsAvg, '-k', label='GM MEKE')
ax[2].plot(gmCellsMax, ':k')
ax[2].plot(gmCellsMin1, '--b')
ax[2].plot(gmCellsAvg1, '-b', label='GM master')
ax[2].plot(gmCellsMax1, ':b')
ax[2].legend()
fig.savefig(f'{meke_path}/meke_timeseries.png')
plt.close(fig)

print('mekeSource: min, 10th, 50th, 90th, max')
print(f'{numpy.min(mekeSource[tidx,:])},{numpy.percentile(mekeSource[tidx,:],[10,50,90])},{numpy.max(mekeSource[tidx,:])}')
print('mekeSink: min, 10th, 50th, 90th, max')
print(f'{numpy.min(mekeSink[tidx,:])},{numpy.percentile(mekeSink[tidx,:],[10,50,90])},{numpy.max(mekeSink[tidx,:])}')
print('meke: min, 10th, 50th, 90th, max')
print(f'{numpy.min(meke[tidx,:])},{numpy.percentile(meke[tidx,:],[10,50,90])},{numpy.max(meke[tidx,:])}')
