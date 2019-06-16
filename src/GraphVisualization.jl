module GraphVisualization

using Cairo, Colors
using LightGraphs: AbstractSimpleGraph, vertices, degree, edges, src, dst

export AbstractAnnotatedGraph, AnnotatedSimpleGraph, plot

include("./annotatedgraph.jl")
include("./layout.jl")
include("./plot.jl")

## End Pkg
##--------
end
