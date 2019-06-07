module GraphVisualization

include("./annotatedgraph.jl")
using JuMP, Cairo, Gurobi, LightGraphs, SimpleGraphs, Colors

export AbstractAnnotatedGraph, AnnotatedSimpleGraph

struct canvas
## Measures in Pixels
##-------------------
    hight::Int64
    width::Int64
end

## End Pkg
##--------
end
