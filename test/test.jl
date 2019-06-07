include("C:/Users/Anton Hinneck/.julia/packages/GraphVisualization/src/GraphVisualization.jl")
include("C:/Users/Anton Hinneck/.julia/packages/PowerGrids/src/PowerGrids.jl")
using LightGraphs

graph = SimpleGraph()

for i in 1:5
    add_vertex!(graph)
end

nodes = [i for i in vertices(graph)]

for i in 1:4
    src = 0
    dst = 0
    while dst == src
        src = rand(nodes, 1)[1]
        dst = rand(nodes, 1)[1]
    end
    new_edge = Edge(src, dst)
    add_edge!(graph, new_edge)
end

for i in edges(graph)
    print(src(i), dst(i), "\n")
end

grid = PowerGrids.get_datasets()[1]
