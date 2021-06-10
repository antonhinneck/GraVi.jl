function arrow_head_to(ctx, x, y; a_angle = 0, ah_angle = pi/16, ah_length = 5.0, color = [0, 0, 0], lw = 1.0, offset = :trigon, tip_mod = 1.0)
    # Addition to cairo plotting
    len_x = cos(ah_angle) * ah_length + tip_mod
    len_y = sin(ah_angle) * ah_length * 2

    offset_x = 1 * len_x * cos(a_angle) + len_y / 2 * sin(a_angle)
    offset_y = - 1 * len_x * sin(a_angle) + len_y / 2 * cos(a_angle)

    move_to(ctx, x - offset_x, y + offset_y)
    rel_line_to(ctx, ah_length * cos(a_angle - ah_angle), ah_length * sin(a_angle - ah_angle))
    rel_line_to(ctx, -ah_length * cos(a_angle + ah_angle), -ah_length * sin(a_angle + ah_angle))

    set_source_rgb(ctx, color...)
    set_line_width(ctx, lw)
    stroke(ctx)
end
