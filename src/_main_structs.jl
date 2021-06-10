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