function plot(fig, graph, name, W, H; radius = 2, rect_w = 1, rect_h = 6, root = :center, lw = 1.0, v_line_dist = 2.0, lstyle = :rectangular, bstyle = :rectangle, font_size = 8, text_pad = 1.0, text_loc = :top)

    init_figure(fig, name, W, H)

    vertices = [LightGraphs.vertices(graph)...]
    edges = [LightGraphs.edges(graph)...]

    text_w_offset = 0
    text_h_offset = 0
    if text_loc == :top
        set_font_size(fig.cairo_context, font_size)
        max_height = 0
        max_width = 0
        for i in [LightGraphs.vertices(graph)...]
            text_dims = text_extents(fig.cairo_context, string(i))
            if text_dims[3] > max_width
                max_width = text_dims[3]
            end
            if text_dims[4] > max_height
                max_height = text_dims[4]
            end
        end
        text_w_offset = max_width
        text_h_offset = max_height
    end

    coords = GraphVisualization.compute_positions(graph, W, H, fig.padding, root = root, x_os = rect_w + text_w_offset / 2, y_os_lwr = rect_h, y_os_gtr = rect_h + text_h_offset)
    x_start_offset = get_x_start_offset(graph, coords[1], coords[2])
    xso = 2

    #println(x_start_offset)
    # coords contains x and y positions

    # PLOT EDGES
    ectr = 1
    if lstyle == :direct
        # Plot edges: direct
        for e in edges
            s = e.src
            d = e.dst
            set_line_width(fig.cairo_context, lw)
            set_source_rgb(fig.cairo_context, [0, 0, 1]...)
            move_to(fig.cairo_context, coords[1][s], coords[2][s])
            line_to(fig.cairo_context, coords[1][d], coords[2][d])
            stroke(fig.cairo_context)
        end
    elseif lstyle == :rectangular
        # Plot edges: rectangular
        for e in edges
            s = e.src
            d = e.dst

            set_line_width(fig.cairo_context, lw)
            set_source_rgb(fig.cairo_context, [0, 0, 1]...)

            # if x_start_offset[ectr] == 1.0 || x_start_offset[ectr] == 0.0

            #     move_to(fig.cairo_context, coords[1][s], coords[2][s])
            #     line_to(fig.cairo_context, coords[1][s], coords[2][d])
            #     line_to(fig.cairo_context, coords[1][d], coords[2][d])
            #     stroke(fig.cairo_context)

            #     if coords[1][s] < coords[1][d]
            #         arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = 0, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
            #     else
            #         arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = pi, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
            #     end

            # else

            offset = (x_start_offset[ectr])
            move_to(fig.cairo_context, coords[1][s], coords[2][s] + rect_h - v_line_dist * offset)
            line_to(fig.cairo_context, coords[1][s] + xso * offset + text_w_offset / 2, coords[2][s] + rect_h - v_line_dist * offset)
            line_to(fig.cairo_context, coords[1][s] + xso * offset + text_w_offset / 2, coords[2][d])
            line_to(fig.cairo_context, coords[1][d], coords[2][d])
            stroke(fig.cairo_context)

            if coords[1][s] < coords[1][d]
                arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = 0, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
            else
                arrow_head_to(fig.cairo_context, coords[1][d], coords[2][d], a_angle = pi, color = [0, 0, 1], ah_length = 8.0, ah_angle = pi/20, tip_mod = 2)
            end
            #end
            ectr += 1
        end
    end

    # Plot vertices
    for v in vertices
        if bstyle == :circle
            set_source_rgb(fig.cairo_context, [0,0,0]...)
            circle(fig.cairo_context, coords[1][v], coords[2][v], radius)
            fill(fig.cairo_context)
        elseif bstyle == :rectangle
            set_source_rgb(fig.cairo_context, [0,0,0]...)
            set_source_rgb(fig.cairo_context, 0.0, 0.0, 0.0);
            set_line_width(fig.cairo_context, 1);
            rectangle(fig.cairo_context, coords[1][v] - rect_w, coords[2][v] - rect_h, 2 * rect_w, 2 * rect_h);
            #rectangle(cr, 180, 20, 80, 80);
            stroke_preserve(fig.cairo_context);
            fill(fig.cairo_context);

            if text_loc == :top
                set_font_size(fig.cairo_context, 8)
                vertex_id = string(v)
                text_dims = text_extents(fig.cairo_context, vertex_id)
                move_to(fig.cairo_context, coords[1][v] - text_dims[3] / 2, coords[2][v] - rect_h - text_pad)
                show_text(fig.cairo_context, vertex_id)
            end
        end
    end

    finish(fig.cairo_surface)

    return fig, coords
end