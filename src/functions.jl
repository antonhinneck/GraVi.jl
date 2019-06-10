using Colors

function color_gradient_symmetric(
                                        value::S where S <: Number,
                                        maximum::T where T <: Number;
                                        max_clip::U where U <: Number = 1,
                                        style::Symbol = :floral,
                                        reverse::Bool = false
                                 )

        if max_clip > 1
                max_clip = 1
        elseif max_clip < 0
                max_clip = 0
        end

        normalized_value::Float64 = abs(value) / (maximum * max_clip)
        if normalized_value > 1.0
                normalized_value = 1.0
        elseif normalized_value < 0.0
                normalized_value = 0.0
        end

        color_1 = [220, 220, 220]
        color_2 = [0, 0, 0]
        output_color = [0,0,0]

        if style == :blossom
                color_1 = [53, 214, 192]
                color_2 = [127, 0, 130]
        elseif style == :floral
                color_1 = [255, 255, 255]
                color_2 = [127, 0, 130]
        elseif style == :desert
                color_1 = [80, 80, 80]
                color_2 = [255, 214, 94]
        elseif style == :park
                color_1 = [148, 244, 148]
                color_2 = [33, 33, 184]
        elseif style == :alert
                color_1 = [100, 100, 100]
                color_2 = [168, 1, 53]
        elseif style == :sunset
                color_1 = [158, 58, 84]
                color_2 = [18, 186, 249]
        elseif style == :grayscale
        elseif style == :dawn
                color_1 = [255, 250, 186]
                color_2 = [127, 0, 130]
        end

        if reverse
                color_sto = color_1
                color_1 = color_2
                color_2 = color_sto
        end

        output_color = [
                                ((color_2[1] - color_1[1]) * normalized_value + color_1[1]) / 255,
                                ((color_2[2] - color_1[2]) * normalized_value + color_1[2]) / 255,
                                ((color_2[3] - color_1[3]) * normalized_value + color_1[3]) / 255
                        ]

        #print(output_color)
        return RGB(output_color...)
end

function color_random(; preset = :none)

        output_color::Array{Float64,1} = [0,0,0]
        color_generated = false

        if preset == :none
                while (sum(output_color) > 320 && sum(output_color) < 120) || !color_generated
                        output_color = rand(0:255, 3)
                        color_generated = true
                end
                output_color = output_color / 255
        elseif preset == :blue
                output_color = [40, 40, rand(50:255, 1)[1]] / 255
        end

        return RGB(output_color...)
end
