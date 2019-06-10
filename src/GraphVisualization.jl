module GraphVisualization

using JuMP, Cairo, Gurobi, Colors
using LightGraphs: AbstractSimpleGraph

export AbstractAnnotatedGraph, AnnotatedSimpleGraph

include("./annotatedgraph.jl")

struct canvas
## Measures in Pixels
##-------------------
    hight::Int64
    width::Int64
end

## End Pkg
##--------
end
