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

    finish(c)

end
