#!/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt
from os import listdir
import pandas as pd
# import sys

file = "dump.deposit.atom.velocity.txt"
# file = "processed_data.txt"

file_data = open(file, 'r').read()
lines = file_data.split('\n')

data_array = np.empty((0,8))

for line in lines:
    if line.startswith('ITEM'):
        continue
    if len(line) > 1:
        line_split = line.split()
        if len(line_split) < 8:
            continue
        data_array = np.append(data_array, np.array([line_split]), axis=0)
        # print(np.array([[float(i) for i in line_split]]))

colNames = ["id", "type", "xs", "ys", "zs", "vx", "vy", "vz"]
data_df = pd.DataFrame(data = data_array, columns=colNames)
data_df = data_df.astype(float)
data_df = data_df.astype({"id": int, "type": int})

data_df = data_df.sort_values(by=["id","ys"])
data_df = data_df.reset_index(drop=True)
# print(data_df.to_string())

row_ys_max = data_df.groupby(['id'])['ys'].transform(max) == data_df['ys']
data_df_reduced = data_df[row_ys_max].reset_index(drop=True)
data_df_reduced['theta'] = np.arctan(data_df_reduced['vy']/data_df_reduced['vz'])/np.pi*180
data_df_reduced['azimu'] = 90 - np.arctan(data_df_reduced['vx']/data_df_reduced['vy'])/np.pi*180
data_df_reduced = data_df_reduced[ data_df_reduced['theta'] > 0 ]

print(data_df_reduced.loc[:,'id':'vz'].to_string(header=False, index=False))

fig = plt.figure()
fig.add_subplot(111)
plt.hist(data_df_reduced['theta'], bins=50, rwidth=0.8)
plt.xlabel(r'$\theta$ (degree)')
plt.ylabel('Counts of scattered particles')
plt.title('Histogram of scattered polar angles of '+str(len(data_df_reduced.index))+' incident ions')
# plt.show()

plt.savefig('distribution.theta.pdf')

fig = plt.figure()
fig.add_subplot(111)
plt.hist(data_df_reduced['azimu'], bins=50, rwidth=0.8)
plt.xlabel(r'$\phi$ (degree)')
plt.ylabel('Counts of scattered particles')
plt.title('Histogram of scattered azimuthal angles of '+str(len(data_df_reduced.index))+' incident ions')
# plt.show()

plt.savefig('distribution.phi.pdf')
