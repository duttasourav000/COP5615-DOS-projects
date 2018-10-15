import json
import os
import sys

algoithm = sys.argv[1]
topologies = ['full', '3D', 'rand2D', 'torus', 'line', 'impline']
nodes = range(100, 5001, 500)

times_for_topologies = {}

for topology in topologies:
    times_for_nodes = []
    for n in nodes:
        command = 'mix run lib/proj2.exs %s %s %s > .op.txt' % (n, topology, algoithm)
        print (command)
        os.system('bash -c "%s"' % command)

        f = open('.op.txt', 'r')
        lines = f.readlines()
        f.close()

        milliseconds = int(lines[len(lines) - 1])
        times_for_nodes.append(milliseconds)

    times_for_topologies[topology] = {}
    times_for_topologies[topology]['nodes'] = nodes
    times_for_topologies[topology]['time (ms)'] = times_for_nodes

f = open('data/%s.json' % algoithm, 'w')
json.dump(times_for_topologies, f)
f.close()