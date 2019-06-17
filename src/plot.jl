function plot(AG, dims;
                export_type = :svg,
                export_dir = "C://Users",
                lvl1_node_radius = 1.2,
                lvl1_font_size = 2.4,
                lvl1_label_offset = 1.8,
                lvl2_node_radius = 0.6,
                lvl2_font_size = 10,
                lvl2_label_offset = 4,
                legend_height = 100,
                jitter = 0,
                line_width = 0.25,
                legend = false,
                label_offset_orthogonal = 1)

    #layout = layout(dims)
    center = dims / 2
    plot_border_top = dims[2]
    plot_border_bottom = 0
    plot_border_left = dims[1]
    plot_border_right = 0
    _vertex_angles = Vector{Float64}()

    @inline function init_surface(export_dir, export_type, dims)
        if export_type == :pdf
            export_dir = string(@__DIR__,"//test.pdf")
            c = CairoPDFSurface(export_dir, dims[1], dims[2])
            cr = CairoContext(c)
            select_font_face(cr, "Times", 1, 1)
            set_font_size(cr, lvl1_font_size)
        else
            export_dir = string(@__DIR__,"//test.svg")
            c = CairoSVGSurface(export_dir, dims[1], dims[2])
            cr = CairoContext(c)
            select_font_face(cr, "Times", 1, 1)
            set_font_size(cr, lvl1_font_size)
        end
        return c, cr
    end

    c, cr = init_surface(export_dir, export_type, dims)

    text = "test"
    txt_exts = text_extents(cr, text)
    # 1: x_bearing
    # 2: y_bearing
    # 3: width
    # 4: height

    # Probe surface dimensions
    #-------------------------
    @inline function max_dims(AG, lvl1_node_radius, lvl2_node_radius)
        max_x = 0
        max_y = maximum([lvl1_node_radius, lvl2_node_radius])
        for i in vertices(AG.Graph)
            text_dims = text_extents(cr, AG.VertexLabels[i])
            if text_dims[3] > max_x
                max_x = text_dims[3]
            end
            if text_dims[4] > max_y
                max_y = text_dims[4]
            end
        end
        return [max_x, max_y]
    end

    max_vertex_dims = max_dims(AG, lvl1_node_radius, lvl2_node_radius)
    height_estimate = max_vertex_dims[2] * (maximum(vertices(AG.Graph)) / 2 + 1)
    width_estimate = max_vertex_dims[2] * (maximum(vertices(AG.Graph)) / 2 + 1)

    if (width_estimate > dims[1]) && !(height_estimate > dims[2])
        print("\nINFO: Resizing Surface.\n")
        dims = [width_estimate, dims[2]]
        c, cr = init_surface(export_dir, export_type, dims)
    elseif  !(width_estimate > dims[1]) && (height_estimate > dims[2])
        print("\nINFO: Resizing Surface.\n")
        dims = [dims[1], height_estimate]
        c, cr = init_surface(export_dir, export_type, dims)
    elseif  (width_estimate > dims[1]) && (height_estimate > dims[2])
        print("\nINFO: Resizing Surface.\n")
        dims = [width_estimate, height_estimate]
        c, cr = init_surface(export_dir, export_type, dims)
    end

    # Preprocessing Assets
    #---------------------
    assets_nodes = Vector{Array{I where I <: Number, 1}}()

    for i in vertices(AG.Graph)
        level = AG.VertexTypes[i]
        if level == 1
            set_font_size(cr, lvl1_font_size)
            label_extents = text_extents(cr, AG.VertexLabels[i])
            width = label_extents[3] + 2 * lvl1_node_radius + lvl1_label_offset
            height = maximum([label_extents[4], 2 * lvl2_node_radius])
        elseif level == 2
            set_font_size(cr, lvl2_font_size)
            label_extents = text_extents(cr, AG.VertexLabels[i])
            width = label_extents[3] + 2 * lvl2_node_radius + lvl1_label_offset
            height = maximum([label_extents[4], 2 * lvl2_node_radius])
        end
        push!(assets_nodes, [width, height, level])
    end

    @inline function _vertex_positions_inner(lvl1_ratio = 0.58, lvl2_ratio = 0.8, switch=1)

        lvl1_nv = 0
        for i in vertices(AG.Graph)
            if AG.VertexTypes[i] == 1
                lvl1_nv += 1
            end
        end

        degrees = 2 * pi
        degree_sections = degrees / lvl1_nv
        lvl1_radius = dims[1] / 2 * lvl1_ratio
        lvl2_radius = dims[1] / 2 * lvl2_ratio
        positions = Vector{Tuple{Float64, Float64}}()

        #=
        set_line_width(cr, 0.2)
        set_source_rgb(cr, [0,0,0]...)
        circle(cr, center[1], center[2], lvl1_radius)
        stroke(cr)

        set_line_width(cr, 0.2)
        set_source_rgb(cr, [0,0,0]...)
        circle(cr, center[1], center[2], lvl2_radius)
        stroke(cr)
        =#

        counter_lvl1_vertex = 0
        for i in vertices(AG.Graph)
            if AG.VertexTypes[i] == 1
                push!(positions, Tuple([cos(degree_sections * counter_lvl1_vertex) * lvl1_radius + center[1]
                                        sin(degree_sections * counter_lvl1_vertex) * lvl1_radius + center[2]]))
                counter_lvl1_vertex += 1
                push!(_vertex_angles, degree_sections * counter_lvl1_vertex)
            elseif AG.VertexTypes[i] == 2
                sub_degree_sections = degree_sections / length(AG.Graph.fadjlist[i])
                push!(positions, Tuple([cos(degree_sections * (counter_lvl1_vertex - 1)) * lvl2_radius + center[1]
                                        sin(degree_sections * (counter_lvl1_vertex - 1)) * lvl2_radius + center[2]]))
                push!(_vertex_angles, degree_sections * (counter_lvl1_vertex - 1))
            end
        end

        return positions
    end

    vertex_positions = _vertex_positions_inner()

    ## PLOT EDGES
    ##-----------
    degs = degree(AG.Graph)
    for (i, e) in enumerate(edges(AG.Graph))
        (s, d) = (src(e), dst(e))

        set_line_width(cr, line_width)
        if AG.VertexTypes[s] == 1 && AG.VertexTypes[d] == 1
            set_line_width(cr, 0.35)
            set_source_rgb(cr, [76, 156, 255] / 255 ...)
            curve_to(cr, vertex_positions[s][1], vertex_positions[s][2],
                center[1],
                center[2],
                vertex_positions[d][1], vertex_positions[d][2])
            stroke(cr)
        end
        if AG.VertexTypes[s] == 2 || AG.VertexTypes[d] == 2
            set_line_width(cr, 0.35)
            set_source_rgb(cr, [0, 49, 191] / 255 ...)
            move_to(cr, vertex_positions[s][1], vertex_positions[s][2])
            line_to(cr, vertex_positions[d][1], vertex_positions[d][2])
            stroke(cr)
        end
    end
    set_line_width(cr, 1)

    @inline function flip_angle(angle::Float64)
        new_angle = angle
        if angle > (pi / 2) && angle < (3 * pi / 2)
            new_angle = angle + pi
        end
        return new_angle
    end

    ## PLOT VERTICES
    ## -------------
    nv = maximum(vertices(AG.Graph))
    for i in vertices(AG.Graph)

        (pos_x, pos_y) = vertex_positions[i]
        move_to(cr, pos_x, pos_y) # Prevents artifacts in the exported pdf file

        set_source_rgb(cr, [1,1,1]...)
        circle(cr, pos_x, pos_y, lvl1_node_radius)
        fill(cr)

        set_source_rgb(cr, [0.0,0.0,0.0]...)
        set_line_width(cr, 0.2)
        circle(cr, pos_x, pos_y, lvl1_node_radius)
        stroke(cr)

        if AG.VertexTypes[i] == 2
            text = AG.VertexLabels[i]
        else
            text = string(i)
        end
        label_extents = text_extents(cr, text)
        angle = _vertex_angles[i]
        #set_source_rgb(cr, wireplot_node_label_font_color...)

        if angle >= (pi / 2) && angle < (3 * pi / 2)
            label_origin_x = pos_x - (lvl1_label_offset + lvl1_node_radius / 2) * cos(_vertex_angles[i]) - label_offset_orthogonal * sin(pi - _vertex_angles[i])
            label_origin_y = pos_y - (lvl1_label_offset + lvl1_node_radius / 2) * sin(_vertex_angles[i]) - label_offset_orthogonal * cos(pi - _vertex_angles[i])
            label_border_left = pos_x - label_extents[3] / 2 - 1
            label_border_right = label_origin_x + label_extents[3]
            label_border_top = label_origin_y + label_extents[4]
            label_border_bottom = label_origin_y
        else
            label_origin_x = pos_x - (label_extents[3] + lvl1_label_offset + lvl1_node_radius / 2) * cos(_vertex_angles[i]) + label_offset_orthogonal * sin(pi - _vertex_angles[i])
            label_origin_y = pos_y - (label_extents[3] + lvl1_label_offset + lvl1_node_radius / 2) * sin(_vertex_angles[i]) + label_offset_orthogonal * cos(pi - _vertex_angles[i])
            label_border_left = pos_x - label_extents[3] / 2 - 1
            label_border_right = label_origin_x + label_extents[3]
            label_border_top = label_origin_y + label_extents[4]
            label_border_bottom = label_origin_y
        end

        move_to(cr, label_origin_x, label_origin_y)
        rotate(cr, flip_angle(_vertex_angles[i]))
        show_text(cr, text)
        rotate(cr, -flip_angle(_vertex_angles[i]))

        plot_border_bottom = max(plot_border_bottom, label_border_bottom)
        plot_border_right = max(plot_border_right, label_border_right)
        plot_border_top = min(plot_border_top, label_border_top)
        plot_border_left = min(plot_border_left, label_border_left)
    end

    #coordinates = build_layout(assets_nodes)

    #print(assets_nodes)

    #pos = [0,0]
    #set_source_rgb(cr, [0.0,0.0,0.0]...)
    #circle(cr, pos[1] + lvl1_node_radius, pos[2] + lvl1_node_radius, lvl1_node_radius)
    #fill(cr)
    #move_to(cr, pos[1] + 2 * lvl1_node_radius + lvl1_label_offset, pos[2] + txt_exts[4])
    #show_text(cr, text)

    finish(c)

end
