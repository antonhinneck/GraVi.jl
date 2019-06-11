function build_layout(vertices)

    buildLayout = Model()
    #TS = Model(solver = GLPKSolverMIP())

    @variable(buildLayout, pos_x[vertices] >= 0)
    @variable(buildLayout, pos_y[vertices] >= 0)
    @variable(buildLayout, max_x >= 0)
    @variable(buildLayout, max_y >= 0)
    @variable(buildLayout, collsion_x[vertices], Bin)
    @variable(buildLayout, collsion_Y[vertices], Bin)
    @variable(buildLayout, adj_angle[vertices, vertices, 4], Bin)

    @objective(TS, Min, sum(data.generator_costs[g] * generation[g] for g in data.generators))

    @constraint(TS, market_clearing[n = data.busses],
    sum(generation[g] for g in data.generators_at_bus[n]) + sum(power_flow_var[l] for l in data.lines_start_at_bus[n]) - sum(power_flow_var[l] for l in data.lines_end_at_bus[n]) == data.bus_demand[n])

    @constraint(TS, voltage_1[l = data.lines],
    (theta[data.line_start[l]] - theta[data.line_end[l]]) + (1 - switched[l]) * M >= power_flow_var[l] * data.line_reactance[l])

    status = optimize!(TS, with_optimizer(Gurobi.Optimizer, OutputFlag = 0))

    coordinates = Vector{N where I <: Number, N where I <: Number}
    return coordinates
end
