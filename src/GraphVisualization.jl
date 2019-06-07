module GraphVisualization

using JuMP, Cairo, Gurobi, LightGraphs, Colors

struct canvas
## Measures in Pixels
##-------------------
    hight::Int64
    width::Int64
end

mutable struct Layout
    canvas::canvas
end

mutable struct Elements
    ne::T where T <: Integer
    v_labels::Vector{String}
    e_labels::Vector{String}
end

## End Pkg
##--------
end
