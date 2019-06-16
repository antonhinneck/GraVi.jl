module GraphVisualization

using Cairo, Colors
using LightGraphs: AbstractSimpleGraph, vertices, degree, edges, src, dst

export AbstractAnnotatedGraph, AnnotatedSimpleGraph, plot

include("./annotatedgraph.jl")
include("./layout.jl")
include("./plot.jl")

struct canvas
## Measures in Pixels
##-------------------
    hight::Int64
    width::Int64
end

## End Pkg
##--------
end
