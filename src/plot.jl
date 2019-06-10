struct elements
    Vertices::I where I <: Integer
    VertexLabels::Dict{I where I <: Integer, String}
    LabelDimensions

end

function decomposeGraph(AG)

    elmnts
end

function plot(AG, dims; export_type = :svg, export_dir = "C://Users")

print(current_dir)
node_label_font_size = 8

    if export_type == :pdf
        export_dir = string(@__DIR__,"//test.pdf")
        c = CairoPDFSurface(current_dir, dims[1], dims[2])
    else
        export_dir = string(@__DIR__,"//test.svg")
        c = CairoSVGSurface(current_dir, dims[1], dims[2])
    end

    cr = CairoContext(c)
    select_font_face(cr, "Times", 1, 1)
    set_font_size(cr, node_label_font_size)
    print(text_extents(cr, "peace"))
    # 1: x_bearing
    # 2: y_bearing
    # 3: width
    # 4: height

    finish(c)

end
