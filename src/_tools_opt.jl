function compute_positions(g, W, H, padding; root = :upperleft, min_distx = 8, min_disty = 8, root_vertex = -1, x_os = 1, y_os_lwr = 1, y_os_gtr = 1)

    @assert padding <= W - padding "Error: Canvas empty (width)."
    @assert padding <= H - padding "Error: Canvas empty (height)."

    sp_adj, sp, seq = bfs(g, initialization = 1)

    m = Model(Ipopt.Optimizer)
    #set_optimizer_attributes(m, "TimeLimit" => 30)
    set_optimizer_attributes(m, "mumps_mem_percent" => 64000)
    #set_optimizer_attributes(m, "linear_solver" => "pardiso")

    verts = [vertices(g)...]

    @variable(m, x[verts] >= 0)
    @variable(m, y[verts] >= 0)
    # @variable(m, right[v1 in verts, v2 in verts; v1 < v2], Bin)
    # @variable(m, lower[v1 in verts, v2 in verts; v1 < v2], Bin)
    @variable(m, dist >= 0)
    # @variable(m, dist_x >= 0)
    # @variable(m, dist_y >= 0)

    # Root vertex equals
    if root == :upperleft
        fix(x[1], padding + x_os, force = true)
        fix(y[1], padding + y_os_gtr, force = true)
    elseif root == :center
        fix(x[1], (W / 2), force = true)
        fix(y[1], (H / 2), force = true)
    elseif root == :leftcenter
        fix(x[1], padding + x_os, force = true)
        fix(y[1], (H / 2), force = true)
    end

    @constraint(m, Wlim_up[v in verts], x[v] - x_os >= padding)
    @constraint(m, Wlim_lw[v in verts], x[v] + x_os <= W - padding)

    @constraint(m, Hlim_up[v in verts], y[v] - y_os_gtr >= padding)
    @constraint(m, Hlim_lw[v in verts], y[v] + y_os_lwr <= H - padding)

    # @constraint(m, con_dist_x1[v1 in verts, v2 in verts; v1 < v2], dist_x + x_os <= x[v1] - x[v2] + W * (1 - right[v1,v2]))
    # @constraint(m, con_dist_x2[v1 in verts, v2 in verts; v1 < v2], dist_x + x_os <= x[v2] + x_os - x[v1] + W * right[v1,v2])
    # @constraint(m, con_dist_x3[v1 in verts, v2 in verts; v1 < v2], dist_y + y_os_gtr <= y[v1]- y[v2] + W * (1 - lower[v1,v2]))
    # @constraint(m, con_dist_x4[v1 in verts, v2 in verts; v1 < v2], dist_y + y_os_lwr <= y[v2] - y[v1] + W * lower[v1,v2])

    @constraint(m, distsq1[v1 in verts, v2 in verts], dist^2 <= 1 * (x[v1] - x[v2])^2 + (W/H) * (y[v1] - y[v2])^2)
    #@constraint(m, con_x[v1 in verts, v2 in sp_adj[v1], v3 in sp_adj[v1]; v1 < v2], x[v1] <= x[v2])

    #@objective(m, Max, (dist_x + dist_y))
    @objective(m, Max, dist)

    optimize!(m)
    objective_value(m)

    #println(string("Distance Value: ",value.(m[:dist_x])))

    return [value.(m[:x]).data, value.(m[:y]).data]
end

function compute_positions_grid(g, W, H, padding)

    verts = [vertices(g)...]
    Wn = W - 2 * padding
    Hn = H - 2 * padding
    rows = ceil(sqrt(length(verts)))
    vspace = Hn/rows
    cols = rows
    hspace = Wn/rows
    xvals = Vector{Float64}()
    yvals = Vector{Float64}()
    crow = 0
    ccol = 0
    cval = 0
    for v in verts

        push!(xvals, ccol * hspace + padding)
        push!(yvals, crow * vspace + padding)
        if ccol <= cols
            ccol += 1
        else
            crow += 1
            ccol = 0
        end

    end

    return [xvals, yvals]
end



