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
    #println(edges_start_at_bus)

    for v in _vertices

        edges_lwr = Vector{Int64}()
        vals_lwr = Vector{Float64}()
        edges_gtr = Vector{Int64}()
        vals_gtr = Vector{Float64}()

        for e in edges_start_at_bus[v]

            if xvals[_edges[e].dst] < xvals[v]
                push!(edges_lwr, e)
                push!(vals_lwr, yvals[_edges[e].dst])
            else
                push!(edges_gtr, e)
                push!(vals_gtr, yvals[_edges[e].dst])
            end
        end

        perm_lwr = sortperm(vals_lwr)
        #permute!(vals_lwr, perm_lwr)
        permute!(edges_lwr, perm_lwr)

        perm_gtr = sortperm(vals_gtr, rev = true)
        #permute!(vals_gtr, perm_gtr)
        permute!(edges_gtr, perm_gtr)

        ctr = 1
        for e in edges_lwr
            edge_start_offset[e] = ctr
            ctr += 1
        end
        for e in edges_gtr
            edge_start_offset[e] = ctr
            ctr += 1
        end
    end

    return edge_start_offset
end