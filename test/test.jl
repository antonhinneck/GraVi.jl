include("C:/Users/Anton Hinneck/Desktop/Libya/GraphVisualization.jl/src/GraphVisualization.jl")
include("C:/Users/Anton Hinneck/juliaPackages/GitHub/PowerGrids.jl/src/PowerGrids.jl")
using .PowerGrids, .GraphVisualization
using LightGraphs
using Ipopt, JuMP, Mosek, MosekTools, ECOS
using Gurobi
dir = @__DIR__
cd(dir)

set_csv_path("C:/Users/Anton Hinneck/Documents/Git/pglib2csv/pglib/2020-08-21.19-54-30-275/csv")
PowerGrids.csv_cases(verbose = true)
PowerGrids.select_csv_case(37)
case = PowerGrids.loadCase() # 118 Bus ieee

include("plot_new.jl")

graph = PowerGrids.toGraph(case)

function get_x_start_offset(g, xvals, yvals)

    _edges = [LightGraphs.edges(g)...]
    _vertices = [LightGraphs.vertices(g)...]
    edges_start_at_bus = Vector{Vector{Int64}}()
    for i in 1:length(_vertices)
        push!(edges_start_at_bus, Vector{Int64}())
    end

    ctr = 1
    for e in _edges
        push!(edges_start_at_bus[e.src], ctr)
        ctr += 1
    end

    edge_start_offset = zeros(length(_edges))

    for v in _vertices

        vert_lwr = Vector{Int64}()
        vals_lwr = Vector{Float64}()
        vert_gtr = Vector{Int64}()
        vals_gtr = Vector{Float64}()

        for e in edges_start_at_bus[v]

            if xvals[_edges[e].dst] < xvals[v]
                push!(vert_lwr, _edges[e].dst)
                push!(vals_lwr, yvals[_edges[e].dst])
            else
                push!(vert_gtr, _edges[e].dst)
                push!(vals_gtr, yvals[_edges[e].dst])
            end
        end

        perm_lwr = sortperm(vals_lwr)
        #permute!(vals_lwr, perm_lwr)
        permute!(vert_lwr, perm_lwr)

        perm_gtr = sortperm(vals_gtr)
        #permute!(vals_gtr, perm_gtr)
        permute!(vert_gtr, perm_gtr)

        ctr = 1
        for e in vert_lwr
            edge_start_offset[e] = ctr
            ctr += 1
        end
        for e in vert_gtr
            edge_start_offset[e] = ctr
            ctr += 1
        end
    end

    return edge_start_offset
end

function compute_positions(g, W, H, padding; root = :upperleft, min_distx = 8, min_disty = 8, root_vertex = -1, x_os = 1, y_os = 1)

    @assert padding <= W - padding "Error: Canvas empty (width)."
    @assert padding <= H - padding "Error: Canvas empty (height)."

    sp_adj, sp, seq = bfs(graph, initialization = 1)

    m = Model(Gurobi.Optimizer)
    set_optimizer_attributes(m, "TimeLimit" => 30)

    verts = [vertices(g)...]

    @variable(m, x[verts] >= 0)
    @variable(m, y[verts] >= 0)
    @variable(m, right[v1 in verts, v2 in verts; v1 < v2], Bin)
    @variable(m, lower[v1 in verts, v2 in verts; v1 < v2], Bin)
    @variable(m, dist_x >= 0)
    @variable(m, dist_y >= 0)

    # Root vertex equals
    if root == :upperleft
        fix(x[1], padding + x_os, force = true)
        fix(y[1], padding + y_os, force = true)
    elseif root == :center
        fix(x[1], (W / 2), force = true)
        fix(y[1], (H / 2), force = true)
    elseif root == :leftcenter
        fix(x[1], padding + x_os, force = true)
        fix(y[1], (H / 2), force = true)
    end

    @constraint(m, Wlim_up[v in verts], x[v] - x_os >= padding)
    @constraint(m, Wlim_lw[v in verts], x[v] + x_os <= W - padding)

    @constraint(m, Hlim_up[v in verts], y[v] - y_os >= padding)
    @constraint(m, Hlim_lw[v in verts], y[v] + y_os <= H - padding)

    @constraint(m, con_dist_x1[v1 in verts, v2 in verts; v1 < v2], dist_x <= x[v1] - x[v2] + W * (1 - right[v1,v2]))
    @constraint(m, con_dist_x2[v1 in verts, v2 in verts; v1 < v2], dist_x <= x[v2] - x[v1] + W * right[v1,v2])
    @constraint(m, con_dist_x3[v1 in verts, v2 in verts; v1 < v2], dist_y <= y[v1] - y[v2] + W * (1 - lower[v1,v2]))
    @constraint(m, con_dist_x4[v1 in verts, v2 in verts; v1 < v2], dist_y <= y[v2] - y[v1] + W * lower[v1,v2])

    @constraint(m, con_x[v1 in verts, v2 in sp_adj[v1], v3 in sp_adj[v1]; v1 < v2], x[v1] <= x[v2])

    @objective(m, Max, (dist_x + dist_y))

    optimize!(m)
    objective_value(m)

    println(string("Distance Value: ",value.(m[:dist_x])))

    return [value.(m[:x]).data, value.(m[:y]).data]
end

