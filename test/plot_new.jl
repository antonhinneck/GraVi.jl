using Cairo

mutable struct legend
    position::Int64
    # The position is denoted by an integer, where 1 = top, 2 = bottom, 3 = left, 4 = right, 5 = none.

    width::Int64
    height::Int64

    anchor_x::Int64
    anchor_y::Int64
    # The anchor denotes the left top corner
    # of the legend box.

    legend(position) = begin new(position) end
end

mutable struct figure
    W::Int64
    H::Int64
    padding::Int64
    legend::legend
    cairo_surface::Any
    cairo_context::Any
    # The legend can point to a legend object or nothing.
    export_dir::String
    export_type::Symbol
    # The export type is denoted by an integer with 1 = pdf and 2 = svg.
    figure() = begin new() end
    figure(W, H) = begin new(W, H) end
end

function init_figure(fig, name, W, H;
    padding = 10,
    export_type = :pdf,
    export_dir = @__DIR__)

    fig.W = W
    fig.H = H

    fig.padding = padding
    fig.legend = legend(5)
    fig.export_type = export_type

    if export_type == :pdf
        fig.export_dir = string(@__DIR__,"\\",name,".pdf")
        println("Export Type: PDF")
    else
        fig.export_dir = string(@__DIR__,"\\",name,".svg")
        println("Export Type: SVG")
    end

    fig.cairo_surface = CairoPDFSurface(fig.export_dir, fig.W, fig.H)
    fig.cairo_context = CairoContext(fig.cairo_surface)

    select_font_face(fig.cairo_context, "Times", 1, 1)
    set_font_size(fig.cairo_context, 12.0)
end


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

function inv_adjlist(g)
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

function arrow_head_to(ctx, x, y; a_angle = 0, ah_angle = pi/16, ah_length = 5.0, color = [0, 0, 0], lw = 1.0, offset = :trigon, tip_mod = 1.0)
    # Addition to cairo plotting
    len_x = cos(ah_angle) * ah_length + tip_mod
    len_y = sin(ah_angle) * ah_length * 2

    offset_x = 1 * len_x * cos(a_angle) + len_y / 2 * sin(a_angle)
    offset_y = - 1 * len_x * sin(a_angle) + len_y / 2 * cos(a_angle)

    move_to(fig.cairo_context, x - offset_x, y + offset_y)
    rel_line_to(fig.cairo_context, ah_length * cos(a_angle - ah_angle), ah_length * sin(a_angle - ah_angle))
    rel_line_to(fig.cairo_context, -ah_length * cos(a_angle + ah_angle), -ah_length * sin(a_angle + ah_angle))

    set_source_rgb(fig.cairo_context, color...)
    set_line_width(fig.cairo_context, lw)
    stroke(fig.cairo_context)

end
