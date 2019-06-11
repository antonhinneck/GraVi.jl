function build_layout(assets)
## Function contains MILP to generate a set of feasible
## 2D coordinates for all passed assets.
##---------------------------------------------------------
## To Do: Try differnet solvers - current default is Gurobi
##---------------------------------------------------------

    vertices = [i for i in 1:length(assets)]

    buildLayout = Model()

    @variable(buildLayout, pos_x[vertices] >= 0)
    @variable(buildLayout, pos_y[vertices] >= 0)
    @variable(buildLayout, max_x >= 0)
    @variable(buildLayout, max_y >= 0)
    @variable(buildLayout, collsion_x[vertices, vertices], Bin)
    # 1: First element displayed at a lower x-index
    # 2: Second element displayed at a lower x-index
    #-----------------------------------------------
    @variable(buildLayout, collsion_y[vertices, vertices], Bin)
    # 1: First element displayed at a lower y-index
    # 2: Second element displayed at a lower y-index
    #-----------------------------------------------
    @variable(buildLayout, adj_angle[vertices, vertices, 4], Bin)

    @objective(buildLayout, Min, max_x + max_y)

    @constraint(buildLayout, set_max_x[v = vertices],
    pos_x[v] <= max_x)

    @constraint(buildLayout, set_max_y[v = vertices],
    pos_y[v] <= max_y)

    @constraint(buildLayout, collision_x_1[v1 = vertices, v2 = vertices],
    pos_x[v1] + assets[v1][1] <= pos_x[v2])

    @constraint(buildLayout, collision_x_2[v1 = vertices, v2 = vertices],
    pos_x[v1] + assets[v1][1] <= pos_x[v2])

    @constraint(buildLayout, set_max_y[v1 = vertices, v2 = vertices],
    pos_x[v1] <= pos_x[v2])

    status = optimize!(TS, with_optimizer(Gurobi.Optimizer, OutputFlag = 0))

    coordinates = Vector{N where I <: Number, N where I <: Number}
    return coordinates
end