function plot(fig, graph, name, W, H; radius = 2, root = :center, lw = 1.0, lstyle = :rectangular, bstyle = :rectangle)

    init_figure(fig, name, W, H)

    vertices = [LightGraphs.vertices(graph)...]
    edges = [LightGraphs.edges(graph)...]

    coords = compute_positions(graph, W, H, fig.padding, root = root, x_os = 1, y_os = 6)
    x_start_offset = get_x_start_offset(graph, coords[1], coords[2])
    xso = 8
    # coords contains x and y positions

    # PLOT EDGES
    ectr = 1
    if lstyle == :direct
        # Plot edges: direct
        for e in edges
            s = e.src
            d = e.dst
            set_line_width(fig.cairo_context, lw)
            set_source_rgb(fig.cairo_context, [0, 0, 1]...)
            move_to(fig.cairo_context, coords[1][s], coords[2][s])
            line_to(fig.cairo_context, coords[1][d], coords[2][d])
            stroke(fig.cairo_context)
        end
    elseif lstyle == :rectangular
        # Plot edges: rectangular
        for e in edges
            s = e.src
            d = e.dst

            set_line_width(fig.cairo_context, lw)
            set_source_rgb(fig.cairo_context, [0, 0, 1]...)

            if x_start_offset[ectr] == 1.0

                move_to(fig.cairo_context, coords[1][s], coords[2][s])
                line_to(fig.cairo_context, coords[1][s], coords[2][d])
                move_to(fig.cairo_context, coords[1][s], coords[2][d])
                line_to(fig.cairo_context, coords[1][d], coords[2][d])
                stroke(fig.cairo_context)

                if coords[1][s] < coords[1][d]
                    arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = 0, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
                else
                    arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = pi, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
                end

            else

                move_to(fig.cairo_context, coords[1][s], coords[2][s])
                line_to(fig.cairo_context, coords[1][s] + xso * (x_start_offset[ectr] - 1.0), coords[2][s])
                move_to(fig.cairo_context, coords[1][s] + xso * (x_start_offset[ectr] - 1.0), coords[2][s])
                line_to(fig.cairo_context, coords[1][s] + xso * (x_start_offset[ectr] - 1.0), coords[2][d])
                move_to(fig.cairo_context, coords[1][s] + xso * (x_start_offset[ectr] - 1.0), coords[2][d])
                line_to(fig.cairo_context, coords[1][d], coords[2][d])
                stroke(fig.cairo_context)

                if coords[1][s] < coords[1][d]
                    arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = 0, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
                else
                    arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = pi, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
                end
            end
        end
    end

    # Plot vertices
    for v in vertices
        if bstyle == :circle
            set_source_rgb(fig.cairo_context, [0,0,0]...)
            circle(fig.cairo_context, coords[1][v], coords[2][v], radius)
            fill(fig.cairo_context)
        elseif bstyle == :rectangle
            set_source_rgb(fig.cairo_context, [0,0,0]...)
            set_source_rgb(fig.cairo_context, 0.0, 0.0, 0.0);
            set_line_width(fig.cairo_context, 1);
            rectangle(fig.cairo_context, coords[1][v] - 1, coords[2][v] - 6, 2, 12);
            #rectangle(cr, 180, 20, 80, 80);
            stroke_preserve(fig.cairo_context);
            fill(fig.cairo_context);
        end
    end

    finish(fig.cairo_surface)

    return fig, coords
end

fig = figure()
plot(fig, graph, "cairoplot", 800, 600, root = :upperleft, lstyle = :rectangular)

# function plot_arrow(fig, graph, name, W, H; radius = 2, root = :center, lw = 1.0, lstyle = :rectangular)
#
#     init_figure(fig, name, W, H)
#
#     # move to center of canvas
#     circle(fig.cairo_context, 40, 20, 1)
#     fill(fig.cairo_context)
#     #circle(fig.cairo_context, 40 + 4.619, 20 - 1.913, 1)
#     #fill(fig.cairo_context)
#     # rel_line_to(fig.cairo_context, arrow_length * cos(arrow_angle), arrow_length * sin(arrow_angle))
#     # rel_move_to(fig.cairo_context, -arrowhead_length * cos(arrow_angle - arrowhead_angle), -arrowhead_length * sin(arrow_angle - arrowhead_angle))
#     arrow_head_to(fig.cairo_context, 40, 20, a_angle = 0, ah_angle = pi/8)
#     arrow_head_to(fig.cairo_context, 40, 20, a_angle = pi / 2, ah_angle = pi/8)
#     arrow_head_to(fig.cairo_context, 40, 20, a_angle = pi, ah_angle = pi/8)
#     arrow_head_to(fig.cairo_context, 40, 20, a_angle = 3 * pi/2, ah_angle = pi/8)
#
#     # arrow_head_to(fig.cairo_context, 40, 20, a_angle = 0, ah_angle = pi/8, offset = :zero, color = [1,0,0])
#     # arrow_head_to(fig.cairo_context, 40, 20, a_angle = pi/4, ah_angle = pi/8, offset = :zero, color = [1,0,0])
#     # arrow_head_to(fig.cairo_context, 40, 20, a_angle = pi, ah_angle = pi/8, offset = :zero, color = [1,0,0])
#     # arrow_head_to(fig.cairo_context, 40, 20, a_angle = 3*pi/2, ah_angle = pi/8, offset = :zero, color = [1,0,0])
#     # rel_line_to(fig.cairo_context, arrowhead_length * cos(arrow_angle - arrowhead_angle), arrowhead_length * sin(arrow_angle - arrowhead_angle))
#     # rel_line_to(fig.cairo_context, -arrowhead_length * cos(arrow_angle + arrowhead_angle), -arrowhead_length * sin(arrow_angle + arrowhead_angle))
#     #
#     # set_source_rgb(fig.cairo_context, 0,0,0)
#     # set_line_width(fig.cairo_context, lw)
#     # stroke(fig.cairo_context)
#
#     finish(fig.cairo_surface)
# end
#
# fig = figure()
# plot_arrow(fig, graph, "cairoplot", 200, 200, root = :upperleft, lstyle = :rectangular)
