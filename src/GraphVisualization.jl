module GraphVisualization

using Cairo, Colors
using JuMP
using Gurobi, Ipopt
using LightGraphs #: AbstractSimpleGraph, vertices, degree, edges, src, dst

include("./_main_structs.jl")
include("./_graph_functions.jl")
include("./_tools_opt.jl")
include("./_tools_cairo.jl")
include("./_tools.jl")
include("./_plot.jl")

export figure, legend
export init_figure
export bfs, max_degree_vertex, inv_fadjlist
export arrow_head_to
export compute_positions
export compute_positions_grid
export plot

# include("./annotatedgraph.jl")
# export AbstractAnnotatedGraph, AnnotatedSimpleGraph, plot
# include("./layout.jl")
# include("./plot.jl")

## End Pkg
##--------
end
