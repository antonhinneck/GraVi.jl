function plot(AG, dims;
                export_type = :svg,
                export_dir = "C://Users",
                lvl1_node_radius = 5,
                lvl1_font_size = 10,
                lvl1_label_offset = 2,
                lvl2_node_radius = 5,
                lvl2_font_size = 10,
                lvl2_label_offset = 2)

    if export_type == :pdf
        export_dir = string(@__DIR__,"//test.pdf")
        c = CairoPDFSurface(export_dir, dims[1], dims[2])
    else
        export_dir = string(@__DIR__,"//test.svg")
        c = CairoSVGSurface(export_dir, dims[1], dims[2])
    end

    text = "peace"
    cr = CairoContext(c)
    select_font_face(cr, "Times", 1, 1)
    set_font_size(cr, lvl1_font_size)
    txt_exts = text_extents(cr, text)
    # 1: x_bearing
    # 2: y_bearing
    # 3: width
    # 4: height

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

    coordinates = build_layout(assets_nodes)

    print(assets_nodes)
    pos = [0,0]
    set_source_rgb(cr, [0.0,0.0,0.0]...)
    circle(cr, pos[1] + lvl1_node_radius, pos[2] + lvl1_node_radius, lvl1_node_radius)
    fill(cr)
    move_to(cr, pos[1] + 2 * lvl1_node_radius + lvl1_label_offset, pos[2] + txt_exts[4])
    show_text(cr, text)

    finish(c)

end
