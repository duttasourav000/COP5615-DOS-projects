import plotly
import plotly.graph_objs as go
import pandas as pd
import json
import math
import sys

algoithm = sys.argv[1]

f = open('data/%s.json' % algoithm, 'r')
time_for_topologies = json.load(f)
f.close()

data = []
for topology in time_for_topologies.keys():
    timings = []
    nodes = []  
    topology_df = pd.DataFrame.from_dict(time_for_topologies[topology])
    topology_df['time (ms)'] = topology_df['time (ms)'].apply(lambda x: math.log(x))
    data.append(go.Scatter(
        x = topology_df['nodes'],
        y = topology_df['time (ms)'],
        name = topology,
        line = dict(
            # color = ('rgb(205, 12, 24)'),
            width = 4)
        )
    )
    
#layout
layout = dict(title = '%s Convergernce' % algoithm,
                xaxis = dict(title = 'nodes'),
                yaxis = dict(title = 'log (time (ms))'),
            )

fig = dict(data=data, layout=layout)
plotly.offline.plot(fig, filename='data/%s-plot.html' % algoithm,auto_open=True)
