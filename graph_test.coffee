assert = require('assert')
graph = require('./graph.coffee')

g = new graph.Graph()
g.set 0, 0, 11
g.set 1, 0, 22
g.set 0, 1, 33
g.set 1, 1, 44

assert.equal g.get(0, 0), 11
assert.equal g.get(1, 0), 22
assert.equal g.get(0, 1), 33
assert.equal g.get(1, 1), 44
assert.equal g.get(99, 99), 0
assert.equal g.get(-1, -1), 0

assert.equal g.getPoint([0, 0]), 11
assert.equal g.getPoint([1, 0]), 22

assert.deepEqual g.getRect(0, 0, 2, 2), [[11, 22], [33, 44]]
assert.deepEqual g.getRect(-1, -1, 2, 2), [[0, 0], [0, 11]]

# Neighbors with diagonals.
neighbors = (p.join(',') for p in g.neighbors(0, 0))
points = ['-1,-1', '0,-1', '1,-1',
          '-1,0',          '1,0',
          '-1,1',  '0,1',  '1,1']
for point in points
  assert.ok point in neighbors, "#{point} in neighbors"

# Neighbors without diagonals.
neighbors = (p.join(',') for p in g.neighbors(0, 0, false))
points = [         '0,-1',
          '-1,0',          '1,0',
                   '0,1']
for point in points
  assert.ok point in neighbors, "#{point} in neighbors"

# Let's try an A* pathfind from 'S' to 'E':
# +-----+    +-----+
# |.X..E|    |.X**E|
# |.X.XX| -> |.X*XX|
# |S....|    |S**..|
# +-----+    +-----+
m = [[1, 0, 1, 1, 1],
     [1, 0, 1, 0, 0],
     [1, 1, 1, 1, 1]]
g = new graph.Graph(m)
path = g.astar(0,2, 3,0)
assert.deepEqual path, [[1,2],[2,2],[2,1],[2,0],[3,0]]

# Same thing, but with diagonals.
# +-----+
# |.X.*E|
# |.X*XX|
# |S*...|
# +-----+
path = g.astar(0,2, 3,0, null, null, true)
assert.deepEqual path, [[1,2],[2,1],[3,0]]

# Can only traverse values > 2
# +-----+    +-----+
# |1143E|    |11**E|
# |92929| -> |92*29|
# |S3392|    |S**92|
# +-----+    +-----+
m = [[1, 1, 4, 3, 3],
     [9, 2, 9, 2, 9],
     [3, 3, 3, 9, 2]]
g = new graph.Graph(m)

path = g.astar(4,2, 4,0, null, null, false)
assert.deepEqual path, [[4,1]]

filter = (value) -> value > 2
path = g.astar(0,2, 4,0, filter, null, false)
assert.deepEqual path, [[1,2],[2,2],[2,1],[2,0],[3,0]]

# Heuristic which looks for path of least resistance.
# +-----+    +-----+
# |2111E|    |1***E|
# |21248| -> |1*248|
# |2111S|    |1***S|
# +-----+    +-----+
m = [[2, 1, 1, 1, 1],
     [2, 1, 9, 9, 9],
     [1, 1, 1, 1, 1]]
g = new graph.Graph(m)

path = g.astar(4,2, 4,0, null, null, false)
assert.deepEqual path, [[4,1]]

heuristic = (p1, p2) -> g.get(p2)
path = g.astar(4,2, 4,0, null, heuristic, false)
assert.deepEqual path, [[3,2],[2,2],[1,2],[1,1],[1,0],[2,0],[3,0]]

# Now an impossible path
# +-----+
# |S.0.E|
# +-----+
m = [[1, 1, 0, 1, 1]]
g = new graph.Graph(m)
path = g.astar(0,0, 4,0)
assert.deepEqual path, []

console.log 'all tests ok'

