using Colors

mutable struct canvas

    resolution::Array{I where I <: Integer, 1}

end

mutable struct layout

    canvas::canvas

end

function layout(resolution::Array{Int64,1};
                border::Array{Int64, 1} = [10, 10],
                border_color::Colors.RGB = RGB([0,0,0]),
                legend::Bool = true,
                legend_position::Symbol = :below)



end
