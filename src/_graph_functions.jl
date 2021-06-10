function bfs(G; initialization = -1, debug = false)

    g_nv = nv(G)
    g_ne = ne(G)
    adj = G.fadjlist

    adj_length = Array{Int16, 1}(undef, g_nv)
    sp = Array{Int16, 1}(undef, g_nv)
    visited = Array{Bool, 1}(undef, g_nv)
    queue = Vector{Int16}()
    seq = Array{Int16, 1}(undef, g_nv)

    sp_adj = Vector{Vector{Int16}}()
    for i in 1:g_nv
        push!(sp_adj, Vector{Int16}())
    end

    for i in 1:g_nv

        sp[i] = 0
        visited[i] = false
        adj_length[i] = length(adj[i])

    end

    # Initialization -1 means random selection
    if initialization == -1
        z = rand(1:g_nv)
    else
        z = initialization
    end

    push!(queue, z)
    sp[z] = 0
    visited[z] = true
    seq[1] = z

    ctr = 2
    while length(queue) != 0

        deleteat!(queue, 1)

        for i in 1:adj_length[z]
            cv = adj[z][i]
            if !visited[cv]
                seq[ctr] = cv
                ctr += 1
                push!(queue, cv)
                sp[cv] = z
                visited[cv] = true
                push!(sp_adj[z], cv)
            end
        end

        if length(queue) > 0
            z = queue[1]
        end
    end

    if debug
        for i in 1:g_nv
            if !visited[i]
                println("[INFO] Vertex ",i," not visited.")
            end
        end
    end

    return sp_adj, sp, seq
end

function max_degree_vertex(g)

    adj = g.fadjlist
    g_nv = nv(g)

    @assert g_nv >= 1 "Graph has no vertices."

    max_deg_vert = 1
    max_deg = size(adj[max_deg_vert], 1)

    for i in 2:g_nv
        if size(adj[i], 1) > max_deg
            max_deg_vert = i
            max_deg = size(adj[i], 1)
        end
    end

    return max_deg_vert, max_deg

end

function inv_fadjlist(g)
    inv_fadjlist = Vector{Vector{Int64}}()
    g_nv = nv(g)
    for i in 1:g_nv
        push!(inv_fadjlist, Vector{Int64}())
        inv_fadjlist[i] = [i for i in 1:g_nv]
        ctr = 0
        for j in g.fadjlist[i]
            deleteat!(inv_fadjlist[i],  j - ctr)
            ctr += 1
        end
    end
    return inv_fadjlist
end