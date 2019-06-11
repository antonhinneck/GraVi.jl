function build_layout(assets)

    vertices = [i for i in 1:length(assets)]

    buildLayout = Model()

    @variable(buildLayout, pos_x[vertices] >= 0)
    @variable(buildLayout, pos_y[vertices] >= 0)
    @variable(buildLayout, max_x >= 0)
    @variable(buildLayout, max_y >= 0)
    @variable(buildLayout, collsion_x[vertices], Bin)
    @variable(buildLayout, collsion_Y[vertices], Bin)
    @variable(buildLayout, adj_angle[vertices, vertices, 4], Bin)

    @objective(buildLayout, Min, max_x + max_y)

    @constraint(buildLayout, set_max_x[v = vertices],
    pos_x[v] <= max_x)

    @constraint(buildLayout, set_max_y[v = vertices],
    pos_y[v] <= max_y)

    @constraint(TS, voltage_1[l = data.lines],
    (theta[data.line_start[l]] - theta[data.line_end[l]]) + (1 - switched[l]) * M >= power_flow_var[l] * data.line_reactance[l])

    status = optimize!(TS, with_optimizer(Gurobi.Optimizer, OutputFlag = 0))

    coordinates = Vector{N where I <: Number, N where I <: Number}
    return coordinates
end
